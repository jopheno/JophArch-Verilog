module RXSampler (
	input sampling_clock,
	input init_flag,
	input rx,
	output reg sampled_rx,
	output [7:0] counter_out
);

assign counter_out = sampling_counter;

parameter SAMPLE_STOP = 2'b00;
parameter SAMPLE_HALF = 2'b01;
parameter SAMPLE_FULL = 2'b10;
parameter SAMPLING_COUNT_HALF = 5;
parameter SAMPLING_COUNT = SAMPLING_COUNT_HALF * 2;
parameter MSG_LENGTH = 10;

reg [3:0] sampling_counter;
reg [1:0] sampling_state;

reg [3:0] bit_count;

initial begin
	sampled_rx = 1;
end

always@(posedge sampling_clock) begin
	if (!init_flag) begin
		sampling_state = SAMPLE_STOP;
		sampled_rx = 1;
		bit_count = 0;
	end
	
	case (sampling_state)
		(SAMPLE_STOP): begin
			if(rx == 0) begin
				// Start bit detectado
				sampling_counter = 4'b1;
				sampling_state = SAMPLE_HALF;
			end
		end
		
		(SAMPLE_HALF): begin
			sampling_counter = sampling_counter + 4'b1;
			if (sampling_counter >= SAMPLING_COUNT_HALF) begin;
				sampling_counter = 0;
				sampled_rx = rx;
				bit_count = bit_count + 4'b1;
				sampling_state = SAMPLE_FULL;
			end
		end
		
		(SAMPLE_FULL): begin
			sampling_counter = sampling_counter + 4'b1;
			if (sampling_counter >= SAMPLING_COUNT) begin
				sampling_counter = 0;
				sampled_rx = rx;
				bit_count = bit_count + 4'b1;
				if (bit_count > MSG_LENGTH) begin
					bit_count = 0;
					if (rx == 1) sampling_state = SAMPLE_STOP;
				end
			end
		end
		
	endcase
end


endmodule
