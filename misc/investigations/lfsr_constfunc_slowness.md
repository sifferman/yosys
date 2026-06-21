# Constant-function elaboration is pathologically slow on verilog-ethernet `lfsr`

## Symptom
`read_verilog -sv lfsr.v` + a single instance of alexforencich verilog-ethernet's
`lfsr` with `LFSR_WIDTH=32, DATA_WIDTH=32` (the arp_cache CRC config) does not finish
elaboration within minutes — the front-end hangs evaluating the `lfsr_mask` constant
function. Confirmed still present on yosys main (this branch's base). The slang
front-end elaborates the same design in ~1 s, which is why downstream projects switch
to `read_slang` for verilog-ethernet.

## Minimal reproducer
See `lfsr.v` (upstream verilog-ethernet, unmodified) and:

```verilog
module repro (input [31:0] ip_in, output [31:0] hash_out);
  lfsr #(.LFSR_WIDTH(32), .LFSR_POLY(32'h4c11db7), .LFSR_CONFIG("GALOIS"),
         .LFSR_FEED_FORWARD(0), .REVERSE(1), .DATA_WIDTH(32), .STYLE("AUTO"))
    h (.data_in(ip_in), .state_in(32'hffffffff), .data_out(), .state_out(hash_out));
endmodule
```

```
yosys -p 'read_verilog -sv lfsr.v repro.v; hierarchy -top repro; flatten; stat'   # >>60 s
```

## Root cause (frontends/ast/simplify.cc :: AstNode::eval_const_function)
`lfsr_mask` is a constant function evaluated once per generated output bit
(`LFSR_WIDTH + DATA_WIDTH = 64` calls for the 32/32 config), and each call runs the
full shift-register simulation in nested `for` loops over `LFSR_WIDTH`/`DATA_WIDTH`.

`eval_const_function` interprets the body statement-by-statement:
  * each `AST_FOR` is rewritten to `AST_WHILE` and the loop body is **cloned** into
    `block->children` every iteration;
  * after essentially every statement it runs `while (stmt->simplify(true,1,-1,false)){}`
    to a fixpoint.
With deeply nested loops over width-32 vectors this is super-linear (repeated cloning +
re-simplification of a growing statement list), so a single width-32 `lfsr_mask` blows
up to tens of seconds, and a design instantiating several is effectively stuck.

## Possible directions (not yet implemented — larger change, needs careful testing)
  * Memoize / cache simplified sub-statements instead of re-simplifying to fixpoint
    after every assignment.
  * Avoid re-cloning the loop body each `AST_WHILE` iteration (reuse + reset locals).
  * A dedicated faster constant-expression interpreter for the in_param path.

A correct, regression-safe fix here is non-trivial; this branch documents the analysis
and a runnable reproducer as a starting point.
