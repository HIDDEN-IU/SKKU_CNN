`timescale 1ns/1ns
//controller : designed by moore machine
module CONTROLLER #(
parameter BATCH_SIZE = 32)(
input clk,
input reset_n,
input start,

//input-----------------//'connected module port name'
input done_conv_weight1,//"input right convolution weight1"
input done_conv_weight2,//"input right convolution weight2"
input done_conv_weight3,//"input right convolution weight3"
input done_fc_weight1,  //"input right FC weight1"
input done_fc_weight2,  //"input right FC weight2"
input done_img_input,   //"input image input"
input done_right_answer,//"input right answer"
input done_layer1,      //
input done_layer2,      //
input done_layer3,      //
input done_fc_fwd,      //'all_end'
input done_fc_bck_prop, //'fc_bck_prop_end'
input done_single_learn,//"convolution back propagation final end"
input done_weight_update,//"when all update done"

//output----------------//'module port name'
output reg conv_weight1,//'weight 6'
output reg conv_weight2,//'weight 16'
output reg conv_weight3,//'weight 32'
output reg fc_weight1,  //'weight1'
output reg fc_weight2,  //'weight2'
output reg img_input,   //'image input'
output reg right_answer,//'right_answer'
output reg srt_layer1,  //
output reg srt_layer2,  //
output reg srt_layer3,  //
output reg srt_fc_fwd,  //'enable'
output reg fc_bp_srt,   //'bck_prop_start'
output reg layer_3,     //convolution back propagation <--------must be change
output reg weight_update//batch end, update start
);

localparam [4:0] INIT = 5'd0;
localparam [4:0] CONV_WEIGHT_1 = 5'd1;
localparam [4:0] CONV_WEIGHT_2 = 5'd2;
localparam [4:0] CONV_WEIGHT_3 = 5'd3;
localparam [4:0] FC_WEIGHT_1 = 5'd4;
localparam [4:0] FC_WEIGHT_2 = 5'd5;
localparam [4:0] INPUT = 5'd6;
localparam [4:0] RIGHT_ANSWER = 5'd7;
localparam [4:0] CONV_LAYER1 = 5'd8;
localparam [4:0] CONV_LAYER2 = 5'd9;
localparam [4:0] CONV_LAYER3 = 5'd10;
localparam [4:0] FC_FWD = 5'd11;
localparam [4:0] FC_BP = 5'd12;
localparam [4:0] LAYER_3 = 5'd13;//<-----------must be change
localparam [4:0] UPDATE = 5'd14;

reg [4:0] state;
reg [4:0] next_state;
wire batch_count;

MAX_COUNTER #(.MAX(BATCH_SIZE)) max_counter(
.clk(done_single_learn), .reset_n(reset_n), .start(start), .out(batch_count));

always @ (*)
begin : STATE_GEN
    case (state)
        INIT : begin
            if (start) next_state = CONV_WEIGHT_1;
            else next_state = next_state;
        end
        CONV_WEIGHT_1 : begin
            if (done_conv_weight1) next_state = CONV_WEIGHT_2;
            else next_state = next_state;
        end
        CONV_WEIGHT_2 : begin
            if (done_conv_weight2) next_state = CONV_WEIGHT_3;
            else next_state = next_state;
        end
        CONV_WEIGHT_3 : begin
            if (done_conv_weight3) next_state = FC_WEIGHT_1;
            else next_state = next_state;
        end
        FC_WEIGHT_1 : begin
            if (done_fc_weight1) next_state = FC_WEIGHT_2;
            else next_state = next_state;
        end
        FC_WEIGHT_2 : begin
            if (done_fc_weight2) next_state = INPUT;
            else next_state = next_state;
        end
        INPUT : begin
            if (done_img_input) next_state = RIGHT_ANSWER;
            else next_state = next_state;
        end
        RIGHT_ANSWER : begin
            if (done_right_answer) next_state = CONV_LAYER1;
            else next_state = next_state;
        end
        CONV_LAYER1 : begin
            if (done_layer1) next_state = CONV_LAYER2;
            else next_state = next_state;
        end
        CONV_LAYER2 : begin
            if (done_layer2) next_state = CONV_LAYER3;
            else next_state = next_state;
        end
        CONV_LAYER3 : begin
            if (done_layer3) next_state = FC_FWD;
            else next_state = next_state;
        end
        FC_FWD : begin
            if (done_fc_fwd) next_state = FC_BP;
            else next_state = next_state;
        end
        FC_BP : begin
            if (done_fc_bck_prop) next_state = LAYER_3;
            else next_state = next_state;
        end
        LAYER_3 : begin
            if (done_single_learn) begin
                if (batch_count) begin
                    next_state = UPDATE;
                end else begin
                    next_state = INPUT;
                end
            end else begin
                next_state = next_state;
            end
        end
        UPDATE : begin
            if (done_weight_update) next_state = INPUT;
            else next_state = next_state;
        end
        default : next_state = INIT;
    endcase
end

always @ (posedge clk or negedge reset_n)
begin : STATE_REG
    if (~reset_n) begin
        state <= INIT;
    end else begin
        state <= next_state;
    end
end

always @ (state)
begin : OUT_GEN
    {conv_weight1, conv_weight2, conv_weight3,
     fc_weight1, fc_weight2, img_input, right_answer,
     srt_layer1, srt_layer2, srt_layer3, srt_fc_fwd,
     fc_bp_srt, layer_3, weight_update} = 1'b0;
    case (state)
        CONV_WEIGHT_1 : conv_weight1 = 1'b1;
        CONV_WEIGHT_2 : conv_weight2 = 1'b1;
        CONV_WEIGHT_3 : conv_weight3 = 1'b1;
        FC_WEIGHT_1   : fc_weight1 = 1'b1;
        FC_WEIGHT_2   : fc_weight2 = 1'b1;
        INPUT         : img_input = 1'b1;
        RIGHT_ANSWER  : right_answer = 1'b1;
        CONV_LAYER1   : srt_layer1 = 1'b1;
        CONV_LAYER2   : srt_layer2 = 1'b1;
        CONV_LAYER3   : srt_layer3 = 1'b1;
        FC_FWD        : srt_fc_fwd = 1'b1;
        FC_BP         : fc_bp_srt = 1'b1;
        LAYER_3       : layer_3 = 1'b1; //<-------must be change
        UPDATE        : weight_update = 1'b1;
    endcase
end

endmodule
