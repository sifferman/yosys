`ifndef TESTBENCH
typedef logic signed [3:0] operand_t;

module source(output operand_t value);
	assign value = -2;
endmodule

module top(output logic [7:0] only_element, output logic [7:0] one_of_two_elements);
	operand_t [0:0] one_operand;
	operand_t [1:0] two_operands;
	source only_element_source(one_operand[0]);
	source one_of_two_source(two_operands[1]);
	assign two_operands[0] = 0;
	assign only_element = one_operand[0];
	assign one_of_two_elements = two_operands[1];
endmodule
`else
module testbench;
	wire [7:0] only_element, one_of_two_elements;
	top uut(only_element, one_of_two_elements);
	initial begin
		#1;
		$display("only_element: %b", only_element);
		$display("one_of_two_elements: %b", one_of_two_elements);
		if (only_element === 8'b11111110 && one_of_two_elements === 8'b11111110)
			$display("PASS");
		$finish;
	end
endmodule
`endif
