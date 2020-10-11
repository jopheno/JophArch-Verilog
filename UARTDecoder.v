module UARTDecoder(
	input UART_ENB,
	input [31:0] DMA_current_instruction,
	input [31:0] f_register_value,
	input [31:0] s_register_value,
	input [31:0] t_register_value,
	input [23:0] immediate,
	output reg UART_channel,
	output reg [2:0] UART_instr,
	output reg [7:0] UART_code_value,
	output reg [31:0] UART_write_value
);

always@(*) begin
	if (UART_ENB) begin
			case (DMA_current_instruction[28:24])
			
				5'b00000: begin // NOP
					UART_instr = 3'b000;
					UART_code_value = 8'b0;
					UART_write_value = 32'b0;
					UART_channel = 0;
				end
			
				5'b00001: begin // ATELL
					UART_instr = 3'b001;
					UART_code_value = DMA_current_instruction[23:16];
					UART_write_value = 32'b0;
					UART_channel = 0;
				end
			
				5'b00010: begin // AREAD
					UART_instr = 3'b010;
					UART_code_value = DMA_current_instruction[23:16];
					UART_write_value = 32'b0;
					UART_channel = 0;
				end
			
				5'b00011: begin // AWRITEi
					UART_instr = 3'b011;
					UART_code_value = 8'b0;
					UART_write_value = {24'b0, immediate[7:0]};
					UART_channel = 0;
				end
			
				5'b00100: begin // AWRITE
					UART_instr = 3'b011;
					UART_code_value = 8'b0;
					UART_write_value = {24'b0, f_register_value[7:0]};
					UART_channel = 0;
				end
			
				5'b00101: begin // ABAUDSET
					UART_instr = 3'b100;
					UART_code_value = 8'b0;
					UART_write_value = f_register_value[31:0];
					UART_channel = 0;
				end
			
				5'b10001: begin // BTELL
					UART_instr = 3'b001;
					UART_code_value = DMA_current_instruction[23:16];
					UART_write_value = 32'b0;
					UART_channel = 1;
				end
			
				5'b10010: begin // BREAD
					UART_instr = 3'b010;
					UART_code_value = DMA_current_instruction[23:16];
					UART_write_value = 32'b0;
					UART_channel = 1;
				end
			
				5'b10011: begin // BWRITEi
					UART_instr = 3'b011;
					UART_code_value = 8'b0;
					UART_write_value = {24'b0, immediate[7:0]};
					UART_channel = 1;
				end
			
				5'b10100: begin // BWRITE
					UART_instr = 3'b011;
					UART_code_value = 8'b0;
					UART_write_value = {24'b0, f_register_value[7:0]};
					UART_channel = 1;
				end
			
				5'b10101: begin // BBAUDSET
					UART_instr = 3'b100;
					UART_code_value = 8'b0;
					UART_write_value = f_register_value[31:0];
					UART_channel = 1;
				end

			
				5'b01001: begin // ADEBUG1
					UART_instr = 3'b101;
					UART_code_value = DMA_current_instruction[23:16];
					UART_write_value = 32'b0;
					UART_channel = 1;
				end
			
				5'b01010: begin // ADEBUG2
					UART_instr = 3'b110;
					UART_code_value = DMA_current_instruction[23:16];
					UART_write_value = 32'b0;
					UART_channel = 1;
				end
			
				5'b11001: begin // BDEBUG1
					UART_instr = 3'b101;
					UART_code_value = DMA_current_instruction[23:16];
					UART_write_value = 32'b0;
					UART_channel = 1;
				end
			
				5'b11010: begin // BDEBUG2
					UART_instr = 3'b110;
					UART_code_value = DMA_current_instruction[23:16];
					UART_write_value = 32'b0;
					UART_channel = 1;
				end

				default: begin
					UART_instr = 3'b000;
					UART_code_value = 8'b0;
					UART_write_value = 32'b0;
					UART_channel = 0;
				end
			endcase
	end else begin
		UART_instr = 3'b000;
		UART_code_value = 8'b0;
		UART_write_value = 8'b0;
		UART_channel = 0;
	end
end

endmodule
	