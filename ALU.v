module ALU(
	input ALU_ENB,
	input [4:0] ALU_op,
	input signed [31:0] ALU_v1,
	input signed [31:0] ALU_v2,
	output reg signed [31:0] ALU_out
);

	always@(*) begin
		if (ALU_ENB) begin
			case(ALU_op)
				(5'b00001): begin // ADD
					ALU_out = ALU_v1 + ALU_v2;
				end
				
				(5'b00010): begin // SUB
					ALU_out = ALU_v1 - ALU_v2;
				end
				
				(5'b00011): begin // MULT
					ALU_out = ALU_v1 * ALU_v2;
				end
				
				(5'b00100): begin // DIV
					ALU_out = ALU_v1 / ALU_v2;
				end
				
				(5'b00101): begin // REM
					ALU_out = ALU_v1 % ALU_v2;
				end
				
				(5'b00110): begin // ABS
					ALU_out = ALU_v1 / ALU_v2;
				end

				(5'b00111): begin // NOT
					ALU_out = ~ALU_v1;
				end
				
				(5'b01000): begin // AND
					ALU_out = ALU_v1 & ALU_v2;
				end
				
				(5'b01001): begin // NAND
					ALU_out = !(ALU_v1 & ALU_v2);
				end
				
				(5'b01010): begin // OR
					ALU_out = ALU_v1 | ALU_v2;
				end
				
				(5'b01011): begin // NOR
					ALU_out = !(ALU_v1 | ALU_v2);
				end
				
				(5'b01100): begin // XOR
					ALU_out = ALU_v1 ^ ALU_v2;
				end
				
				(5'b01101): begin // XNOR
					ALU_out = !(ALU_v1 ^ ALU_v2);
				end
				
				(5'b10000): begin // SET
					if (ALU_v1 == ALU_v2)
						ALU_out = 1;
					else
						ALU_out = 0;
				end
				
				(5'b10001): begin // SLT
					if (ALU_v1 < ALU_v2)
						ALU_out = 1;
					else
						ALU_out = 0;
				end
				
				(5'b10010): begin // SGT
					if (ALU_v1 > ALU_v2)
						ALU_out = 1;
					else
						ALU_out = 0;
				end
				
				(5'b10011): begin // SDT
					if (ALU_v1 == ALU_v2)
						ALU_out = 0;
					else
						ALU_out = 1;
				end
				
				(5'b10101): begin // SLET
					if (ALU_v1 <= ALU_v2)
						ALU_out = 1;
					else
						ALU_out = 0;
				end
				
				(5'b10110): begin // SGET
					if (ALU_v1 >= ALU_v2)
						ALU_out = 1;
					else
						ALU_out = 0;
				end
				
				
				default: ALU_out = 32'b0;

			endcase
		end else begin
			ALU_out = 32'b0;
		end
	end


endmodule
