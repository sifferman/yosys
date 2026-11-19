#!/usr/bin/env bash
set -ex
# Without opt, so that a connection in the wrong direction stays in the netlist.
${YOSYS} -q -o port_connection_output_syn.v -p 'hierarchy -top top; proc' port_connection_output.sv
iverilog -g2012 -o port_connection_output_sim -DTESTBENCH port_connection_output.sv port_connection_output_syn.v
vvp -N port_connection_output_sim > port_connection_output.out
cat port_connection_output.out
grep PASS port_connection_output.out
rm -f port_connection_output_syn.v port_connection_output_sim port_connection_output.out
