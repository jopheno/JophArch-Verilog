module WriteController (

	input ALU_ENB,
	input ALU_write_back_flag,
	input [7:0] ALU_write_back_code,
	input [31:0] ALU_write_back_value,

	input STACK_ENB,
	input STACK_write_back_flag,
	input [7:0] STACK_write_back_code,
	input [31:0] STACK_write_back_value,

	input JMP_ENB,
	input JMP_write_back_flag,
	input [7:0] JMP_write_back_code,
	input [31:0] JMP_write_back_value,

	input DMA_ENB,
	input DMA_write_back_flag,
	input [7:0] DMA_write_back_code,
	input [31:0] DMA_write_back_value,

	input SCHED_ENB,
	input SCHED_write_back_flag,
	input [7:0] SCHED_write_back_code,
	input [31:0] SCHED_write_back_value,

	input UART_ENB,
	input UART_write_back_flag,
	input [7:0] UART_write_back_code,
	input [31:0] UART_write_back_value,
	
	output wire REG_write_back_flag,
	output wire [7:0] REG_write_back_code,
	output wire [31:0] REG_write_back_data
);

assign REG_write_back_flag = ( ALU_ENB == 1 )? ALU_write_back_flag : ( STACK_ENB == 1 )? STACK_write_back_flag : ( UART_ENB == 1 )? UART_write_back_flag : ( SCHED_ENB == 1 )? SCHED_write_back_flag : ( JMP_ENB == 1 )? JMP_write_back_flag : ( DMA_ENB == 1 )? DMA_write_back_flag : 1'b0;
assign REG_write_back_code = ( ALU_ENB == 1 )? ALU_write_back_code : ( STACK_ENB == 1 )? STACK_write_back_code : ( UART_ENB == 1 )? UART_write_back_code : ( SCHED_ENB == 1 )? SCHED_write_back_code : ( JMP_ENB == 1 )? JMP_write_back_code : ( DMA_ENB == 1 )? DMA_write_back_code : 8'b0;
assign REG_write_back_data = ( ALU_ENB == 1 )? ALU_write_back_value : ( STACK_ENB == 1 )? STACK_write_back_value : ( UART_ENB == 1 )? UART_write_back_value : ( SCHED_ENB == 1 )? SCHED_write_back_value : ( JMP_ENB == 1 )? JMP_write_back_value : ( DMA_ENB == 1 )? DMA_write_back_value : 32'b0;

endmodule
