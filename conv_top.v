module CONV_TOP #(
parameter IMG = 6'd7,
parameter PAD  = 6'd1 )(
input clk,
input rst_n,
input i_load,//single clock signal
input w_load,
input signed [15:0] img_in,
output [15:0] pooling_out,
output done_pooling,
output [15:0] addr
);

localparam SIZE = IMG + 2*PAD;

wire pass;
wire signed [15:0] i_out1, i_out2, i_out3, w_out1, w_out2, w_out3;
wire signed [15:0] io1, io2, io3;
wire signed [15:0] result;


wire end_sig, srt_sig, srt_pool;

INPUT #(.IMG(IMG),.PAD(PAD)) INPUT1 (.clk(clk), .load(i_load), .rst_n(rst_n),
                                     .img_in(img_in), .srt_sig(srt_sig),
                                     .out1(i_out1), .out2(i_out2), .out3(i_out3));

WEIGHT WEIGHT1 (.clk(clk), .rst_n(rst_n),
                .load(w_load), .pass(pass),
                .out1(w_out1), .out2(w_out2), .out3(w_out3));

SYS_ARRAY #(.SIZE(SIZE)) SYS1 (.clk(clk), .rst_n(rst_n), .pass(pass), .srt_sig(srt_sig),
                               .in_hrzt1(i_out1), .in_hrzt2(i_out2), .in_hrzt3(i_out3),
                               .in_vrtc1(w_out1), .in_vrtc2(w_out2), .in_vrtc3(w_out3),
                               .result(result), .srt_pool(srt_pool), .end_sig(end_sig));

POOLING #(.n(SIZE/2-1)) POOL1 (.clk(clk), .reset_n(rst_n), .en_reg(srt_pool),
                               .en_pooling(end_sig), .conv_out(result),
                               .pooling_out(pooling_out), .done_pooling(done_pooling), .addr(addr));


endmodule