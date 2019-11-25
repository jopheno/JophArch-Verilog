module SchedulerDecoder(
	input SCHED_ENB,
	input [31:0] current_instruction,
	input [31:0] f_register_value,
	input [31:0] s_register_value,
	input [31:0] t_register_value,
	input [23:0] immediate,
	input [15:0] PC_pos,
	output reg SCHED_conf,
	output reg [3:0] SCHED_OP,
	output reg [15:0] SCHED_value
);

	always@(*) begin
		if (SCHED_ENB) begin
			case (current_instruction[28:24])

				5'b10001: begin // Config SYSCall | SYSCalli
					SCHED_conf = 1;
					SCHED_OP[3:0] = 4'b0001;
					SCHED_value[15:0] = immediate[15:0];
				end

				5'b10010: begin // Config Timer Interruption | Timeri
					SCHED_conf = 1;
					SCHED_OP[3:0] = 4'b0010;
					SCHED_value[15:0] = immediate[15:0];
				end

				5'b10011: begin // Config DMA Operation Interruption | DMAInti
					SCHED_conf = 1;
					SCHED_OP[3:0] = 4'b0011;
					SCHED_value[15:0] = immediate[15:0];
				end

				5'b00001: begin // Initialize | Start
					SCHED_conf = 1;
					SCHED_OP[3:0] = 4'b0100;
					SCHED_value[15:0] = immediate[15:0];
				end

				5'b00010: begin // Reset timer | RTimer
					SCHED_conf = 1;
					SCHED_OP[3:0] = 4'b0101;
					SCHED_value[15:0] = immediate[15:0];
				end

				5'b00011: begin // Return last PC_POS | RETR
					SCHED_conf = 1;
					SCHED_OP[3:0] = 4'b0110;
					SCHED_value[15:0] = {8'b0, current_instruction[27:16]};
				end

				5'b00100: begin // Return PC_POS | PC
					SCHED_conf = 1;
					SCHED_OP[3:0] = 4'b0111;
					SCHED_value[15:0] = {8'b0, current_instruction[27:16]};
				end
				
				default: begin
					SCHED_conf = 0;
					SCHED_OP[3:0] = 0;
					SCHED_value[15:0] = 0;
				end
			
			endcase
		end else begin
			SCHED_conf = 0;
			SCHED_OP[3:0] = 0;
			SCHED_value[15:0] = 0;
		end
	end

endmodule
