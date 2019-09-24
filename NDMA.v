module NDMA (
	input init_flag,
	input clock,
	input DMA_Apply_Btn,
	input DMA_ENB,
	input [31:0] DMA_current_instruction,
	input [31:0] f_register_value,
	input [31:0] s_register_value,
	input [31:0] t_register_value,
	input [21:0] IO_in,

	input [31:0] RAM_data,
	input [15:0] r_esp,

	output reg [57:0] IO_out,
	output reg DMA_write_back_flag,
	output reg [7:0] DMA_write_back_code,
	output reg [31:0] DMA_write_back_value,

	output reg RAM_write_flag,
	output reg [15:0] RAM_write_addr,
	output reg [31:0] RAM_write_data,

	output reg DMA_stack_flag,
	output reg [15:0] DMA_stack_data
);

initial begin
	integer i = 0;
	
	for (i = 0; i <= 57; i = i +1) begin
		IO_out[i] = 0;
   end

	RAM_write_flag = 0;
	RAM_write_data = 8'b0;
	RAM_write_addr = 32'b0;
	Input_Queue_WritePos = 0;
	Input_Queue_ReadPos = 0;
	Input_Queue_ReadAmount = 0;
	Input_Queue_WriteAmount = 0;

end


// OUTPUT Explanation
/*
IO_out[17:0] => Red LEDs [16 Red LEDs]
IO_out[25:18] => Green LEDs [8 Green LEDs]

IO_out[33:26] => Value at first display (from LEFT) [HEX6 && HEX7]
IO_out[41:34] => Value at second display (from LEFT) [HEX4 && HEX5]
IO_out[57:42] => Value at third display (from LEFT) [HEX1 && HEX2 && HEX3]
*/

	reg [21:0] Input_Queue [32];
	reg [4:0] Input_Queue_WritePos = 0;
	reg [4:0] Input_Queue_ReadPos = 0;
	reg [15:0] Input_Queue_ReadAmount = 0;
	reg [15:0] Input_Queue_WriteAmount = 0;

	always@(negedge clock) begin
		if (!init_flag) begin
			IO_out[57:0] = 58'b0;
		end

		if (DMA_ENB) begin

		case (DMA_current_instruction[28:24])
			
				(5'b01001): begin // RAI - READ ALL INPUTS
					if (Input_Queue_WriteAmount > Input_Queue_ReadAmount) begin
						Input_Queue_ReadPos = Input_Queue_ReadPos + 1;
						Input_Queue_ReadAmount = Input_Queue_ReadAmount + 1;
					end
				end
			
				(5'b01010): begin // RI - READ INPUT
					if (Input_Queue_WriteAmount > Input_Queue_ReadAmount) begin
						Input_Queue_ReadPos = Input_Queue_ReadPos + 1;
						Input_Queue_ReadAmount = Input_Queue_ReadAmount + 1;
					end
				end
				(5'b00001): begin // SAO - Set all outputs

					
					IO_out[25:0] = {6'b0, f_register_value};
				end
			
				(5'b00010): begin // SO - Set Output -> Set value from a single output depending on the value passed through the last 8 bits of register value

					
					if (DMA_current_instruction[23:16] == 8'b10000001) begin // USED TO SET DISPLAY 1 [8bits]
						IO_out[33:26] = f_register_value[7:0];
						
					end else if (DMA_current_instruction[23:16] == 8'b10000010) begin // USED TO SET DISPLAY 2 [8bits]
						IO_out[41:34] = f_register_value[7:0];
						
					end else if (DMA_current_instruction[23:16] == 8'b10000011) begin // USED TO SET DISPLAY 3 [16bits]
						IO_out[57:42] = f_register_value[15:0];
						
					end else begin
						IO_out[DMA_current_instruction[23:16]] = f_register_value[0];
					end
					
				end
			
				(5'b00011): begin // SOi - Set Output Immediate -> Set value at third register IMMEDIATE position to first register IMMEDIATE value [0]
					
					case (DMA_current_instruction[23:16])
						(8'b10000001): IO_out[33:26] = DMA_current_instruction[7:0]; // USED TO SET DISPLAY 1 [8bits]
						(8'b10000010): IO_out[41:34] = DMA_current_instruction[7:0]; // USED TO SET DISPLAY 2 [8bits]
						(8'b10000011): IO_out[57:42] = DMA_current_instruction[15:0]; // USED TO SET DISPLAY 3 [16bits]
						default: IO_out[DMA_current_instruction[23:16]] = DMA_current_instruction[0];
					endcase

				end
			
				(5'b01100): begin // PAUSE
					if (Input_Queue_WriteAmount > Input_Queue_ReadAmount) begin
						Input_Queue_ReadPos = Input_Queue_ReadPos + 1;
						Input_Queue_ReadAmount = Input_Queue_ReadAmount + 1;
					end
				end
		endcase

		end

	end

	always@(*) begin
		if (!init_flag) begin
			//IO_out[57:0] = 58'b0;

			RAM_write_flag = 0;
			RAM_write_data = 8'b0;
			RAM_write_addr = 32'b0;
			
			DMA_stack_flag = 0;
			DMA_stack_data = 16'b0;
		end

		if (DMA_ENB) begin
			case (DMA_current_instruction[28:24])
			
				(5'b01001): begin // RAI - READ ALL INPUTS
					if (Input_Queue_WriteAmount > Input_Queue_ReadAmount) begin
						DMA_write_back_flag = 1;
						DMA_write_back_code = DMA_current_instruction[23:16];
						DMA_write_back_value = {10'b0, Input_Queue[Input_Queue_ReadPos]};
						//Input_Queue_ReadPos = Input_Queue_ReadPos + 1;
						//Input_Queue_ReadAmount = Input_Queue_ReadAmount + 1;
						RAM_write_flag = 0;
						RAM_write_addr = 0;
						RAM_write_data = 0;
						DMA_stack_flag = 0;
						DMA_stack_data = 16'b0;
					end else begin
						DMA_write_back_flag = 0;
						DMA_write_back_code = 0;
						DMA_write_back_value = 0;
						RAM_write_flag = 0;
						RAM_write_addr = 0;
						RAM_write_data = 0;
						DMA_stack_flag = 0;
						DMA_stack_data = 16'b0;
					end
				end
			
				(5'b01010): begin // RI - READ INPUT
					if (Input_Queue_WriteAmount > Input_Queue_ReadAmount) begin
						DMA_write_back_flag = 1;
						DMA_write_back_code = DMA_current_instruction[23:16];
						if (DMA_current_instruction[7:0] == 8'b10000000) // 8 bits
							DMA_write_back_value = {24'b0, Input_Queue[Input_Queue_ReadPos][7:0]};
						else if (DMA_current_instruction[7:0] == 8'b10000001) // 16 bits
							DMA_write_back_value = {16'b0, Input_Queue[Input_Queue_ReadPos][15:0]};
						else
							DMA_write_back_value = {31'b0, Input_Queue[Input_Queue_ReadPos][DMA_current_instruction[7:0]]};

						//Input_Queue_ReadPos = Input_Queue_ReadPos + 1;
						//Input_Queue_ReadAmount = Input_Queue_ReadAmount + 1;
						RAM_write_flag = 0;
						RAM_write_addr = 0;
						RAM_write_data = 0;
						
						DMA_stack_flag = 0;
						DMA_stack_data = 16'b0;
					end else begin
						DMA_write_back_flag = 0;
						DMA_write_back_code = 0;
						DMA_write_back_value = 0;
						RAM_write_flag = 0;
						RAM_write_addr = 0;
						RAM_write_data = 0;
						
						DMA_stack_flag = 0;
						DMA_stack_data = 16'b0;
					end
				end
			
				(5'b01011): begin // GIA - GET INPUTS AMOUNT
					DMA_write_back_flag = 1;
					DMA_write_back_code = DMA_current_instruction[23:16];
					DMA_write_back_value = (Input_Queue_WriteAmount-Input_Queue_ReadAmount);
					RAM_write_flag = 0;
					RAM_write_addr = 0;
					RAM_write_data = 0;
					
					DMA_stack_flag = 0;
					DMA_stack_data = 16'b0;
				end
			
				(5'b01100): begin // PAUSE - Similar to GIA, this instruction auto-read an input value if there is any available inputs to read.
					DMA_write_back_flag = 1;
					DMA_write_back_code = DMA_current_instruction[23:16];
					DMA_write_back_value = (Input_Queue_WriteAmount-Input_Queue_ReadAmount);
					RAM_write_flag = 0;
					RAM_write_addr = 0;
					RAM_write_data = 0;
					
					DMA_stack_flag = 0;
					DMA_stack_data = 16'b0;
				end
			
				/*(5'b00001): begin // SAO - Set all outputs
					DMA_write_back_flag = 0;
					DMA_write_back_code = 0;
					DMA_write_back_value = 0;
					RAM_write_flag = 0;
					RAM_write_addr = 0;
					RAM_write_data = 0;
					
					IO_out[25:0] = {6'b0, f_register_value};
				end
			
				(5'b00010): begin // SO - Set Output -> Set value from a single output depending on the value passed through the last 8 bits of register value
					DMA_write_back_flag = 0;
					DMA_write_back_code = 0;
					DMA_write_back_value = 0;
					RAM_write_flag = 0;
					RAM_write_addr = 0;
					RAM_write_data = 0;
					
					if (DMA_current_instruction[23:16] == 8'b10000001) begin // USED TO SET DISPLAY 1 [8bits]
						IO_out[33:26] = f_register_value[7:0];
						
					end else if (DMA_current_instruction[23:16] == 8'b10000010) begin // USED TO SET DISPLAY 2 [8bits]
						IO_out[41:34] = f_register_value[7:0];
						
					end else if (DMA_current_instruction[23:16] == 8'b10000011) begin // USED TO SET DISPLAY 3 [16bits]
						IO_out[57:42] = f_register_value[15:0];
						
					end else begin
						IO_out[DMA_current_instruction[23:16]] = f_register_value[0];
					end
					
				end
			
				(5'b00011): begin // SOi - Set Output Immediate -> Set value at third register IMMEDIATE position to first register IMMEDIATE value [0]
					DMA_write_back_flag = 0;
					DMA_write_back_code = 0;
					DMA_write_back_value = 0;
					RAM_write_flag = 0;
					RAM_write_addr = 0;
					RAM_write_data = 0;
					
					case (DMA_current_instruction[23:16])
						(8'b10000001): IO_out[33:26] = DMA_current_instruction[7:0]; // USED TO SET DISPLAY 1 [8bits]
						(8'b10000010): IO_out[41:34] = DMA_current_instruction[7:0]; // USED TO SET DISPLAY 2 [8bits]
						(8'b10000011): IO_out[57:42] = DMA_current_instruction[15:0]; // USED TO SET DISPLAY 3 [16bits]
						default: IO_out[DMA_current_instruction[23:16]] = DMA_current_instruction[0];
					endcase

				end*/
			
				/*(5'b10000): begin // MLB - Memory Load Byte -> Load byte from memory
				
					DMA_write_back_flag = 0;
					DMA_write_back_code = 0;
					DMA_write_back_value = 0;
					RAM_write_flag = 0;
					RAM_write_data = 0;

					//RAM_write_addr = DMA_current_instruction[15:0]; // Immediate [24bits] => Memory Address

				end*/
				
				(5'b10010): begin // LOADi - Memory Read Byte -> Read byte from memory
				
					DMA_write_back_flag = 1;
					DMA_write_back_code = DMA_current_instruction[23:16];
					DMA_write_back_value = RAM_data;
					RAM_write_flag = 0;					RAM_write_data = 0;

					RAM_write_addr = DMA_current_instruction[15:0]; // Immediate [24bits] => Memory Address
					
					DMA_stack_flag = 0;
					DMA_stack_data = 16'b0;

				end

				
				(5'b10011): begin // STOREi - Memory Save Byte -> Save byte in memory
				
					DMA_write_back_flag = 0;
					DMA_write_back_code = 0;
					DMA_write_back_value = 0;

					RAM_write_flag = 1;
					RAM_write_data = t_register_value[31:0];
					RAM_write_addr = DMA_current_instruction[15:0]; // Immediate [24bits] => Memory Address
					
					DMA_stack_flag = 0;
					DMA_stack_data = 16'b0;

				end
				
				(5'b10000): begin // LOAD - Memory Read Byte -> Read byte from memory
				
					DMA_write_back_flag = 1;
					DMA_write_back_code = DMA_current_instruction[23:16];
					DMA_write_back_value = RAM_data;
					RAM_write_flag = 0;
					RAM_write_data = 0;

					RAM_write_addr = f_register_value[15:0]; // Immediate [24bits] => Memory Address
					
					DMA_stack_flag = 0;
					DMA_stack_data = 16'b0;

				end

				
				(5'b10001): begin // STORE - Memory Save Byte -> Save byte in memory
				
					DMA_write_back_flag = 0;
					DMA_write_back_code = 0;
					DMA_write_back_value = 0;

					RAM_write_flag = 1;
					RAM_write_data = t_register_value[31:0];
					RAM_write_addr = f_register_value[15:0]; // Immediate [24bits] => Memory Address
					
					DMA_stack_flag = 0;
					DMA_stack_data = 16'b0;

				end
				
				(5'b10100): begin // POP
					integer aux;
					
					aux = r_esp[15:0] + 1;
				
					DMA_write_back_flag = 1;
					DMA_write_back_code = DMA_current_instruction[23:16];
					DMA_write_back_value = RAM_data;
					
					DMA_stack_flag = 1;
					DMA_stack_data = aux;
					
					RAM_write_flag = 0;
					RAM_write_data = 0;

					RAM_write_addr = aux;

				end

				
				(5'b10101): begin // PUSH
					integer aux;
					
					aux = r_esp[15:0] - 1;
				
					DMA_write_back_flag = 0;
					DMA_write_back_code = 0;
					DMA_write_back_value = 0;
					
					DMA_stack_flag = 1;
					DMA_stack_data = aux;

					RAM_write_data = f_register_value[31:0];
					RAM_write_addr = r_esp[15:0];
					RAM_write_flag = 1;

				end

				
				(5'b10110): begin // SP
				
					DMA_write_back_flag = 0;
					DMA_write_back_code = 0;
					DMA_write_back_value = 0;
					
					DMA_stack_flag = 1;
					DMA_stack_data = f_register_value[15:0];

					RAM_write_flag = 0;
					RAM_write_data = 32'b0;
					RAM_write_addr = 16'b0;

				end
				default: begin
					DMA_write_back_flag = 0;
					DMA_write_back_code = 0;
					DMA_write_back_value = 0;
					
					RAM_write_flag = 0;
					RAM_write_addr = 0;
					RAM_write_data = 0;

					DMA_stack_flag = 0;
					DMA_stack_data = 16'b0;
				end

			endcase
		end else begin
			DMA_write_back_flag = 0;
			DMA_write_back_code = 0;
			DMA_write_back_value = 0;
			
			RAM_write_flag = 0;
			RAM_write_addr = 0;
			RAM_write_data = 0;

			DMA_stack_flag = 0;
			DMA_stack_data = 16'b0;
		end
	end
	
	always@(negedge DMA_Apply_Btn) begin
	
		if (init_flag) begin
			Input_Queue[Input_Queue_WritePos] = IO_in;
			Input_Queue_WritePos = Input_Queue_WritePos + 1;
			Input_Queue_WriteAmount = Input_Queue_WriteAmount + 1;
		end
	end
	
endmodule
