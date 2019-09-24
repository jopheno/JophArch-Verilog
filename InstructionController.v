module InstructionController (
	input r_src,
	input [31:0] rom_instruction,
	input [31:0] ram_instruction,
	output wire [31:0] curr_instruction
);

assign curr_instruction = ( r_src == 1 )? ram_instruction : rom_instruction;

endmodule
