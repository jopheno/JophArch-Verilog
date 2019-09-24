module NStackDecoder(
	input init,
	input STACK_ENB,
	input [31:0] DMA_current_instruction,
	input [31:0] f_register_value,
	input [31:0] s_register_value,
	input [31:0] t_register_value,
	input [23:0] immediate,
	
	input [31:0] STACK_TOP,
	
	input [15:0] STACK_AMOUNT,

	output reg STACK_pop_flag,

	output reg STACK_write_back_flag,
	output reg [7:0] STACK_write_back_code,
	output reg [31:0] STACK_write_back_value

);

	// STACK REGISTER
	parameter STACK_TOP_REG = 8'b00100000;

	initial begin
		STACK_pop_flag = 1'b0;
		STACK_write_back_flag = 1'b0;
		STACK_write_back_code = 8'b0;
		STACK_write_back_value = 32'b0;
	end

	always@(*) begin

		if (STACK_ENB) begin
			case (DMA_current_instruction[28:24])
				
				(5'b00001): begin // POP
						STACK_pop_flag = 1;

						STACK_write_back_flag = 1;
						STACK_write_back_code = immediate[23:16];
						STACK_write_back_value = STACK_TOP;

				end
				
				(5'b00010): begin // PUSH
						STACK_pop_flag = 0;

						STACK_write_back_flag = 1;
						STACK_write_back_code = STACK_TOP_REG;
						STACK_write_back_value = f_register_value;

				end
				
				(5'b00011): begin // PUSHi
						STACK_pop_flag = 0;

						STACK_write_back_flag = 1;
						STACK_write_back_code = STACK_TOP_REG;
						STACK_write_back_value = immediate[23:0];

				end
				
				(5'b00100): begin // GSA - Get Stack Amount
						STACK_write_back_flag = 1;
						STACK_write_back_code = immediate[23:16];
						STACK_pop_flag = 0;
						
						STACK_write_back_value = STACK_AMOUNT;

				end
			
				default: begin
					STACK_write_back_flag = 0;
					STACK_write_back_code = 0;
					STACK_write_back_value = 0;
					STACK_pop_flag = 0;
				end
			endcase
		 end else begin
				STACK_write_back_flag = 0;
				STACK_write_back_code = 0;
				STACK_write_back_value = 0;
				STACK_pop_flag = 0;
		end
	end

endmodule
