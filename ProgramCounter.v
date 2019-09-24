module ProgramCounter(

	input clock,
	input init_flag,
	input JMP_flag,
	input [31:0] result,
	
	input CALL_flag,
	input RET_flag,
	input PUSH_flag,
	input POP_flag,
	input GSA_flag,
	input SWITCH_flag,
	
	output reg [15:0] PC_pos = 0,
	
	output reg PRG_write_flag,
	output reg [7:0] PRG_write_addr,
	output reg [31:0] PRG_write_data
);

	reg [31:0] CALL_STACK [1024];//1024
	reg [9:0] CALL_STACK_SIZE; //9

	initial begin
		integer i = 0;

		PC_pos = 16'b0;
		PRG_write_flag = 0;
		PRG_write_addr = 16'b0;
		PRG_write_data = 32'b0;
	
		for (i = 0; i < 128; i = i +1) begin
			CALL_STACK[i] = 0;
		end

		CALL_STACK_SIZE = 0;
	end
	
	always@(negedge clock) begin
		if (init_flag) begin
			if (JMP_flag == 1) begin
				PC_pos = result[15:0];
				
				PRG_write_data = 32'b0;
				PRG_write_addr = 16'b0;
				PRG_write_flag = 0;
			end else if(CALL_flag == 1) begin
				// ADICIONAR NA CALLSTACK

				CALL_STACK[CALL_STACK_SIZE] = (PC_pos + 1);
				CALL_STACK_SIZE = CALL_STACK_SIZE + 1;
				PC_pos = result[15:0];
				
				PRG_write_data = 32'b0;
				PRG_write_addr = 16'b0;
				PRG_write_flag = 0;
				
			end else if (RET_flag == 1) begin
				// RETIRAR DA CALLSTACK
				
				CALL_STACK_SIZE = CALL_STACK_SIZE - 1;
				PC_pos = CALL_STACK[CALL_STACK_SIZE][15:0];
				
				PRG_write_data = 32'b0;
				PRG_write_addr = 16'b0;
				PRG_write_flag = 0;
				
				
			end else if (PUSH_flag == 1) begin
				// ADICIONAR DA CALLSTACK
				
				CALL_STACK[CALL_STACK_SIZE] = result;
				CALL_STACK_SIZE = CALL_STACK_SIZE + 1;
				PC_pos = PC_pos + 1;
				
				PRG_write_data = 32'b0;
				PRG_write_addr = 16'b0;
				PRG_write_flag = 0;
				
				
			end else if (POP_flag == 1) begin
				// RETIRAR DA CALLSTACK
				
				CALL_STACK_SIZE = CALL_STACK_SIZE - 1;
				PRG_write_data = CALL_STACK[CALL_STACK_SIZE][15:0];
				PRG_write_addr = result;
				PRG_write_flag = 1;
				
				
			end else if (GSA_flag == 1) begin

				PRG_write_data = CALL_STACK_SIZE;
				PRG_write_addr = result;
				PRG_write_flag = 1;
				
				
			end else if (SWITCH_flag == 1) begin
				// r_src = immediate[0]; -> Primeiro bit do imediato.
				
				PRG_write_data[31:0] = result[0];
				PRG_write_addr[7:0] = 8'b00100100;
				PRG_write_flag = 1;
				
			end else begin
				PC_pos = PC_pos + 1;
			end
		end
	end

endmodule
