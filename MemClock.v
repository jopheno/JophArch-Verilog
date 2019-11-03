module MemClock
 #(parameter MCLOCK_SIZE=8)
(
	input physical_clock,
	input [31:0] clock_eff,
	output reg mclock
);

reg [31:0] count;

initial begin
	count = 0;
end

always@(posedge physical_clock) begin
	count <= count+1;
	
	if (count >= (clock_eff/(2*MCLOCK_SIZE))) begin // 8x faster
	//if (count >= ((clock_eff*MCLOCK_SIZE)/2)) begin // 8x slower
		count <= 0;
		mclock = ~mclock;
	end
end

endmodule
