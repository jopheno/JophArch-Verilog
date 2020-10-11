module UARTController (
	input clock,
	input physical_clock,
	input uart_clock,
	input init_flag,
	input UART_ENB,
	input [2:0] instruction,
	input [7:0] write_value,
	input rx,
	input ready_to_receive,
	output reg tx,
	output reg ready_to_send,
	output reg wb_flag,
	output reg [7:0] wb_data
	
	// TEST PURPOSES
	//output [1:0] read_state_out,
	//output reg [1:0] write_state,
	//output reg [2:0] amount_read,
	//output reg [2:0] amount_write,
	
	//output reg [6:0] buffer_read,
	//output reg [6:0] buffer_size
	//output reg [7:0] test_buffer
);

assign read_state_out = read_state;

parameter IDLE = 2'b00;
parameter READING = 2'b01;
parameter WRITING = 2'b01;
parameter PARITY = 2'b10;
parameter ENDING = 2'b11;

reg [7:0] buffer [128];

reg [7:0] write_buffer [128];
reg [6:0] write_buffer_size;
reg [6:0] write_buffer_write;
reg read_control;

reg read_parity;
reg write_parity;

/* TEST PURPOSES */
reg [1:0] read_state;
reg [1:0] write_state;
reg [3:0] amount_read;
reg [3:0] amount_write;
	
reg [6:0] buffer_read;
reg [6:0] buffer_size;
//reg [7:0] test_buffer;


initial begin
	integer i = 0;
	amount_read = 3'b000;
	buffer_size = 7'b0000000;
	tx = 1;
	ready_to_send = 0;

	for (i = 0; i < 128; i = i +1) begin
		buffer[i] = 8'b00000000;
	end
end

// assign wb_flag = buffer_read != buffer_size;
// assign wb_data = buffer[buffer_read];

always@(posedge physical_clock) begin
	if (!init_flag) begin
		wb_flag = 0;
	end

	//wb_flag = buffer_read != buffer_size;
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
				//wb_data[7:0] = 10;
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
		wb_data[7:0] = 0;
	end
end

always@(negedge clock) begin

	if (!init_flag) begin
		buffer_read = 0;
		write_buffer_write = 0;
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

always@(posedge clock) begin
	if (!init_flag) begin
		ready_to_send = 1;
	end
end

//always@(posedge (uart_clock && ready_to_receive)) begin
always@(posedge uart_clock) begin
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
