module UARTClockGenerator (
	input physical_clock,
	input init_flag,
	input [2:0] instruction,
	input [31:0] baudrate_value,
	output uart_clock,
	output sampling_clock_out,
	output [31:0] clock_count
);


reg[31:0] c;
reg[31:0] c_sample;
reg custom_uart_clock;
reg sampling_clock;
reg [31:0] desired_baudrate;
parameter cycle_hz = 2500000; // 2500000
parameter default_baudrate = 250000;
parameter sampling_speed = 10;

assign clock_count = c;

// If I count to 25000000 it will give me a 1Hz frequency clock,
// to describe the baud rate I must consider the time needed to
// read a byte, on this implementation case, it needs 1 cycle for
// the starting bit recognition, 8 cycles for reading each bit from
// the data, and one last cycle for the parity bit, so it sums up 10
// cycles for each 8 bits block being read, so, to convert to baudrate
// I must divide by 10 the counter, this way counting up to 2500000 will
// give me a 1 baud rate, if I want a higher baudrate, I must speed
// up the process by dividing this count amount per the baudrate
// desired.
always@(posedge physical_clock) begin
	if (!init_flag) begin
		c[31:0] = 32'b0;
		c_sample[31:0] = 32'b0;
		desired_baudrate = default_baudrate;
	end
	
	if (instruction == 3'b100) begin
		desired_baudrate = baudrate_value;
	end
	
	if (c_sample[31:0] >= (cycle_hz/desired_baudrate)) begin
		sampling_clock = ~sampling_clock;
		c_sample = 0;
	end
	
	if (c[31:0] >= (cycle_hz/desired_baudrate)) begin
		custom_uart_clock = ~custom_uart_clock;
		c[31:0] = 0;
	end
	
	c[31:0] = c[31:0] + 1;
	c_sample[31:0] = c_sample[31:0] + sampling_speed;
end

assign uart_clock = custom_uart_clock;
assign sampling_clock_out = sampling_clock;

endmodule
