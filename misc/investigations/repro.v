// Minimal repro: the arp_cache CRC config (LFSR_WIDTH=32, DATA_WIDTH=32, GALOIS, REVERSE)
`default_nettype none
module repro (
    input  wire [31:0] ip_in,
    output wire [31:0] hash_out
);
    lfsr #(
        .LFSR_WIDTH(32),
        .LFSR_POLY(32'h4c11db7),
        .LFSR_CONFIG("GALOIS"),
        .LFSR_FEED_FORWARD(0),
        .REVERSE(1),
        .DATA_WIDTH(32),
        .STYLE("AUTO")
    ) h (
        .data_in(ip_in),
        .state_in(32'hffffffff),
        .data_out(),
        .state_out(hash_out)
    );
endmodule
