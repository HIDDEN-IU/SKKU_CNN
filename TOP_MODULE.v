module TOP_MODULE(
input clk,
input reset_n,
input srt,
input [15:0] ex_data,
input [15:0] ex_addr,
input ex_we,
input done_conv_weight1,
input done_conv_weight2,
input done_conv_weight3,
input done_fc_weight1,
input done_fc_weight2,
input done_img_input,
input done_right_answer,

output conv_weight1,
output conv_weight2,
output conv_weight3,
output fc_weight1,
output fc_weight2,
output img_input,
output right_answer
);

parameter FRT_CELL = 32;
parameter MID_CELL = 20;
parameter BCK_CELL = 10;
parameter IMG_SIZE = 18;
parameter BATCH_SIZE = 1;

wire srt_layer1, srt_layer2, srt_layer3,
     srt_fc_fwd, fc_bp_srt, weight_update;
     
wire done_layer1, done_layer2, done_layer3,
     done_fc_fwd, done_fc_bck_prop, done_weight_update;

wire [15:0] fc_err_prop, fc_err_addr, fc_data, fc_addr, flat_out, addr_out;
wire fc_we, we_out;

reg done_single_learn;

CONTROLLER #(
.BATCH_SIZE(BATCH_SIZE)) controller(
.clk(clk),
.reset_n(reset_n),
.start(srt),
.done_conv_weight1(done_conv_weight1),
.done_conv_weight2(done_conv_weight2),
.done_conv_weight3(done_conv_weight3),
.done_fc_weight1(done_fc_weight1),  
.done_fc_weight2(done_fc_weight2),
.done_img_input(done_img_input), 
.done_right_answer(done_right_answer),
.done_layer1(done_layer1),
.done_layer2(done_layer2),
.done_layer3(done_layer3),
.done_fc_fwd(done_fc_fwd),
.done_fc_bck_prop(done_fc_bck_prop),
.done_single_learn(done_single_learn),
.done_weight_update(done_weight_update),

.conv_weight1(conv_weight1),
.conv_weight2(conv_weight2),
.conv_weight3(conv_weight3),
.fc_weight1(fc_weight1),
.fc_weight2(fc_weight2),
.img_input(img_input),
.right_answer(right_answer),
.srt_layer1(srt_layer1),
.srt_layer2(srt_layer2),
.srt_layer3(srt_layer3),
.srt_fc_fwd(srt_fc_fwd),
.fc_bp_srt(fc_bp_srt),
.layer_3(layer_3),
.weight_update(weight_update)
);

TOP_MODULE_CONV #(
.IMG_SIZE(IMG_SIZE)) top_module_conv(
.clk(clk),
.reset_n(reset_n),
.data(ex_data),
.addr(ex_addr),
.we(ex_we),
.conv_weight1(conv_weight1),
.conv_weight2(conv_weight2),
.conv_weight3(conv_weight3),
.img_input(img_input),
.srt_layer1(srt_layer1),
.srt_layer2(srt_layer2),
.srt_layer3(srt_layer3),

.done_layer1(done_layer1),
.done_layer2(done_layer2),
.done_layer3(done_layer3),
.flat_out(flat_out),
.addr_out(addr_out),
.we_out(we_out)
);

TOP_MODULE_FC #(
.FRT_CELL(FRT_CELL),
.MID_CELL(MID_CELL),
.BCK_CELL(BCK_CELL),
.BATCH_SIZE(BATCH_SIZE)) fc_part(
.clk(clk),
.reset_n(reset_n),
.weight1(fc_weight1),
.weight2(fc_weight2),
.right_answer(right_answer),
.enable(srt_fc_fwd),
.ex_we(fc_we),
.ex_value(fc_data),
.ex_addr(fc_addr),
.bck_prop_start(fc_bp_srt),
.batch_end(weight_update),

.all_end(done_fc_fwd),
.fc_bck_prop_end(done_fc_bck_prop),
.fc_batch_end(done_weight_update),
.fc_err_prop(fc_err_prop),
.fc_err_addr(fc_err_addr)
);

always @(posedge clk or negedge reset_n)
begin : LAYER3_GEN
    if (!reset_n) begin
        done_single_learn <= 1'b0;
    end else begin
        if (layer_3) begin
        done_single_learn <= 1'b1;
        end else begin
            done_single_learn <= 1'b0;
        end
    end
end

assign fc_data = !(fc_weight1 | fc_weight2 | right_answer) ? flat_out : ex_data;
assign fc_addr = !(fc_weight1 | fc_weight2 | right_answer) ? addr_out : ex_addr;
assign fc_we = !(fc_weight1 | fc_weight2 | right_answer) ? we_out : ex_we;

endmodule