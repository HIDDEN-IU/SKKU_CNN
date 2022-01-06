//sigmoid approximation 1
module SIGMOID_APPROX_FN(
input reg [15:0] in,
output reg [15:0] out
);

`define FIXED_5        (16'd5 << 8)
`define FIXED_1        (16'd1 << 8)
`define FIXED_2_375    16'h0260
`define FIXED_0_84375  16'h00D8
`define FIXED_0_625    16'h00A0
`define FIXED_0_5      16'h0080

function [15:0] piecewise_sig_stage1(
input [15:0] in
);
	begin
		if(in >= `FIXED_5)
			piecewise_sig_stage1 = `FIXED_1;
		else if ((in >= `FIXED_2_375) && (in < `FIXED_5))
			piecewise_sig_stage1 = (in>>5);
		else if ((in >= `FIXED_1) && (in < `FIXED_2_375))
			piecewise_sig_stage1 = (in>>3);
		else
			piecewise_sig_stage1 = (in>>2);
	end
endfunction

function [15:0] piecewise_sig_stage2(
input [15:0] in,
input [15:0] temp
);
	begin
		if(in >= `FIXED_5)
			piecewise_sig_stage2 = `FIXED_1;
		else if ((in >= `FIXED_2_375) && (in < `FIXED_5)) 
			piecewise_sig_stage2 = temp + `FIXED_0_84375;
		else if ((in >= `FIXED_1) && (in < `FIXED_2_375))
			piecewise_sig_stage2 = temp + `FIXED_0_625;
		else 
			piecewise_sig_stage2 = temp + `FIXED_0_5;
	end
endfunction

reg [15:0] temp1, temp2, result;
reg sign;

always @(in) begin
	temp1 = in[15] ? piecewise_sig_stage1(~in+1) : piecewise_sig_stage1(in);
	temp2 = in[15] ? (~in + 1) : in;
	sign = in[15];
	result = sign ? (`FIXED_1 - piecewise_sig_stage2(temp2, temp1)) : piecewise_sig_stage2(temp2, temp1);
end

always @(*)
begin
	if(result == 0) out = 0;
	else out = result;
end

endmodule


//sigmoid approximation2
/*module SIGMOID_APPROX_DRV(
input [15:0] in,
input clk,
input rst, 
input en,
output [15:0] out
);

wire [15:0] out_saf;

function [15:0] fixed_mult(
input [15:0] a,
input [15:0] b
);
	reg [31:0] a_32,b_32,c_32;
	
	begin
		a_32 = a;
		b_32 = b;
		c_32 = a_32 * b_32;
		c_32 = (c_32 >> 8);
		fixed_mult = c_32[15:0];
	end
endfunction

SIGMOID_APPROX_FN saf(.clk(clk), .rst(rst), .enable(en), .in(in), .out(out_saf));
assign out = fixed_mult(out_saf, (`FIXED_1-out_saf));

endmodule*/