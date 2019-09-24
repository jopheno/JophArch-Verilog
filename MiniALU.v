module MiniALU(
	input JMP_ENB,
	input [3:0] M_ALU_op,
	input [31:0] M_ALU_v1,
	input [31:0] M_ALU_v2,
	output reg [31:0] M_ALU_out
);

	always@(*) begin
		if (JMP_ENB) begin
			case(M_ALU_op)
				(3'b000): begin // SUM
					M_ALU_out = M_ALU_v1 + M_ALU_v2;
				end
				
				(3'b001): begin // SUB
					M_ALU_out = M_ALU_v1 - M_ALU_v2;
				end
				
				(3'b010): begin // MULT
					M_ALU_out = M_ALU_v1 * M_ALU_v2;
				end
				
				(3'b011): begin // DIV
					M_ALU_out = M_ALU_v1 / M_ALU_v2;
				end
				
				(3'b100): begin // AND
					M_ALU_out = M_ALU_v1 & M_ALU_v2;
				end
				
				(3'b101): begin // OR
					M_ALU_out = M_ALU_v1 | M_ALU_v2;
				end
				
				(3'b110): begin // XOR
					M_ALU_out = M_ALU_v1 ^ M_ALU_v2;
				end
				
				
				default: M_ALU_out = 32'b0;

			endcase
		end else begin
			M_ALU_out = 32'b0;
		end
	end


endmodule
