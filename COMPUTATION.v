module COMPUTATION #(
parameter IMG = 6'd14,
parameter PAD = 6'd1)(
input clk,
input reset_n,
input i_load,
input w_load,
input signed [15:0] img_in,

output [15:0] pooling_out,
output done_pooling,
output [15:0] addr
);

localparam SIZE = IMG + 2*PAD;

wire signed [15:0] i_out1, i_out2, i_out3, w_out1, w_out2, w_out3;
wire signed [15:0] io1, io2, io3;
wire signed [15:0] result;
wire end_sig, srt_sig, srt_poolpass;

INPUT #(
.IMG(IMG),
.PAD(PAD)) in(
.clk(clk),
.rst_n(reset_n),
.load(i_load),//single clock signal
.img_in(img_in),
.srt_sig(srt_sig),

.out1(i_out1),
.out2(i_out2),
.out3(i_out3)
);

WEIGHT weight(
.clk(clk),
.rst_n(reset_n),
.load(w_load),
.pass(pass),

.out1(w_out1),
.out2(w_out2),
.out3(w_out3)
);

SYS_ARRAY #(
.SIZE(SIZE)) sys_array(
.clk(clk),
.rst_n(reset_n),
.pass(pass),
.srt_sig(srt_sig), // start signal
.in_hrzt1(i_out1),
.in_hrzt2(i_out2),
.in_hrzt3(i_out3),
.in_vrtc1(w_out1),
.in_vrtc2(w_out2),
.in_vrtc3(w_out3),

.result(result),
.srt_pool(srt_pool),
.end_sig(end_sig)
);

POOLING #(
.n(SIZE/2-1)) pooling(
.clk(clk),
.reset_n(rst_n),
.en_reg(srt_pool),
.en_pooling(end_sig),

.conv_out(result),
.pooling_out(pooling_out),
.done_pooling(done_pooling),
.addr(addr));

endmodule