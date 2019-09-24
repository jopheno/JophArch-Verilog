module ALUDecoder(
	input ALU_ENB,
	input [31:0] DMA_current_instruction,
	input [31:0] f_register_value,
	input [31:0] s_register_value,
	input [31:0] t_register_value,
	input [23:0] immediate,
	output reg [4:0] ALU_op,
	output reg signed [31:0] ALU_v1,
	output reg signed [31:0] ALU_v2,

	output reg ALU_write_back_flag,
	output reg [7:0] ALU_write_back_code
);

	always@(*) begin
		if (ALU_ENB) begin
			if (DMA_current_instruction[31:29] == 3'b010) begin
				case (DMA_current_instruction[28:24])
					
					(5'b00001): begin // ADD
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b00001;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end
					
					(5'b00010): begin // SUB
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b00010;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end
					
					(5'b00011): begin // MULT
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b00011;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end
					
					(5'b00100): begin // DIV
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b00100;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end

					(5'b00101): begin // REM
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b00101;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end

					(5'b00110): begin // ABS
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b00110;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end

					(5'b00111): begin // NOT
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b00111;
						ALU_v1 = f_register_value;
						ALU_v2 = 0;
					end

					(5'b01000): begin // AND
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b01000;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end

					(5'b01001): begin // NAND
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b01001;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end

					(5'b01010): begin // OR
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b01010;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end

					(5'b01011): begin // NOR
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b01011;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end

					(5'b01100): begin // XOR
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b01100;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end

					(5'b01101): begin // XNOR
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b01101;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end

			





					(5'b10000): begin // SET
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b10000;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end

					(5'b10001): begin // SLT
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b10001;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end

					(5'b10010): begin // SGT
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b10010;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end

					(5'b10011): begin // SDT
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b10011;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end

					(5'b10101): begin // SLET
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b10101;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end

					(5'b10110): begin // SGET
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b10110;
						ALU_v1 = f_register_value;
						ALU_v2 = s_register_value;
					end
					
					default: begin
						ALU_write_back_flag = 0;
						ALU_write_back_code = 8'b0;
						ALU_op = 0;
						ALU_v1 = 32'b0;
						ALU_v2 = 32'b0;
					end

				endcase
			end else begin
			
				case (DMA_current_instruction[28:24])

					
					(5'b00001): begin // ADDi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b00001;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end

					
					(5'b00010): begin // SUBi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b00010;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end

					
					(5'b00011): begin // MULTi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b00011;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end

					
					(5'b00100): begin // DIVi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b00100;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end

					
					(5'b00101): begin // REMi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b00101;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end

					
					(5'b00110): begin // ABSi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b00110;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end

					
					(5'b00111): begin // NOTi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b00111;
						ALU_v1 = immediate[15:0];
						ALU_v2 = 0;
					end

					
					(5'b01000): begin // ANDi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b01000;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end

					
					(5'b01001): begin // NANDi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b01001;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end

					
					(5'b01010): begin // ORi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b01010;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end
					
					(5'b01011): begin // NORi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b01011;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end
					
					(5'b01100): begin // XORi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b01100;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end
					
					(5'b01101): begin // XNORi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b01101;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end





					
					(5'b10000): begin // SETi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b10000;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end
					
					(5'b10001): begin // SLTi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b10001;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end
					
					(5'b10010): begin // SGTi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b10010;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end
					
					(5'b10011): begin // SDTi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b10011;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end
					
					(5'b10101): begin // SLETi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b10101;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end
					
					(5'b10110): begin // SGETi
						ALU_write_back_flag = 1;
						ALU_write_back_code = immediate[23:16];
						ALU_op = 5'b10110;
						ALU_v1 = t_register_value;
						ALU_v2 = immediate[15:0];
					end
					
					default: begin
						ALU_write_back_flag = 0;
						ALU_write_back_code = 8'b0;
						ALU_op = 0;
						ALU_v1 = 32'b0;
						ALU_v2 = 32'b0;
					end

				endcase
			end
		end else begin
			ALU_write_back_flag = 0;
			ALU_write_back_code = 8'b0;
			ALU_op = 0;
			ALU_v1 = 32'b0;
			ALU_v2 = 32'b0;
		end
	end

endmodule
