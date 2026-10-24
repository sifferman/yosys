typedef logic signed [3:0] operand_t;

module typedef_signed_element(
	input operand_t [1:0] operands,
	output logic [7:0] element,
	output logic [15:0] array
);
	assign element = operands[0];
	assign array = operands;
endmodule
