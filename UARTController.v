module UARTController (
	input clock,
	input physical_clock,
	input init_flag,
	input UART_ENB,
	input [2:0] instruction,
	input [7:0] write_value,
	input rx,
	output reg tx,
	output reg wb_flag,
	output reg [7:0] wb_data
);

parameter IDLE = 2'b00;
parameter READING = 2'b01;
parameter WRITING = 2'b01;
parameter PARITY = 2'b10;
parameter ENDING = 2'b11;

reg [7:0] buffer [128];

reg [7:0] write_buffer [128];
reg [6:0] write_buffer_size;
reg [6:0] write_buffer_write;

reg read_parity;
reg write_parity;

reg [1:0] read_state;
reg [1:0] write_state;
reg [3:0] amount_read;
reg [3:0] amount_write;
	
reg [6:0] buffer_read;
reg [6:0] buffer_size;


initial begin
	integer i = 0;
	amount_read = 3'b000;
	amount_write = 3'b000;

	buffer_size = 7'b0000000;

	for (i = 0; i < 128; i = i +1) begin
		buffer[i] = 8'b00000000;
	end
end

always@(posedge physical_clock) begin
	if (UART_ENB) begin
		case(instruction)
			(3'b001): begin
				wb_flag = 1;
				wb_data[7:0] = buffer_read[6:0] != buffer_size[6:0];
			end

			// Read value
			(3'b010): begin
				wb_flag = 1;
				wb_data[7:0] = buffer[buffer_read[6:0]][7:0];
			end
			
			// Write value
			(3'b011): begin
				wb_flag = 0;
				wb_data[7:0] = 0;
			end

			// DEBUG1 buffer_read
			(3'b101): begin
				wb_flag = 1;
				wb_data[7:0] = {1'b0, buffer_read[6:0]};
			end

			// DEBUG2 buffer_size
			(3'b110): begin
				wb_flag = 1;
				wb_data[7:0] = {1'b0, buffer_size[6:0]};
			end
			
			default: begin
				wb_flag = 0;
				wb_data[7:0] = 0;
			end
		endcase
	end else begin
		wb_flag = 0;
		wb_data[7:0] = 0;
	end
end

always@(negedge clock) begin

	if (!init_flag) begin
		write_buffer_write = 0;
		buffer_read = 0;
	end
	
	if (UART_ENB) begin
		case(instruction)
			// Read value
			(3'b010): begin
				if (buffer_read[6:0] != buffer_size[6:0]) begin
					buffer_read[6:0] = buffer_read[6:0] + 1;
				end
			end
			
			// Write value
			(3'b011): begin
				write_buffer[write_buffer_write[6:0]][7:0] = write_value[7:0];
				write_buffer_write[6:0] = write_buffer_write[6:0] + 1;
			end
		endcase
	end
	
end

reg[31:0] c;
reg custom_uart_clock;

parameter desired_baudrate = 1200;

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
	end
	
	if (c[31:0] >= (2500000/desired_baudrate)) begin
		custom_uart_clock = ~custom_uart_clock;
		c[31:0] = 0;
	end
	
	c[31:0] = c[31:0] + 1;
end

always@(posedge custom_uart_clock) begin
	if (!init_flag) begin
		amount_read = 0;
		amount_write = 0;
		buffer_size = 0;
		write_buffer_size = 0;
		write_parity = 0;
		tx = 1;
		read_state = IDLE;
		write_state = IDLE;
	end
	
	case(write_state)
		(IDLE): begin
			write_parity = 0;
			amount_write = 0;
			tx = 1;
			if (write_buffer_size != write_buffer_write) begin
				tx = 0;
				write_state = WRITING;
			end
		end
		
		(WRITING): begin
			tx = write_buffer[write_buffer_size][amount_write];
			write_parity = write_parity + tx;
			amount_write = amount_write + 1;
			
			if (amount_write >= 8) begin
				write_state = PARITY;
			end
			else begin
				write_state = WRITING;
			end
		end
		
		(PARITY): begin
			tx = write_parity;
			amount_write = 0;
			write_buffer_size = write_buffer_size + 1;
			write_state = IDLE;
		end
		
		default: begin
			write_state = IDLE;
		end
	endcase

	case(read_state)
		(IDLE): begin
			read_parity = 0;
			amount_read = 0;
			if (rx == 0)
				read_state = READING;
			else
				read_state = IDLE;
		end
		
		(READING): begin
			read_parity = read_parity + rx;
			buffer[buffer_size][amount_read] = rx;
			//test_buffer[amount_read] = rx;
			amount_read = amount_read + 1;
			
			if (amount_read >= 8) begin
				read_state = PARITY;
			end
		end
		
		(PARITY): begin
			if (rx == read_parity)
				read_state = ENDING;
			else begin
				read_state = IDLE;
			end
		end
		
		(ENDING): begin
			buffer_size = buffer_size + 1;
			amount_read = 0;
			//test_buffer = 8'b00000000;

			if (rx == 0)
				read_state = READING;
			else
				read_state = IDLE;

		end
		
		default: begin
			read_state = IDLE;
		end
	endcase
end

endmodule
