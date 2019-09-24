module ProgramCounter(

	input clock,
	input init_flag,
	input JMP_flag,
	input [15:0] JMP_pos,
	
	input CALL_flag,
	input RET_flag,
	
	output reg [15:0] PC_pos = 0
);

	reg [31:0] CALL_STACK [1024];//1024
	reg [9:0] CALL_STACK_SIZE; //9

	initial begin
		integer i = 0;

		PC_pos = 16'b0;
	
		for (i = 0; i < 128; i = i +1) begin
			CALL_STACK[i] = 0;
		end

		CALL_STACK_SIZE = 0;
	end
	
	always@(negedge clock) begin
		if (init_flag) begin
			if (JMP_flag == 1) begin
				PC_pos = JMP_pos;
			end else if(CALL_flag == 1) begin
				// ADICIONAR NA CALLSTACK

				CALL_STACK[CALL_STACK_SIZE] = (PC_pos + 1);
				CALL_STACK_SIZE = CALL_STACK_SIZE + 1;
				PC_pos = JMP_pos[15:0];
				
			end else if (RET_flag == 1) begin
				// RETIRAR DA CALLSTACK
				
				CALL_STACK_SIZE = CALL_STACK_SIZE - 1;
				PC_pos = CALL_STACK[CALL_STACK_SIZE][15:0];
				
				
			end else begin
				PC_pos = PC_pos + 1;
			end
		end
	end

endmodule
