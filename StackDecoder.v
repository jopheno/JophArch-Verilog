module StackDecoder(
	input init,
	input STACK_ENB,
	input [31:0] DMA_current_instruction,
	input [31:0] f_register_value,
	input [31:0] s_register_value,
	input [31:0] t_register_value,
	input [23:0] immediate,
	
	input [7:0] STACK_TOP_A,
	input [15:0] STACK_TOP_B,
	input [31:0] STACK_TOP_C,
	
	input [7:0] STACK_AMOUNT_A,
	input [7:0] STACK_AMOUNT_B,
	input [7:0] STACK_AMOUNT_C,
	
	output reg [1:0] STACK_pop_id,
	output reg STACK_pop_flag,

	output reg STACK_write_back_flag,
	output reg [7:0] STACK_write_back_code,
	output reg [31:0] STACK_write_back_value

);

	// STACK REGISTERs
	parameter A = 8'b00100000;
	parameter B = 8'b01000000;
	parameter C = 8'b01100000;

	always@(*) begin

		if (!init) begin
			STACK_pop_flag = 0;
			STACK_pop_id = 0;
			STACK_write_back_flag = 0;
			STACK_write_back_code = 0;
			STACK_write_back_value = 0;
		end

		if (STACK_ENB) begin
			case (DMA_current_instruction[26:24])
				
				(3'b001): begin // POP
					if (DMA_current_instruction[28:27] > 0) begin
						STACK_write_back_flag = 1;
						STACK_write_back_code = immediate[23:16];
						STACK_pop_flag = 1;
						STACK_pop_id = DMA_current_instruction[28:27];
						
						case (DMA_current_instruction[28:27])
						
							(2'b01): STACK_write_back_value = STACK_TOP_A;
							(2'b10): STACK_write_back_value = STACK_TOP_B;
							(2'b11): STACK_write_back_value = STACK_TOP_C;

							default: STACK_write_back_value = STACK_TOP_A;
						endcase

					end else begin
						STACK_write_back_flag = 0;
						STACK_write_back_code = 0;
						STACK_write_back_value = 0;
						STACK_pop_id = 0;
						STACK_pop_flag = 0;
					end

				end
				
				(3'b010): begin // PUSH
					if (DMA_current_instruction[28:27] > 0) begin
						STACK_write_back_flag = 1;
						STACK_pop_id = DMA_current_instruction[28:27];
						STACK_pop_flag = 0;
						STACK_write_back_value = f_register_value;
						
						case (DMA_current_instruction[28:27])
						
							(2'b01): STACK_write_back_code = A;
							(2'b10): STACK_write_back_code = B;
							(2'b11): STACK_write_back_code = C;

							default: STACK_write_back_code = A;
						endcase

					end else begin
						STACK_write_back_flag = 0;
						STACK_write_back_code = 0;
						STACK_write_back_value = 0;
						STACK_pop_id = 0;
						STACK_pop_flag = 0;
					end

				end
				
				(3'b011): begin // PUSHi
					if (DMA_current_instruction[28:27] > 0) begin
						STACK_write_back_flag = 1;
						STACK_pop_id = DMA_current_instruction[28:27];
						STACK_pop_flag = 0;
						STACK_write_back_value = immediate[23:0];
						
						
						case (DMA_current_instruction[28:27])
						
							(2'b01): STACK_write_back_code = A;
							(2'b10): STACK_write_back_code = B;
							(2'b11): STACK_write_back_code = C;

							default: STACK_write_back_code = A;
						endcase

					end else begin
						STACK_write_back_flag = 0;
						STACK_write_back_code = 0;
						STACK_write_back_value = 0;
						STACK_pop_id = 0;
						STACK_pop_flag = 0;
					end

				end
				
				(3'b100): begin // GSA - Get Stack Amount
					if (DMA_current_instruction[28:27] > 0) begin
						STACK_write_back_flag = 1;
						STACK_write_back_code = immediate[23:16];
						STACK_pop_flag = 0;
						STACK_pop_id = DMA_current_instruction[28:27];
						
						case (DMA_current_instruction[28:27])
						
							(2'b01): STACK_write_back_value = STACK_AMOUNT_A;
							(2'b10): STACK_write_back_value = STACK_AMOUNT_B;
							(2'b11): STACK_write_back_value = STACK_AMOUNT_C;

							default: STACK_write_back_value = STACK_AMOUNT_A;
						endcase

					end else begin
						STACK_write_back_flag = 0;
						STACK_write_back_code = 0;
						STACK_write_back_value = 0;
						STACK_pop_id = 0;
						STACK_pop_flag = 0;
					end

				end
			
				default: begin
					STACK_write_back_flag = 0;
					STACK_write_back_code = 0;
					STACK_write_back_value = 0;
					STACK_pop_id = 0;
					STACK_pop_flag = 0;
				end
			endcase
		 end else begin
				STACK_write_back_flag = 0;
				STACK_write_back_code = 0;
				STACK_write_back_value = 0;
				STACK_pop_id = 0;
				STACK_pop_flag = 0;
		end
	end

endmodule
