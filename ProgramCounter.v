module ProgramCounter(

	input clock,
	input init_flag,
	input JMP_flag,
	input [31:0] result,
	input [15:0] r_k,
	input [15:0] sys_int_pos,

	input timer_int,
	input op_int,
	input [15:0] int_pos,
	
	input CALL_flag,
	input RET_flag,
	input PUSH_flag,
	input POP_flag,
	input GSA_flag,
	input SWITCH_flag,
	input SYS_flag,
	input Kernel_flag,
	
	output reg [15:0] PC_pos = 0,
	
	output reg PRG_write_flag,
	output reg [7:0] PRG_write_addr,
	output reg [31:0] PRG_write_data
);

	reg [15:0] CALL_STACK [1024];//1024
	reg [9:0] CALL_STACK_SIZE; //9
	
	wire [15:0] new_pos;
	
	assign new_pos[15:0] = result[15:0] + r_k[15:0];

	initial begin
		integer i = 0;

		PC_pos = 16'b0;
		PRG_write_flag = 0;
		PRG_write_addr = 16'b0;
		PRG_write_data = 32'b0;
	
		for (i = 0; i < 1024; i = i +1) begin
			CALL_STACK[i] = 0;
		end

		CALL_STACK_SIZE[9:0] = 10'b0;
	end
	
	always@(negedge clock) begin
		if (init_flag) begin

			PC_pos <= PC_pos + 1;

			if (timer_int == 0) begin
			
			if (JMP_flag == 1) begin
				PC_pos <= result[15:0];
				//PC_pos = new_pos[15:0];
				
				PRG_write_data = 32'b0;
				PRG_write_addr = 16'b0;
				PRG_write_flag = 0;
			end else if(CALL_flag == 1) begin
				// ADICIONAR NA CALLSTACK
				
				integer aux;
				aux = CALL_STACK_SIZE[9:0] + 1;

				CALL_STACK[CALL_STACK_SIZE] = (PC_pos + 1);
				CALL_STACK_SIZE = aux;
				//PC_pos = result[15:0];
				PC_pos <= new_pos[15:0];
				
				PRG_write_data = 32'b0;
				PRG_write_addr = 16'b0;
				PRG_write_flag = 0;
				
			end else if (RET_flag == 1) begin
				// RETIRAR DA CALLSTACK
				
				integer aux;
				aux = CALL_STACK_SIZE[9:0] - 1;
				
				CALL_STACK_SIZE = aux;
				PC_pos <= CALL_STACK[aux][15:0];
				
				PRG_write_data = 32'b0;
				PRG_write_addr = 16'b0;
				PRG_write_flag = 0;
				
				
			end else if (PUSH_flag == 1) begin
				// ADICIONAR DA CALLSTACK
				
				integer aux;
				aux = CALL_STACK_SIZE[9:0] + 1;
				
				//CALL_STACK[CALL_STACK_SIZE] = result;
				CALL_STACK[CALL_STACK_SIZE] = new_pos[15:0];
				CALL_STACK_SIZE[9:0] = aux;
				
				PRG_write_data = 32'b0;
				PRG_write_addr = 16'b0;
				PRG_write_flag = 0;
				
				
			end else if (POP_flag == 1) begin
				// RETIRAR DA CALLSTACK
				
				integer aux;
				aux = CALL_STACK_SIZE[9:0] - 1;
				
				CALL_STACK_SIZE = aux;
				PRG_write_data = CALL_STACK[CALL_STACK_SIZE][15:0];
				PRG_write_addr = result;
				PRG_write_flag = 1;
				
				
			end else if (GSA_flag == 1) begin

				PRG_write_data = {22'b0, CALL_STACK_SIZE[9:0]};
				PRG_write_addr = result;
				PRG_write_flag = 1;
				
				
			end else if (SWITCH_flag == 1) begin
				
				//PC_pos = result[15:0];
				PC_pos <= new_pos[15:0];
				PRG_write_data[31:0] = {31'b0, result[16]};
				PRG_write_addr[7:0] = 8'b00100100;
				PRG_write_flag = 1;
				
				
			end else if (SYS_flag == 1) begin
				
				PC_pos <= sys_int_pos[15:0];
				
				// Go to kernel offset
				PRG_write_data[31:0] = 32'b0;
				PRG_write_addr[7:0] = 8'b01100100;
				PRG_write_flag = 1;
				
				
			end else if (Kernel_flag == 1) begin

				// Go to result last 16 bits position
				PC_pos <= result[31:16];
				
				// Set kernel offset to results first 16 bits
				PRG_write_data[31:0] = {16'b0, result[15:0]};
				PRG_write_addr[7:0] = 8'b01100100;
				PRG_write_flag = 1;
			end
			end


			if (timer_int == 1 && (JMP_flag == 1 || CALL_flag == 1 || RET_flag == 1)) begin
				PC_pos <= int_pos[15:0];
				
				// Go to kernel offset
				PRG_write_data[31:0] = 32'b0;
				PRG_write_addr[7:0] = 8'b01100100;
				PRG_write_flag = 1;
			end
		end
	end

endmodule
