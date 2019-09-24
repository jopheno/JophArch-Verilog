module NStacks(
	input STACK_ENB,
	input clock,

	input STACK_pop_flag,
	
	input STACK_push_flag,
	input [31:0] STACK_push_value,

	input [31:0] STACK_data,
	
	output reg [31:0] STACK_TOP,

	output reg [15:0] STACK_AMOUNT,
	
	output reg STACK_write_flag,
	output reg [15:0] STACK_write_addr,
	output reg [31:0] STACK_write_data
	
);


initial begin
	STACK_write_flag = 1'b0;
	STACK_write_addr = 16'b0;
	STACK_write_data = 32'b0;
	
	STACK_TOP = 32'b0;
	STACK_AMOUNT = 16'b0;
end

  
	always@(negedge clock) begin
			if (STACK_pop_flag) begin
				integer size;
			
				STACK_write_flag = 0;
				STACK_write_data = 0;

				size = STACK_write_addr - 1;
				STACK_write_addr = size[15:0];
			end
			
			if (STACK_push_flag) begin
				integer size;

				size = STACK_write_addr + 1;
				STACK_write_addr = size[15:0];
				STACK_write_data = STACK_push_value;
				STACK_write_flag = 1;
			end

	end

  always@(STACK_data, STACK_write_addr) begin
		STACK_TOP = STACK_data;
		STACK_AMOUNT = STACK_write_addr;
	end

endmodule
