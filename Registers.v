module Registers(
	input init,
	input clock,
	input REG_write_back_flag,
	input [7:0] REG_write_back_code,
	input [31:0] REG_write_back_data,

	input [7:0] f_register_code,
	input [7:0] s_register_code,
	input [7:0] t_register_code,
	
	input [31:0] STACK_TOP,
	input [15:0] STACK_AMOUNT,
	
	input CALL_FLAG,
	input RET_FLAG,
	
	input DMA_stack_flag,
	input [15:0] DMA_stack_data,

	output reg[31:0] f_register_value,
	output reg[31:0] s_register_value,
	output reg[31:0] t_register_value,
	
	output reg [31:0] r_eax,
	output reg [31:0] r_ebx,
	output reg [31:0] r_ecx,
	output reg [31:0] r_edx,
	output reg [3:0] r_clk,
	output reg [15:0] r_esp,
	output reg r_src,
	output reg [15:0] r_k,
	
	output reg STACK_push_flag,
	output reg [31:0] STACK_push_value
);

//reg [127:0] CALL_BKP_STACK [64];
//reg [7:0] CALL_STACK_SIZE;

initial begin
	/*integer i = 0;
	
	for (i = 0; i < 64; i = i +1) begin
		CALL_BKP_STACK[i] = 0;
	end
	
	CALL_STACK_SIZE = 8'b0;*/

	r_eax[31:0] = 32'b0;
	r_ebx[31:0] = 32'b0;
	r_ecx[31:0] = 32'b0;
	r_edx[31:0] = 32'b0;

	r_esp[15:0] = 16'hFFFF;
	r_clk[3:0] = 4'b0;
	r_src = 0;
	r_k[15:0] = 16'b0;
	
	STACK_push_flag = 0;
	STACK_push_value[31:0] = 32'b0;

end
  
	//reg [31:0] r_eax;
	//reg [31:0] r_ebx;
	//reg r_ecx[31:0] = 0;
	//reg r_edx[31:0] = 0;
  
	//reg p_tpa[7:0] = 0;
	//reg p_bpa[7:0] = 0;
 
	//reg p_tpb[15:0] = 0;
	//reg p_bpb[15:0] = 0;
 
	//reg p_tpc[31:0] = 0;
	//reg p_bpc[31:0] = 0;
	
	// STACK REGISTER
	parameter STACK_TOP_REG = 8'b00100000;
	parameter STACK_AMOUNT_REG = 8'b00100001;
	
	// CUSOTM REGISTERS
	
	parameter clk = 8'b00100010;
	parameter esp = 8'b10010011;
	parameter src = 8'b00100100;
	parameter k =   8'b01100100;

	// EAX REGISTERs
	parameter eax = 8'b10000000;
	parameter ax =  8'b10000001;
	parameter al =  8'b10000010;
	parameter ah =  8'b10000011;
	parameter aw =  8'b10000101;
	parameter as =  8'b10000110;
	parameter ap =  8'b10000111;

	parameter ebx = 8'b10100000;
	parameter bx =  8'b10100001;
	parameter bl =  8'b10100010;
	parameter bh =  8'b10100011;
	parameter bw =  8'b10100101;
	parameter bs =  8'b10100110;
	parameter bp =  8'b10100111;

	parameter ecx = 8'b11000000;
	parameter cx =  8'b11000001;
	parameter cl =  8'b11000010;
	parameter ch =  8'b11000011;
	parameter cw =  8'b11000101;
	parameter cs =  8'b11000110;
	parameter cp =  8'b11000111;

	parameter edx = 8'b11100000;
	parameter dx =  8'b11100001;
	parameter dl =  8'b11100010;
	parameter dh =  8'b11100011;
	parameter dw =  8'b11100101;
	parameter ds =  8'b11100110;
	parameter dp =  8'b11100111;

	always@(negedge clock) begin


		if (!init) begin
			r_eax[31:0] = 32'b0;
			r_ebx[31:0] = 32'b0;
			r_ecx[31:0] = 32'b0;
			r_edx[31:0] = 32'b0;

			r_esp[15:0] = 16'hFFFF;
			r_clk[3:0] = 4'b0;
			r_src = 0;
			r_k[15:0] = 16'b0;
		end else begin
		
		if (DMA_stack_flag) begin
			r_esp[15:0] = DMA_stack_data[15:0];
		end
		
		/*if (CALL_FLAG) begin
			CALL_BKP_STACK[CALL_STACK_SIZE] = {r_eax, r_ebx, r_ecx, r_edx};
			CALL_STACK_SIZE = CALL_STACK_SIZE + 1;
		end
		
		if (RET_FLAG) begin
			CALL_STACK_SIZE = CALL_STACK_SIZE - 1;
			r_eax[31:0] = CALL_BKP_STACK[CALL_STACK_SIZE][31:0];
			r_ebx[31:0] = CALL_BKP_STACK[CALL_STACK_SIZE][63:32];
			r_ecx[31:0] = CALL_BKP_STACK[CALL_STACK_SIZE][95:64];
			r_edx[31:0] = CALL_BKP_STACK[CALL_STACK_SIZE][127:96];
		end*/

		if (REG_write_back_flag) begin

			case (REG_write_back_code)
				clk: r_clk = REG_write_back_data[3:0];
				src: r_src = REG_write_back_data[0];
				k: r_k = REG_write_back_data[15:0];

				// EAX REGISTERs
				eax: r_eax = REG_write_back_data;
				ax: r_eax[15:0] = REG_write_back_data[15:0];
				al: r_eax[7:0] = REG_write_back_data[7:0];
				ah: r_eax[15:8] = REG_write_back_data[7:0];
				aw: r_eax[31:16] = REG_write_back_data[15:0];
				as: r_eax[23:16] = REG_write_back_data[7:0];
				ap: r_eax[31:24] = REG_write_back_data[7:0];


				// EBX REGISTERs
				ebx: r_ebx = REG_write_back_data;
				bx: r_ebx[15:0] = REG_write_back_data[15:0];
				bl: r_ebx[7:0] = REG_write_back_data[7:0];
				bh: r_ebx[15:8] = REG_write_back_data[7:0];
				bw: r_ebx[31:16] = REG_write_back_data[15:0];
				bs: r_ebx[23:16] = REG_write_back_data[7:0];
				bp: r_ebx[31:24] = REG_write_back_data[7:0];


				// ECX REGISTERs
				ecx: r_ecx = REG_write_back_data;
				cx: r_ecx[15:0] = REG_write_back_data[15:0];
				cl: r_ecx[7:0] = REG_write_back_data[7:0];
				ch: r_ecx[15:8] = REG_write_back_data[7:0];
				cw: r_ecx[31:16] = REG_write_back_data[15:0];
				cs: r_ecx[23:16] = REG_write_back_data[7:0];
				cp: r_ecx[31:24] = REG_write_back_data[7:0];


				// EDX REGISTERs
				edx: r_edx = REG_write_back_data;
				dx: r_edx[15:0] = REG_write_back_data[15:0];
				dl: r_edx[7:0] = REG_write_back_data[7:0];
				dh: r_edx[15:8] = REG_write_back_data[7:0];
				dw: r_edx[31:16] = REG_write_back_data[15:0];
				ds: r_edx[23:16] = REG_write_back_data[7:0];
				dp: r_edx[31:24] = REG_write_back_data[7:0];

				default: begin end // do nothing

			endcase
		end
		end

	end

  always@(*) begin
			if (REG_write_back_code == STACK_TOP_REG) begin
				STACK_push_flag = 1;
				STACK_push_value = REG_write_back_data;
			end else begin
				STACK_push_flag = 0;
				STACK_push_value = 32'b0;
			end
	end
	
  always@(*) begin
		case (f_register_code)
		
			// CUSTOM REGISTERs
			clk: f_register_value = {28'b0,r_clk[3:0]};
			esp: f_register_value = {16'b0,r_esp[15:0]};
			src: f_register_value = {31'b0,r_src};
			k: f_register_value = {16'b0,r_k[15:0]};

			// EAX REGISTERs
			eax: f_register_value = r_eax;
			ax: f_register_value = {16'b0,r_eax[15:0]};
			al: f_register_value = {24'b0,r_eax[7:0]};
			ah: f_register_value = {24'b0,r_eax[15:8]};
			aw: f_register_value = {16'b0,r_eax[31:16]};
			as: f_register_value = {24'b0,r_eax[23:16]};
			ap: f_register_value = {24'b0,r_eax[31:24]};

			// EBX REGISTERs
			ebx: f_register_value = r_ebx;
			bx: f_register_value = {16'b0,r_ebx[15:0]};
			bl: f_register_value = {24'b0,r_ebx[7:0]};
			bh: f_register_value = {24'b0,r_ebx[15:8]};
			bw: f_register_value = {16'b0,r_ebx[31:16]};
			bs: f_register_value = {24'b0,r_ebx[23:16]};
			bp: f_register_value = {24'b0,r_ebx[31:24]};

			// ECX REGISTERs
			ecx: f_register_value = r_ecx;
			cx: f_register_value = {16'b0,r_ecx[15:0]};
			cl: f_register_value = {24'b0,r_ecx[7:0]};
			ch: f_register_value = {24'b0,r_ecx[15:8]};
			cw: f_register_value = {16'b0,r_ecx[31:16]};
			cs: f_register_value = {24'b0,r_ecx[23:16]};
			cp: f_register_value = {24'b0,r_ecx[31:24]};

			// EDX REGISTERs
			edx: f_register_value = r_edx;
			dx: f_register_value = {16'b0,r_edx[15:0]};
			dl: f_register_value = {24'b0,r_edx[7:0]};
			dh: f_register_value = {24'b0,r_edx[15:8]};
			dw: f_register_value = {16'b0,r_edx[31:16]};
			ds: f_register_value = {24'b0,r_edx[23:16]};
			dp: f_register_value = {24'b0,r_edx[31:24]};

			// TOP_STACK
			STACK_TOP_REG: f_register_value = STACK_TOP;
			STACK_AMOUNT_REG: f_register_value = {16'b0,STACK_AMOUNT};

			default: f_register_value = 32'b0;

		endcase

	end



  always@(*) begin
		case (s_register_code)
		
			// CUSTOM REGISTERs
			clk: s_register_value = {28'b0,r_clk[3:0]};
			esp: s_register_value = {16'b0,r_esp[15:0]};
			src: s_register_value = {31'b0,r_src};
			k: s_register_value = {16'b0,r_k[15:0]};

			// EAX REGISTERs
			eax: s_register_value = r_eax;
			ax: s_register_value = {16'b0,r_eax[15:0]};
			al: s_register_value = {24'b0,r_eax[7:0]};
			ah: s_register_value = {24'b0,r_eax[15:8]};
			aw: s_register_value = {16'b0,r_eax[31:16]};
			as: s_register_value = {24'b0,r_eax[23:16]};
			ap: s_register_value = {24'b0,r_eax[31:24]};

			// EBX REGISTERs
			ebx: s_register_value = r_ebx;
			bx: s_register_value = {16'b0,r_ebx[15:0]};
			bl: s_register_value = {24'b0,r_ebx[7:0]};
			bh: s_register_value = {24'b0,r_ebx[15:8]};
			bw: s_register_value = {16'b0,r_ebx[31:16]};
			bs: s_register_value = {24'b0,r_ebx[23:16]};
			bp: s_register_value = {24'b0,r_ebx[31:24]};

			// ECX REGISTERs
			ecx: s_register_value = r_ecx;
			cx: s_register_value = {16'b0,r_ecx[15:0]};
			cl: s_register_value = {24'b0,r_ecx[7:0]};
			ch: s_register_value = {24'b0,r_ecx[15:8]};
			cw: s_register_value = {16'b0,r_ecx[31:16]};
			cs: s_register_value = {24'b0,r_ecx[23:16]};
			cp: s_register_value = {24'b0,r_ecx[31:24]};

			// EDX REGISTERs
			edx: s_register_value = r_edx;
			dx: s_register_value = {16'b0,r_edx[15:0]};
			dl: s_register_value = {24'b0,r_edx[7:0]};
			dh: s_register_value = {24'b0,r_edx[15:8]};
			dw: s_register_value = {16'b0,r_edx[31:16]};
			ds: s_register_value = {24'b0,r_edx[23:16]};
			dp: s_register_value = {24'b0,r_edx[31:24]};

			// TOP_STACK
			STACK_TOP_REG: s_register_value = STACK_TOP;
			STACK_AMOUNT_REG: s_register_value = {16'b0,STACK_AMOUNT};

			default: s_register_value = 32'b0;

		endcase

	end



  always@(*) begin
		case (t_register_code)
		
			// CUSTOM REGISTERs
			clk: t_register_value = {28'b0,r_clk[3:0]};
			esp: t_register_value = {16'b0,r_esp[15:0]};
			src: t_register_value = {31'b0,r_src};
			k: t_register_value = {16'b0,r_k[15:0]};

			// EAX REGISTERs
			eax: t_register_value = r_eax;
			ax: t_register_value = {16'b0,r_eax[15:0]};
			al: t_register_value = {24'b0,r_eax[7:0]};
			ah: t_register_value = {24'b0,r_eax[15:8]};
			aw: t_register_value = {16'b0,r_eax[31:16]};
			as: t_register_value = {24'b0,r_eax[23:16]};
			ap: t_register_value = {24'b0,r_eax[31:24]};

			// EBX REGISTERs
			ebx: t_register_value = r_ebx;
			bx: t_register_value = {16'b0,r_ebx[15:0]};
			bl: t_register_value = {24'b0,r_ebx[7:0]};
			bh: t_register_value = {24'b0,r_ebx[15:8]};
			bw: t_register_value = {16'b0,r_ebx[31:16]};
			bs: t_register_value = {24'b0,r_ebx[23:16]};
			bp: t_register_value = {24'b0,r_ebx[31:24]};

			// ECX REGISTERs
			ecx: t_register_value = r_ecx;
			cx: t_register_value = {16'b0,r_ecx[15:0]};
			cl: t_register_value = {24'b0,r_ecx[7:0]};
			ch: t_register_value = {24'b0,r_ecx[15:8]};
			cw: t_register_value = {16'b0,r_ecx[31:16]};
			cs: t_register_value = {24'b0,r_ecx[23:16]};
			cp: t_register_value = {24'b0,r_ecx[31:24]};

			// EDX REGISTERs
			edx: t_register_value = r_edx;
			dx: t_register_value = {16'b0,r_edx[15:0]};
			dl: t_register_value = {24'b0,r_edx[7:0]};
			dh: t_register_value = {24'b0,r_edx[15:8]};
			dw: t_register_value = {16'b0,r_edx[31:16]};
			ds: t_register_value = {24'b0,r_edx[23:16]};
			dp: t_register_value = {24'b0,r_edx[31:24]};

			// TOP_STACK
			STACK_TOP_REG: t_register_value = STACK_TOP;
			STACK_AMOUNT_REG: t_register_value = {16'b0,STACK_AMOUNT};

			default: t_register_value = 32'b0;

		endcase

	end


endmodule
