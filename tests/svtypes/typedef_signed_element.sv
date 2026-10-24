module top;
	typedef logic signed [4:1] operand_t;
	typedef operand_t [1:0] pair_t;

	operand_t [1:0] operands;
	operand_t [1:0][1:0] grid;
	operand_t [1:0] memory [1];
	pair_t [0:0] pairs;
	logic [4:1] words [1];
	logic index;
	operand_t [1:0] written;

	assign operands = '1;
	assign grid = '1;
	assign memory[0] = '1;
	assign pairs = '1;
	assign words[0] = '1;
	assign index = 1;
	always_comb begin
		written = '0;
		written[index] = '1;
	end

	// A comparison with a signed constant extends a select by its own sign.
	always_comb begin
		assert(operands[0] == 8'shff);
		assert(grid[1][0] == 8'shff);
		assert(memory[0][0] == 8'shff);
		assert(written[index] == 8'shff);
		assert(operands == 16'sh00ff);
		assert(operands[1:1] == 8'sh0f);
		assert(operands[0][4] == 8'sh01);
		assert(grid[0] == 16'sh00ff);
		assert(grid[1][1:1] == 8'sh0f);
		assert(pairs[0] == 16'sh00ff);
		assert(words[0] == 8'sh0f);
		assert($left(operands[0]) == 4);
	end
endmodule
