module VirtualClock (physical_clock, clock_eff, virtual_clock);

input physical_clock;
input [31:0] clock_eff;
output reg virtual_clock;

reg [31:0] count;


initial begin
	count = 0;
end

always@(posedge physical_clock) begin
	count <= count+1;
	
	if (count >= (clock_eff/2)) begin
		count <= 1;
		virtual_clock = ~virtual_clock;
	end
end

endmodule
