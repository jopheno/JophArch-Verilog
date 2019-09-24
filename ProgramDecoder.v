module ProgramDecoder(
	input JMP_ENB,
	input [31:0] DMA_current_instruction,
	input [31:0] f_register_value,
	input [31:0] s_register_value,
	input [31:0] t_register_value,
	input [23:0] immediate,
	input [15:0] PC_pos,
	output reg JMP_flag = 0,
	output reg CALL_flag = 0,
	output reg RET_flag = 0,
	output reg [3:0] Mini_ALU_op,
	output reg [31:0] Mini_ALU_v1,
	output reg [31:0] Mini_ALU_v2
);

	always@(*) begin
		if (JMP_ENB) begin
			case (DMA_current_instruction[28:24])
			
				5'b00001: begin // JMP
					Mini_ALU_op = 0;
					Mini_ALU_v1 = f_register_value;
					Mini_ALU_v2 = 32'b0;
					JMP_flag = 1;
					CALL_flag = 0;
					RET_flag = 0;
				end

				5'b01001: begin // JMPi
					Mini_ALU_op = 0;
					Mini_ALU_v1 = immediate[15:0];
					Mini_ALU_v2 = 32'b0;
					JMP_flag = 1;
					CALL_flag = 0;
					RET_flag = 0;
				end

				5'b01010: begin // JMPfi
					Mini_ALU_op = 0;
					Mini_ALU_v1 = PC_pos;
					Mini_ALU_v2 = immediate[15:0];
					JMP_flag = 1;
					CALL_flag = 0;
					RET_flag = 0;
				end

				5'b01011: begin // JMPbi
					Mini_ALU_op = 1;
					Mini_ALU_v1 = PC_pos;
					Mini_ALU_v2 = immediate[15:0];
					JMP_flag = 1;
					CALL_flag = 0;
					RET_flag = 0;
				end

				5'b00101: begin // JMPC
					Mini_ALU_op = 0;
					Mini_ALU_v1 = f_register_value;
					Mini_ALU_v2 = 32'b0;
					if (t_register_value >= 1)
						JMP_flag = 1;
					else
						JMP_flag = 0;
					
					CALL_flag = 0;
					RET_flag = 0;
				end

				5'b01101: begin // JMPCi
					Mini_ALU_op = 0;
					Mini_ALU_v1 = immediate[15:0];
					Mini_ALU_v2 = 32'b0;
					if (t_register_value[0] == 1)
						JMP_flag = 1;
					else
						JMP_flag = 0;
					
					CALL_flag = 0;
					RET_flag = 0;
				end

				5'b01110: begin // JMPCfi
					Mini_ALU_op = 0;
					Mini_ALU_v1 = PC_pos;
					Mini_ALU_v2 = immediate[15:0];
					if (t_register_value >= 1)
						JMP_flag = 1;
					else
						JMP_flag = 0;
					
					CALL_flag = 0;
					RET_flag = 0;
				end

				5'b01111: begin // JMPCbi
					Mini_ALU_op = 1;
					Mini_ALU_v1 = PC_pos;
					Mini_ALU_v2 = immediate[15:0];
					if (t_register_value >= 1)
						JMP_flag = 1;
					else
						JMP_flag = 0;

					CALL_flag = 0;
					RET_flag = 0;
				end

				5'b10000: begin // CALL
					Mini_ALU_op = 0;
					Mini_ALU_v1 = f_register_value;
					Mini_ALU_v2 = 32'b0;
					CALL_flag = 1;
					RET_flag = 0;
					JMP_flag = 0;
				end

				5'b10001: begin // CALLi
					Mini_ALU_op = 0;
					Mini_ALU_v1 = immediate[15:0];
					Mini_ALU_v2 = 32'b0;
					CALL_flag = 1;
					RET_flag = 0;
					JMP_flag = 0;
				end

				5'b10010: begin // RET
					Mini_ALU_op = 0;
					Mini_ALU_v1 = f_register_value;
					Mini_ALU_v2 = 32'b0;
					JMP_flag = 0;
					CALL_flag = 0;
					RET_flag = 1;
				end

				5'b11000: begin // HALT
					Mini_ALU_op = 0;
					Mini_ALU_v1 = PC_pos;
					Mini_ALU_v2 = 32'b0;
					JMP_flag = 1;
					CALL_flag = 0;
					RET_flag = 0;
				end
				
				default: begin
					JMP_flag = 0;
					Mini_ALU_op = 0;
					Mini_ALU_v1 = 0;
					Mini_ALU_v2 = 0;
					CALL_flag = 0;
					RET_flag = 0;
				end
			
			endcase
		end else begin
			JMP_flag = 0;
			Mini_ALU_op = 0;
			Mini_ALU_v1 = 0;
			Mini_ALU_v2 = 0;
			CALL_flag = 0;
			RET_flag = 0;
		end
	end

endmodule
