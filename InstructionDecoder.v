module InstructionDecoder (
	input [31:0] ID_instruction,
	output reg [2:0] ID_type,
	output reg [4:0] ID_func,
	output reg [7:0] f_register_code,
	output reg [7:0] s_register_code,
	output reg [7:0] t_register_code,
	output reg [23:0] immediate
);
	
	always@(ID_instruction) begin
		
		case(ID_instruction[31:29])
		
			// Aritmetic & Logic UNIT [1]
			(3'b010): begin
				t_register_code = ID_instruction[23:16];
				s_register_code = ID_instruction[15:8];
				f_register_code = ID_instruction[7:0];
			end
		
			// Aritmetic & Logic UNIT [2]
			(3'b011): begin
				t_register_code = ID_instruction[23:16];
				s_register_code = ID_instruction[15:8];
				f_register_code = ID_instruction[7:0];
			end
		
			// Direct Memory Access ( DMA )
		
			(3'b100): begin
				t_register_code = ID_instruction[23:16];
				s_register_code = ID_instruction[15:8];
				f_register_code = ID_instruction[7:0];
			end
		
			// Stacks ( STACK )
		
			(3'b001): begin
				t_register_code = ID_instruction[23:16];
				s_register_code = ID_instruction[15:8];
				f_register_code = ID_instruction[7:0];
			end
		
			// Program ( JMP )
		
			(3'b111): begin
				t_register_code = ID_instruction[23:16];
				s_register_code = ID_instruction[15:8];
				f_register_code = ID_instruction[7:0];
			end
		
			default: begin
				f_register_code = 8'b0;
				s_register_code = 8'b0;
				t_register_code = 8'b0;
			end
		
		endcase
		
		ID_type = ID_instruction[31:29];
		ID_func = ID_instruction[28:24];
		immediate = ID_instruction[23:0];
	end

endmodule
	
	