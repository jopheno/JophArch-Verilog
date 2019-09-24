module VerilogDisplay (in, out);

  input [3:0] in;
  output reg [7:0] out = 8'b11111111;
  
  parameter s0 = 4'b0000;
  parameter s1 = 4'b0001;
  parameter s2 = 4'b0010;
  parameter s3 = 4'b0011;
  parameter s4 = 4'b0100;
  parameter s5 = 4'b0101;
  parameter s6 = 4'b0110;
  parameter s7 = 4'b0111;
  parameter s8 = 4'b1000;
  parameter s9 = 4'b1001;

  parameter sA = 4'b1010;
  parameter sB = 4'b1011;
  parameter sC = 4'b1100;
  parameter sD = 4'b1101;
  parameter sE = 4'b1110;
  parameter sF = 4'b1111;
  
  always@(in) begin
  
		case (in)     //.GFEDCBA
			s0: out = 8'b01000000;
			s1: out = 8'b01111001;
			s2: out = 8'b00100100;
			s3: out = 8'b00110000;
			s4: out = 8'b00011001;
			s5: out = 8'b00010010;
			s6: out = 8'b00000010;
			s7: out = 8'b01111000;
			s8: out = 8'b00000000;
			s9: out = 8'b00010000;

			sA: out = 8'b00001000;
			sB: out = 8'b00000011;
			sC: out = 8'b01000110;
			sD: out = 8'b00100001;
			sE: out = 8'b00000110;
			sF: out = 8'b00001110;

			default: out = 8'b01111111;
			
		
		endcase
  end
	
  
endmodule
