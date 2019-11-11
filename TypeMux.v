module TypeMux(
	input [2:0] ID_type,
	output reg ALU_ENB,
	output reg STACK_ENB,
	output reg JMP_ENB,
	output reg DMA_ENB,
	output reg SCHED_ENB
);

	parameter STACK_PARAM = 3'b001;
	parameter ALU1_PARAM = 3'b010;
	parameter ALU2_PARAM = 3'b011;
	parameter DMA_PARAM = 3'b100;
	parameter JMP_PARAM = 3'b111;
	parameter SCHED_PARAM = 3'b101;

	always@(*) begin
		case (ID_type)
	
			ALU1_PARAM: begin
				ALU_ENB = 1;
				STACK_ENB = 0;
				JMP_ENB = 0;
				DMA_ENB = 0;
				SCHED_ENB = 0;
			end

			ALU2_PARAM: begin
				ALU_ENB = 1;
				STACK_ENB = 0;
				JMP_ENB = 0;
				DMA_ENB = 0;
				SCHED_ENB = 0;
			end

			STACK_PARAM: begin
				ALU_ENB = 0;
				STACK_ENB = 1;
				JMP_ENB = 0;
				DMA_ENB = 0;
				SCHED_ENB = 0;
			end

			JMP_PARAM: begin
				ALU_ENB = 0;
				STACK_ENB = 0;
				JMP_ENB = 1;
				DMA_ENB = 0;
				SCHED_ENB = 0;
			end

			DMA_PARAM: begin
				ALU_ENB = 0;
				STACK_ENB = 0;
				JMP_ENB = 0;
				DMA_ENB = 1;
				SCHED_ENB = 0;
			end

			SCHED_PARAM: begin
				ALU_ENB = 0;
				STACK_ENB = 0;
				JMP_ENB = 0;
				DMA_ENB = 0;
				SCHED_ENB = 1;
			end
			
			default: begin
				ALU_ENB = 0;
				STACK_ENB = 0;
				JMP_ENB = 0;
				DMA_ENB = 0;
				SCHED_ENB = 0;
			end

		endcase
	end

endmodule

