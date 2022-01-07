module TOP_MODULE_CONV(
input clk,
input reset_n,
input [15:0]img,
output [15:0]result
);

localparam SIZE = IMG + 2*PAD;

wire pass;
wire signed [15:0] i_out1, i_out2, i_out3;
wire signed [15:0] w_out11, w_out12, w_out13;
wire signed [15:0] w_out21, w_out22, w_out23;
wire signed [15:0] w_out31, w_out32, w_out33;
wire signed [15:0] w_out41, w_out42, w_out43;
wire signed [15:0] w_out51, w_out52, w_out53;
wire signed [15:0] w_out61, w_out62, w_out63;
wire signed [15:0] result_1, result_2, result_3, result_4, result_5, result_6;
wire signed [15:0] address_1, address_2, address_3, address_4, address_5, address_6;
wire signed [15:0] addr_pl_1, address_pl_2, address_pl_3, address_pl_4, address_pl_5, address_pl_6;
wire [15:0] ram_1, ram_2, ram_3, ram_4, ram_5, ram_6;

wire end_sig_1, srt_sig_1, srt_pool_1;
wire end_sig_2, srt_sig_2, srt_pool_2;
wire end_sig_3, srt_sig_3, srt_pool_3;
wire end_sig_4, srt_sig_4, srt_pool_4;
wire end_sig_5, srt_sig_5, srt_pool_5;
wire end_sig_6, srt_sig_6, srt_pool_6;


INPUT #(.IMG(IMG),.PAD(PAD)) INPUT1 (.clk(clk), .load(i_load), .rst_n(rst_n),
                                     .img_in(img_in), .srt_sig(srt_sig),
                                     .out1(i_out1), .out2(i_out2), .out3(i_out3));
                            
//CONV_1
WEIGHT WEIGHT1 (.clk(clk), .rst_n(rst_n),
                .load(w_load), .pass(pass),
                .out1(w_out11), .out2(w_out12), .out3(w_out13));

SYS_ARRAY #(.SIZE(SIZE)) SYS1 (.clk(clk), .rst_n(rst_n), .pass(pass), .srt_sig(srt_sig_1),
                               .in_hrzt1(i_out1), .in_hrzt2(i_out2), .in_hrzt3(i_out3),
                               .in_vrtc1(w_out11), .in_vrtc2(w_out12), .in_vrtc3(w_out13),
                               .result(result_1), .addr(address_1), .srt_pool(srt_pool_1), .end_sig(end_sig_1));

single_port_ram RAM1 (.data(result_1), .addr(address_1), .we(we), .clk(clk), .q(ram_1));

POOLING #(.n(SIZE/2-1)) POOL1 (.clk(clk), .reset_n(rst_n), .en_reg(srt_pool),
                               .en_pooling(end_sig), .conv_out(result),
                               .pooling_out(pooling_out), .addr(address_pl_1), .done_pooling(done_pooling));

//CONV_2
WEIGHT WEIGHT2 (.clk(clk), .rst_n(rst_n),
                .load(w_load), .pass(pass),
                .out1(w_out21), .out2(w_out22), .out3(w_out23));

SYS_ARRAY #(.SIZE(SIZE)) SYS2 (.clk(clk), .rst_n(rst_n), .pass(pass), .srt_sig(srt_sig_2),
                               .in_hrzt1(i_out1), .in_hrzt2(i_out2), .in_hrzt3(i_out3),
                               .in_vrtc1(w_out21), .in_vrtc2(w_out22), .in_vrtc3(w_out23),
                               .result(result_2), .addr(address_2), .srt_pool(srt_pool_2), .end_sig(end_sig_2));

single_port_ram RAM2(.data(result_2), .addr(address_2), .we(we), .clk(clk), .q(ram_2));

POOLING #(.n(SIZE/2-1)) POOL2 (.clk(clk), .reset_n(rst_n), .en_reg(srt_pool),
                               .en_pooling(end_sig), .conv_out(result),
                               .pooling_out(pooling_out), .addr(address_pl_2), .done_pooling(done_pooling));

//CONV_3
WEIGHT WEIGHT3 (.clk(clk), .rst_n(rst_n),
                .load(w_load), .pass(pass),
                .out1(w_out1), .out2(w_out2), .out3(w_out3));

SYS_ARRAY #(.SIZE(SIZE)) SYS3 (.clk(clk), .rst_n(rst_n), .pass(pass), .srt_sig(srt_sig),
                               .in_hrzt1(i_out1), .in_hrzt2(i_out2), .in_hrzt3(i_out3),
                               .in_vrtc1(w_out1), .in_vrtc2(w_out2), .in_vrtc3(w_out3),
                               .result(result_3), .addr(address), .srt_pool(srt_pool), .end_sig(end_sig));

single_port_ram RAM3(.data(result), .addr(address), .we(we), .clk(clk), .q(ram_3));

POOLING #(.n(SIZE/2-1)) POOL3 (.clk(clk), .reset_n(rst_n), .en_reg(srt_pool),
                               .en_pooling(end_sig), .conv_out(result),
                               .pooling_out(pooling_out), .done_pooling(done_pooling));

//CONV_4
WEIGHT WEIGHT4 (.clk(clk), .rst_n(rst_n),
                .load(w_load), .pass(pass),
                .out1(w_out1), .out2(w_out2), .out3(w_out3));

SYS_ARRAY #(.SIZE(SIZE)) SYS4 (.clk(clk), .rst_n(rst_n), .pass(pass), .srt_sig(srt_sig),
                               .in_hrzt1(i_out1), .in_hrzt2(i_out2), .in_hrzt3(i_out3),
                               .in_vrtc1(w_out1), .in_vrtc2(w_out2), .in_vrtc3(w_out3),
                               .result(result_4), .addr(address), .srt_pool(srt_pool), .end_sig(end_sig));

single_port_ram RAM4(.data(result), .addr(address), .we(we), .clk(clk), .q(ram_4));

POOLING #(.n(SIZE/2-1)) POOL4 (.clk(clk), .reset_n(rst_n), .en_reg(srt_pool),
                               .en_pooling(end_sig), .conv_out(result),
                               .pooling_out(pooling_out), .done_pooling(done_pooling));

//CONV_5
WEIGHT WEIGHT5 (.clk(clk), .rst_n(rst_n),
                .load(w_load), .pass(pass),
                .out1(w_out1), .out2(w_out2), .out3(w_out3));

SYS_ARRAY #(.SIZE(SIZE)) SYS5 (.clk(clk), .rst_n(rst_n), .pass(pass), .srt_sig(srt_sig),
                               .in_hrzt1(i_out1), .in_hrzt2(i_out2), .in_hrzt3(i_out3),
                               .in_vrtc1(w_out1), .in_vrtc2(w_out2), .in_vrtc3(w_out3),
                               .result(result_5), .addr(address), .srt_pool(srt_pool), .end_sig(end_sig));

single_port_ram RAM5 (.data(result), .addr(address), .we(we), .clk(clk), .q(ram_5));

POOLING #(.n(SIZE/2-1)) POOL5 (.clk(clk), .reset_n(rst_n), .en_reg(srt_pool),
                               .en_pooling(end_sig), .conv_out(result),
                               .pooling_out(pooling_out), .done_pooling(done_pooling));

//CONV_6
WEIGHT WEIGHT6 (.clk(clk), .rst_n(rst_n),
                .load(w_load), .pass(pass),
                .out1(w_out1), .out2(w_out2), .out3(w_out3));

SYS_ARRAY #(.SIZE(SIZE)) SYS6 (.clk(clk), .rst_n(rst_n), .pass(pass), .srt_sig(srt_sig),
                               .in_hrzt1(i_out1), .in_hrzt2(i_out2), .in_hrzt3(i_out3),
                               .in_vrtc1(w_out1), .in_vrtc2(w_out2), .in_vrtc3(w_out3),
                               .result(result_6), .addr(address), .srt_pool(srt_pool), .end_sig(end_sig));

single_port_ram RAM6 (.data(result_6), .addr(address), .we(we), .clk(clk), .q(ram_6));

POOLING #(.n(SIZE/2-1)) POOL6 (.clk(clk), .reset_n(rst_n), .en_reg(srt_pool),
                               .en_pooling(end_sig), .conv_out(result_6),
                               .pooling_out(pooling_out), .done_pooling(done_pooling));


endmodule

endmodule