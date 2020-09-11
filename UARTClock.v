module UARTClock (physical_clock, baud_rate, uart_clock);

input physical_clock;
input [31:0] baud_rate;
output reg uart_clock;

reg [31:0] count;


initial begin
	count = 0;
end

// TODO: Refazer levando em consideração baudrate sendo bytes por SEGUNDO.
always@(posedge physical_clock) begin
	count <= count+1;
	
	if (count >= ((8*baud_rate)/2)) begin
		count <= 1;
		uart_clock = ~uart_clock;
	end
end

endmodule
