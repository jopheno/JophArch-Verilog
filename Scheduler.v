module Scheduler #(parameter CLOCK_COUNT_TO_INTERRUPT=500000)
(
// 10ms

	input init_flag,
	input clock,
	input physical_clock,
	
	// From DMA parallel component
	input DMA_op_ready,
	input [31:0] r_k,
	input [15:0] PC_pos,
	
	// From scheduler inst decoder
	input PRG_ENB,
	input JMP_flag,
	input SCHED_ENB,
	input SCHED_conf,
	input [3:0] SCHED_OP,
	input [15:0] SCHED_value,

	output reg timer_int, // Timer interruption flag
	output reg op_int, // DMA operation interruption flag
	output [15:0] int_pos, // Points 
	output reg [15:0] sys_int_pos, // SYSCall interruption jump position 
	
	output reg SCHED_write_flag,
	output reg [7:0] SCHED_write_addr,
	output reg [31:0] SCHED_write_data
	
);

reg initialized;
reg [15:0] timer_int_pos;
reg [15:0] op_int_pos;
reg [31:0] timer;
reg reset_timer;

reg [15:0] last_PC_pos;


initial begin
	timer = 0;
	timer_int = 0;
	
	initialized = 1'b0;
	last_PC_pos = 16'b0;
	timer_int_pos = 16'b0;
	op_int_pos = 16'b0;
	sys_int_pos = 16'b0;
	reset_timer = 1'b0;
	op_int = 1'b0;
		
	SCHED_write_flag = 1'b0;
	SCHED_write_addr = 8'b0;
	SCHED_write_data = 32'b0;
end

assign int_pos[15:0] = timer_int_pos[15:0];

always@(posedge physical_clock) begin
	timer <= timer+1;
	
	// If the processor was executed for at least a second and is not currently in kernel mode.
	if (r_k[15:0] > 0 && timer >= CLOCK_COUNT_TO_INTERRUPT && initialized == 1) begin
		timer_int <= 1;
	end

	if (reset_timer == 1) begin
		timer <= 0;
		timer_int <= 0;
	end
	
end

always@(posedge clock) begin
	if (!init_flag) begin
		initialized = 1'b0;
		last_PC_pos = 16'b0;
		timer_int_pos = 16'b0;
		op_int_pos = 16'b0;
		sys_int_pos = 16'b0;
		reset_timer = 1'b0;
		op_int = 1'b0;
		
		SCHED_write_flag = 1'b0;
		SCHED_write_addr = 8'b0;
		SCHED_write_data = 32'b0;
	end
	
	if (timer_int == 1 && PRG_ENB == 1) begin
		last_PC_pos[15:0] = PC_pos[15:0];
	end
	
	if (reset_timer == 1) begin
		reset_timer = 0;
	end
	
	// Calling instructions
	if (SCHED_ENB == 1) begin
		// Config instructions
		if (SCHED_conf == 1) begin
			case (SCHED_OP[3:0])
				4'b0001: begin
					sys_int_pos[15:0] = SCHED_value[15:0];
					
					SCHED_write_flag = 1'b0;
					SCHED_write_addr = 8'b0;
					SCHED_write_data = 32'b0;
				end
				4'b0010: begin
					timer_int_pos[15:0] = SCHED_value[15:0];
					
					SCHED_write_flag = 1'b0;
					SCHED_write_addr = 8'b0;
					SCHED_write_data = 32'b0;
				end
				4'b0011: begin
					op_int_pos[15:0] = SCHED_value[15:0];
					
					SCHED_write_flag = 1'b0;
					SCHED_write_addr = 8'b0;
					SCHED_write_data = 32'b0;
				end
				4'b0100: begin
					initialized = 1;
					
					SCHED_write_flag = 1'b0;
					SCHED_write_addr = 8'b0;
					SCHED_write_data = 32'b0;
				end
				4'b0101: begin
					reset_timer = 1;
					
					SCHED_write_flag = 1'b0;
					SCHED_write_addr = 8'b0;
					SCHED_write_data = 32'b0;
				end
				4'b0110: begin
					SCHED_write_flag = 1'b1;
					SCHED_write_addr = SCHED_value[7:0];
					SCHED_write_data = {16'b0, last_PC_pos[15:0]};
				end
				4'b0111: begin
					SCHED_write_flag = 1'b1;
					SCHED_write_addr = SCHED_value[7:0];
					SCHED_write_data = {16'b0, PC_pos[15:0]};
				end
				
				default: begin end
			endcase
		end
	end
	
	/*if (timer_int == 1) begin
		int_pos[15:0] = timer_int_pos[15:0];
	end else begin
		if (DMA_op_ready == 1) begin
			int_pos[15:0] = op_int_pos[15:0];
			op_int = 1'b1;
		end
	end*/
	
	
end


endmodule
