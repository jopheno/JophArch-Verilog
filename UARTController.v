module UARTController (
	input clock,
	input uart_clock,
	input init_flag,
	input UART_ENB,
	input [2:0] instruction,
	input [7:0] write_value,
	input rx,
	output reg tx,
	output reg wb_flag,
	output reg [7:0] wb_data
	
	// TEST PURPOSES
	/*output reg [1:0] read_state,
	output reg [1:0] write_state,
	output reg [2:0] amount_read,
	output reg [2:0] amount_write,
	
	output reg [6:0] buffer_read,
	output reg [6:0] buffer_size,
	output reg [7:0] test_buffer*/
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

/* TEST PURPOSES */
reg [1:0] read_state;
reg [1:0] write_state;
reg [2:0] amount_read;
reg [2:0] amount_write;
	
reg [6:0] buffer_read;
reg [6:0] buffer_size;
reg [7:0] test_buffer;


initial begin
	integer i = 0;
	amount_read = 3'b000;
	buffer_size = 7'b0000000;

	for (i = 0; i < 128; i = i +1) begin
		buffer[i] = 8'b00000000;
	end
end

always@(negedge clock) begin

	if (!init_flag) begin
		write_buffer_write = 0;
	end
	
	if (UART_ENB) begin
	
		case(instruction)
			// Is value available
			(3'b001): begin
				if (buffer_read != buffer_size) begin
					wb_data = 8'b00000001;
				end else begin
					wb_data = 8'b00000000;
				end
				wb_flag = 1;
			end
			
			// Read value
			(3'b010): begin
				if (buffer_read != buffer_size) begin
					wb_data = buffer[buffer_read];
					buffer_read = buffer_read + 1;
				end else begin
					wb_data = 8'b00000000;
				end
				wb_flag = 1;
			end
			
			// Write value
			(3'b011): begin
				write_buffer[write_buffer_write] = write_value;
				write_buffer_write = write_buffer_write + 1;
				wb_flag = 0;
				wb_data = 8'b00000000;
			end
			
			default: begin
				wb_flag = 0;
				wb_data = 8'b00000000;
			end
		endcase
	
	end
	
end

always@(posedge uart_clock) begin
	if (!init_flag) begin
		amount_read = 0;
		amount_write = 0;
		buffer_size = 0;
		write_buffer_size = 0;
		write_parity = 0;
		read_state = IDLE;
		write_state = IDLE;
	end
	
	case(write_state)
		(IDLE): begin
			write_parity = 0;

			if (write_buffer_size != write_buffer_write) begin
				tx = 0;
				write_state = WRITING;
			end else begin
				tx = 1;
			end
		end
		
		(WRITING): begin
			write_parity = write_parity + write_buffer[amount_write];
			tx = write_buffer[amount_write];
			amount_write = amount_write + 1;
			
			if (amount_write == 0) begin
				write_state = PARITY;
			end
		end
		
		(PARITY): begin
			tx = write_parity;
			write_buffer_size = write_buffer_size + 1;

			write_state = IDLE;
		end
		
		default: begin
		
		end
	endcase

	case(read_state)
		(IDLE): begin
			read_parity = 0;

			if (rx == 0)
				read_state = READING;
			else
				read_state = IDLE;
		end
		
		(READING): begin
			read_parity = read_parity + rx;
			buffer[buffer_size][amount_read] = rx;
			test_buffer[amount_read] = rx;
			amount_read = amount_read + 1;
			
			if (amount_read == 0) begin
				read_state = PARITY;
			end
		end
		
		(PARITY): begin
			if (rx == read_parity)
				read_state = ENDING;
			else begin
				read_state = IDLE;
				amount_read = 0;
			end
		end
		
		(ENDING): begin
			buffer_size = buffer_size + 1;
			test_buffer = 8'b00000000;

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