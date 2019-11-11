module DataPath(
	input physical_clock, // Clock 50MHz

	input [21:0] IO_input, // 0-17 SWs; 18-21 Keys;
	output wire [25:0] IO_output, // 0-7 GreenLEDS; 8-25;
	
	output [15:0] DISPLAY_1,
	output [15:0] DISPLAY_2,
	output [31:0] DISPLAY_3,

	input DMA_Apply_Btn,
	output clock,
	output [1:0] cp_flag

);
	wire [57:0] IO_out;

	assign IO_output[25:0] = IO_out[25:0];
	assign cp_flag = {1'b0, timer_int};

	VerilogDisplay inst_display1_0(
		IO_out[29:26],
		DISPLAY_1[7:0]
	);
	
	VerilogDisplay inst_display1_1(
		IO_out[33:30],
		DISPLAY_1[15:8]
	);
	







	VerilogDisplay inst_display2_0(
		IO_out[37:34],
		DISPLAY_2[7:0]
	);
	
	VerilogDisplay inst_display2_1(
		IO_out[41:38],
		DISPLAY_2[15:8]
	);






	VerilogDisplay inst_display3_0(
		IO_out[45:42],
		DISPLAY_3[7:0]
	);
	
	VerilogDisplay  inst_display3_1(
		IO_out[49:46],
		DISPLAY_3[15:8]
	);
	
	VerilogDisplay  inst_display3_2(
		IO_out[53:50],
		DISPLAY_3[23:16]
	);
	
	VerilogDisplay  inst_display3_3(
		IO_out[57:54],
		DISPLAY_3[31:24]
	);

	// wire clock;
	
	wire REG_write_back_flag;
	wire [7:0] REG_write_back_code;
	wire [31:0] REG_write_back_data;

	wire ALU_ENB;
	wire DMA_ENB;
	wire STACK_ENB;
	wire JMP_ENB;
	wire SCHED_ENB;
	
	wire CALL_flag;
	wire RET_flag;
	wire PUSH_flag;
	wire POP_flag;
	wire GSA_flag;
	wire SWITCH_flag;
	wire SYS_flag;
	wire Kernel_flag;

	wire [15:0] PC_pos;
	wire [31:0] JMP_pos;

	wire [31:0] r_eax;
	wire [31:0] r_ebx;
	wire [31:0] r_ecx;
	wire [31:0] r_edx;
	wire [3:0] r_clk;
	wire [15:0] r_esp;
	wire r_src;
	wire [15:0] r_k;
	
	wire [7:0] f_register_code;
	wire [31:0] f_register_value;
  
	wire [7:0] s_register_code;
	wire [31:0] s_register_value;
  
	wire [7:0] t_register_code;
	wire [31:0] t_register_value;

	reg init_flag = 0;
	wire [31:0] curr_instruction;
	wire [31:0] ram_instruction;
	wire [31:0] rom_instruction;
	wire [2:0] ID_type;
	wire [4:0] ID_func;
	wire [23:0] immediate;
	
	//wire ALU_ENB,
	wire ALU_write_back_flag;
	wire [7:0] ALU_write_back_code;
	wire [31:0] ALU_write_back_value;
	
	//wire DMA_ENB;
	wire DMA_write_back_flag;
	wire [7:0] DMA_write_back_code;
	wire [31:0] DMA_write_back_value;

	//wire STACK_ENB;
	wire STACK_write_back_flag;
	wire [7:0] STACK_write_back_code;
	wire [31:0] STACK_write_back_value;

	//wire JMP_ENB;
	wire JMP_write_back_flag;
	wire [7:0] JMP_write_back_code;
	wire [31:0] JMP_write_back_value;
	
	wire [31:0] clock_eff;

	assign clock_eff = ( r_clk == 0 )? 128 : ( r_clk == 1 )?  50000 : ( r_clk == 2 )? 500000 : ( r_clk == 3 )? 5000000 : 50000000;


	// FLAGS

	reg write_back_flag;
	reg ALU_src_flag;
	wire JMP_flag;

	// Scheduler
	
	wire DMA_op_ready;
	wire timer_int;
	wire op_int;
	wire [15:0] int_pos;
	wire [15:0] sys_int_pos;

	wire SCHED_conf;
	wire [3:0] SCHED_OP;
	wire [15:0] SCHED_value;

	
	// Program Decoder
	
	wire [3:0] M_ALU_op;
	wire [31:0] M_ALU_v1;
	wire [31:0] M_ALU_v2;
	wire [31:0] M_ALU_out;

	// ALU Decoder
	
	wire [4:0] ALU_op;
	wire [31:0] ALU_v1;
	wire [31:0] ALU_v2;

	// Instruction Decoder

	// DMA Instructions Wires
  
	wire DMA_stack_flag;
	wire [15:0] DMA_stack_data;
	// REGISTERs Wires
	
	reg n_reset = 1;
	
	wire DMA_Apply_clock;
	
	wire mclock;
	
	DeBounce inst_debounce(
		physical_clock,
		n_reset,
		DMA_Apply_Btn,
		DMA_Apply_clock
	);

	VirtualClock inst_virtualclock(
		physical_clock,
		clock_eff,
		clock
	);

	MemClock inst_memclock(
		physical_clock,
		clock_eff,
		mclock
	);

	ProgramCounter inst_programcounter(
		clock,
		init_flag,
		JMP_flag,
		JMP_pos,
		r_k,
		sys_int_pos,

		timer_int,
		op_int,
		int_pos,

		CALL_flag,
		RET_flag,
		PUSH_flag,
		POP_flag,
		GSA_flag,
		SWITCH_flag,
		SYS_flag,
		Kernel_flag,

		PC_pos,
		
		JMP_write_back_flag,
		JMP_write_back_code,
		JMP_write_back_value
	);

	WriteController inst_writecontroller(

		ALU_ENB,
		ALU_write_back_flag,
		ALU_write_back_code,
		ALU_write_back_value,

		STACK_ENB,
		STACK_write_back_flag,
		STACK_write_back_code,
		STACK_write_back_value,

		JMP_ENB,
		JMP_write_back_flag,
		JMP_write_back_code,
		JMP_write_back_value,

		DMA_ENB,
		DMA_write_back_flag,
		DMA_write_back_code,
		DMA_write_back_value,

		REG_write_back_flag,
		REG_write_back_code,
		REG_write_back_data
	);
  
	TypeMux inst_typemux(
		ID_type,
		ALU_ENB,
		STACK_ENB,
		JMP_ENB,
		DMA_ENB,
		SCHED_ENB
	);
	
	/*NDMA inst_new_dma(
		init_flag,
		clock,
		DMA_Apply_clock,
		DMA_ENB,
		curr_instruction,
		f_register_value,
		s_register_value,
		t_register_value,
		IO_input,
		RAM_data,
		r_esp,
		IO_out,
		DMA_write_back_flag,
		DMA_write_back_code,
		DMA_write_back_value,
		RAM_write_flag,
		RAM_write_addr,
		RAM_write_data,
		DMA_stack_flag,
		DMA_stack_data
	);*/

	wire pram_wb_flag;
	wire [15:0] pram_addr;
	wire [31:0] pram_wb_data;
	wire [31:0] pram_data;
	
	wire hdd_wb_flag;
	wire [15:0] hdd_addr;
	wire [31:0] hdd_wb_data;
	wire [31:0] hdd_data;
	
	Scheduler inst_scheduler(
		init_flag,
		clock,
		physical_clock,
		DMA_op_ready,
		r_k,
		SCHED_ENB,
		SCHED_conf,
		SCHED_OP,
		SCHED_value,
		timer_int,
		op_int,
		int_pos,
		sys_int_pos
	);
	
	DMA inst_DMA(
		init_flag,
		clock,
		physical_clock,
		mclock,
		DMA_Apply_clock,
		DMA_ENB,
		curr_instruction,
		f_register_value,
		s_register_value,
		t_register_value,
		IO_input,
		r_esp,		
		RAM_data,

		// Parallel functions
		PC_pos,
		pram_data,
		hdd_data,

		
		IO_out,
		DMA_write_back_flag,
		DMA_write_back_code,
		DMA_write_back_value,
		RAM_write_flag,
		RAM_write_addr,
		RAM_write_data,
		DMA_stack_flag,
		DMA_stack_data,
		
		// Parallel functions
		
		pram_addr,
		hdd_addr,
		pram_wb_data,
		hdd_wb_data,
		pram_wb_flag,
		hdd_wb_flag
		
	);
	
	single_port_rom inst_instructionmem(
		PC_pos,
		physical_clock,
		rom_instruction
	);

	wire [31:0] RAM_data;

	wire RAM_write_flag;
	wire [15:0] RAM_write_addr;
	wire [31:0] RAM_write_data;
	
	/*RAMMemory inst_datamem(
		RAM_write_data,
		RAM_write_addr,
		RAM_write_flag,
		physical_clock,
		RAM_data
	);*/
	
	InstructionController inst_instruction_ctrl(
		r_src,
		rom_instruction,
		ram_instruction,
		curr_instruction
	);
	
	HDD inst_hdd(
		hdd_wb_data,
		hdd_addr,
		hdd_wb_flag,
		physical_clock,
		hdd_data
	);
	
	wire selected_flag;
	wire [15:0] selected_addr;
	wire[31:0] selected_data;
	
	assign selected_flag = (DMA_ENB == 1) ? RAM_write_flag : pram_wb_flag;
	assign selected_addr[15:0] = (DMA_ENB == 1) ? RAM_write_addr[15:0] : pram_addr[15:0];
	assign selected_data[31:0] = (DMA_ENB == 1) ? RAM_write_data[31:0] : pram_wb_data[31:0];

	wire [31:0] received_data;
	assign RAM_data[31:0] = (DMA_ENB == 1) ? received_data[31:0] : 32'b0;
	assign pram_data[31:0] = (DMA_ENB == 0) ? received_data[31:0] : 32'b0;
	
	//assign selected_flag = RAM_write_flag;
	//assign selected_addr[15:0] = RAM_write_addr[15:0];
	//assign selected_data[31:0] = RAM_write_data[31:0];
	
	wire ram_write_flag;
	assign ram_write_flag = 1'b0;
	wire [31:0] ram_write_data;
	assign ram_write_data = 32'b0;
	
	DualPortRAM inst_dualportram(

		ram_write_data,
		selected_data,
	
		PC_pos,
		selected_addr,

		ram_write_flag,
		selected_flag,

		physical_clock,

		ram_instruction,
		received_data
	);

	SchedulerDecoder inst_scheddec(
		SCHED_ENB,
		curr_instruction,
		f_register_value,
		s_register_value,
		t_register_value,
		curr_instruction[23:0],
		PC_pos,
		SCHED_conf,
		SCHED_OP,
		SCHED_value
	);
	
	ProgramDecoder inst_programdec(
		JMP_ENB,
		curr_instruction,
		f_register_value,
		s_register_value,
		t_register_value,
		curr_instruction[23:0],
		PC_pos,

		JMP_flag,
		CALL_flag,
		RET_flag,
		PUSH_flag,
		POP_flag,
		GSA_flag,
		SWITCH_flag,
		SYS_flag,
		Kernel_flag,

		M_ALU_op,
		M_ALU_v1,
		M_ALU_v2
	);
	
	MiniALU inst_minialu(
		JMP_ENB,
		M_ALU_op,
		M_ALU_v1,
		M_ALU_v2,
		JMP_pos
	);
  
	//Test inst_2 (clock, write_back_code, write_back_value);

	InstructionDecoder inst_instdec(
		curr_instruction,
		ID_type,
		ID_func,
		f_register_code,
		s_register_code,
		t_register_code,
		immediate
	);
	
	ALUDecoder inst_aludec(
		ALU_ENB,
		curr_instruction,
		f_register_value,
		s_register_value,
		t_register_value,
		curr_instruction[23:0],

		ALU_op,
		ALU_v1,
		ALU_v2,

		ALU_write_back_flag,
		ALU_write_back_code
	);

	ALU inst_alu(
		ALU_ENB,
		ALU_op,
		ALU_v1,
		ALU_v2,
		ALU_write_back_value
	);
  
	Registers inst_registers(
		init_flag,
		clock,

		REG_write_back_flag,
		REG_write_back_code,
		REG_write_back_data,

		f_register_code,
		s_register_code,
		t_register_code,

		STACK_TOP,
		STACK_AMOUNT,

		CALL_flag,
		RET_flag,
		
		DMA_stack_flag,
		DMA_stack_data,

		f_register_value,
		s_register_value,
		t_register_value,
		
		r_eax,
		r_ebx,
		r_ecx,
		r_edx,
		r_clk,
		r_esp,
		r_src,
		r_k,
		
		STACK_push_flag,
		STACK_push_value
	);
	
	/*wire write_bkp;

	assign write_bkp = 1;
	
	single_port_reg_bkp_ram (
		registers_bkp,
		bkp_pos,
		write_bkp,
		physical_clock,
		
		
	
	);*/
  
	always@(negedge clock) begin
		init_flag = 1;
	end

endmodule
  
  