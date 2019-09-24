module DMA(
	input clock, // Virtual_Clock
	input init_flag, // Flag that initializes the system
	input DMA_ENB,
	input [21:0] IO_in, // Input values
	output reg [25:0] IO_out, // Output register values
	input DMA_Apply_Btn, // Apply new combination of inputs
	// input [15:0] Instructions_Memory_ReadPos, // Program Counter
	input [31:0] DMA_current_instruction, // Instruction Readed
	input [31:0] f_register_value,
	input [31:0] s_register_value,
	input [31:0] t_register_value,
	output reg WB_FLAG,
	output reg [7:0] WB_POS,
	output reg [31:0] WB_VALUE,
	output reg [31:0] Input_Queue_Amount_READ,
	output reg [31:0] Input_Queue_Amount_WRITE
);

	initial begin
		Input_Queue_Amount_WRITE = 0;
		Input_Queue_Amount_READ = 0;
	end

	//input clock;
	//input init_flag;

	//input [21:0] IO_in; // 0-17 SWs; 18-21 Keys;
	//output reg [25:0] IO_out; // 0-7 GreenLEDS; 8-25;

	//input DMA_Apply_Btn;

	// Leitura combinacional dos valores das filas

	//input [15:0] Instructions_Memory_ReadPos; // Program Counter
	//output reg [31:0] DMA_current_instruction; // Current Instruction
	//output reg test = 0;
	//output reg [31:0] test2 = 0;

	// Implementaçao de Fila de entradas, e sinal que indicara se a pilha esta vazia.

	reg [21:0] Input_Queue [64];
	reg [5:0] Input_Queue_WritePos = 0;
	reg [5:0] Input_Queue_ReadPos = 0;
	reg [7:0] Input_Queue_Amount = 0;
	//reg [31:0] Input_Queue_Amount_READ = 0;
	//reg [31:0] Input_Queue_Amount_WRITE = 0;

	reg [25:0] Output_Queue [64];
	reg [5:0] Output_Queue_WritePos = 0;
	reg [5:0] Output_Queue_ReadPos = 0;
	reg [7:0] Output_Queue_Amount = 0;

	//reg [31:0] Instructions_Memory [256];
	//reg [7:0] Instructions_Memory_WritePos = 0;

	reg [7:0] Memory_Queue [128];
	reg [6:0] Memory_Queue_WritePos = 0;
	reg [6:0] Memory_Queue_ReadPos = 0;
	
	
	/*Instructions_Memory[0] = 32'b000_00000_000_00000_00000000_00000001;
	Instructions_Memory[1] = 32'b000_00000_000_00000_00000000_00000010;
	Instructions_Memory[2] = 32'b000_00000_000_00000_00000000_00000011;*/

	// TESTE DE SOMA, SUBTRACAO, MULTIPLICACAO, DIVISAO ! \\
	
	/*
	Instructions_Memory[0] = 32'b011_00001_10000000_00000000_00000001; // ADDi eax 1 => EAX = 1
	Instructions_Memory[1] = 32'b011_00010_10000000_00000000_00001011; // SUBi eax -11 => EAX = 10
	Instructions_Memory[2] = 32'b011_00011_10000000_00000000_00000010; // MULTi eax 2 => EAX = 20
	Instructions_Memory[3] = 32'b011_00100_10000000_00000000_00000010; // DIVi eax 2 => EAX = 10
	*/
	
	// TESTE DO JUMPC \\
	/*
	Soma 1 em ambos os valores e compara-os, inicialmente dará igual e ele aceitara o JMPC
	e voltara para a segunda instrucao somando um apenas no segundo registrador, logo a comparação agora
	será negada, e assim ele não aceitará mais o JMPC porque eax != ebx
	*/

	/*
	Instructions_Memory[0] = 32'b011_00001_10000000_00000000_00000001; // ADDi eax 1
	Instructions_Memory[1] = 32'b011_00001_10100000_00000000_00000001; // ADDi ebx 1
	Instructions_Memory[2] = 32'b010_10000_10100000_10100000_10000000; // SET ebx eax
	Instructions_Memory[3] = 32'b111_01101_10100000_00000000_00000001; // JUMPCi ebx 1
	*/
  
	always@(*) begin
	
		if (DMA_ENB) begin
		case (DMA_current_instruction[28:24])
		
			5'b01001: begin // Read all inputs
				WB_FLAG = 0;

				if (Input_Queue_Amount_WRITE - Input_Queue_Amount_READ > 0) begin
					WB_FLAG = 1;

					WB_POS = DMA_current_instruction[23:16]; // THIRD REGISTER CODE (IMMEDIATE)
					WB_VALUE[31:0] = 32'b0;
					WB_VALUE[21:0] = Input_Queue[Input_Queue_ReadPos];
					Input_Queue_ReadPos = Input_Queue_ReadPos + 1;
					Input_Queue_Amount_READ = Input_Queue_Amount_READ + 1;
				end
			end

			5'b01010: begin // Read especific input
				WB_FLAG = 0;

				if (Input_Queue_Amount_WRITE - Input_Queue_Amount_READ > 0) begin
					WB_FLAG = 1;

					WB_POS = DMA_current_instruction[23:16]; // THIRD REGISTER CODE (IMMEDIATE)
					WB_VALUE[31:0] = 32'b0;
					WB_VALUE[0] = Input_Queue[Input_Queue_ReadPos][DMA_current_instruction[7:0]];
					Input_Queue_ReadPos = Input_Queue_ReadPos + 1;
					Input_Queue_Amount_READ = Input_Queue_Amount_READ + 1;
				end
			end

			5'b01011: begin // Get available inputs amount
				WB_FLAG = 1;

				WB_POS = DMA_current_instruction[23:16]; // THIRD REGISTER CODE (IMMEDIATE)
				WB_VALUE[31:0] = 32'b0;
				WB_VALUE[7:0] = (Input_Queue_Amount_WRITE - Input_Queue_Amount_READ);
			end

			5'b00001: begin // Set All Outputs
				WB_FLAG = 0;

				Output_Queue[Output_Queue_WritePos] = f_register_value[25:0]; // FIRST REGISTER VALUE
				Output_Queue_WritePos = Output_Queue_WritePos + 1;
				Output_Queue_Amount = Output_Queue_Amount + 1;
			end

			5'b00010: begin // Set Output -> Set value at third register value position to first register value [0] (FIRST POSITION)
				WB_FLAG = 0;

				if (Output_Queue_Amount > 0) begin
					Output_Queue[Output_Queue_WritePos] = Output_Queue[Output_Queue_WritePos-1];
				end else begin
					Output_Queue[Output_Queue_WritePos] = IO_out;
				end
				Output_Queue[Output_Queue_WritePos][t_register_value] = f_register_value[0];
				Output_Queue_WritePos = Output_Queue_WritePos + 1;
			end

			5'b00011: begin // Set Output Immediate -> Set value at third register IMMEDIATE position to first register IMMEDIATE value [0]
				WB_FLAG = 0;

				if (Output_Queue_Amount > 0) begin
					Output_Queue[Output_Queue_WritePos] = Output_Queue[Output_Queue_WritePos-1];
				end else begin
					Output_Queue[Output_Queue_WritePos] = IO_out;
				end
				Output_Queue[Output_Queue_WritePos][DMA_current_instruction[23:16]] = DMA_current_instruction[0];
				Output_Queue_WritePos = Output_Queue_WritePos + 1;
			end
			
			default: begin WB_FLAG = 0; end

		endcase
		end else begin
			WB_FLAG = 0;
			WB_POS = 8'b0;
			WB_VALUE = 32'b0;
		end
	
		//DMA_current_instruction = Instructions_Memory[Instructions_Memory_ReadPos[7:0]];
	end
  
	always@(negedge clock) begin
	
		if (Output_Queue_ReadPos < Output_Queue_WritePos) begin
			IO_out = Output_Queue[Output_Queue_ReadPos];
			Output_Queue_ReadPos = Output_Queue_ReadPos + 1;
		end
	end
	
	always@(posedge DMA_Apply_Btn) begin
		Input_Queue[Input_Queue_WritePos[5:0]] = IO_in[21:0];
		Input_Queue_WritePos = Input_Queue_WritePos + 1;

		Input_Queue_Amount_WRITE = Input_Queue_Amount_WRITE + 1;
	end

			
			
endmodule
  
