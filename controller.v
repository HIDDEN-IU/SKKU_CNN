module CONTROLLER (
input clk,
input reset_n,
input start_bit,
input done_w_1,
input done_i_1,
input done_r_1,
input done_s_1,
input done_p_1,
input done_w_2,
input done_i_2,
input done_r_2,
input done_s_2,
input done_p_2,
input done_fc_1,
input done_fc_2,
output reg w_load_1,
output reg i_load_1,
output reg s_load_1,
output reg r_load_1,
output reg p_load_1,
output reg w_load_2,
output reg i_load_2,
output reg s_load_2,
output reg r_load_2,
output reg p_load_2,
output reg srt_fc_1,
output reg srt_fc_2,
output reg done_fwd
);

localparam [3:0] INIT = 4'd0;
localparam [3:0] weight_1 = 4'd1;
localparam [3:0] input_1 = 4'd2;
localparam [3:0] sys_1 = 4'd3;
localparam [3:0] reg_1 = 4'd4;
localparam [3:0] pooling_1 = 4'd5;
localparam [3:0] weight_2 = 4'd6;
localparam [3:0] input_2 = 4'd7;
localparam [3:0] sys_2 = 4'd8;
localparam [3:0] reg_2 = 4'd9;
localparam [3:0] pooling_2 = 4'd10;
localparam [3:0] FC_1 = 4'd11;
localparam [3:0] FC_2 = 4'd12;
localparam [3:0] DONE = 4'd13;

reg [3:0] state;
reg [3:0] next_state;

always @ (*)
begin : STATE_GEN
    case (state)
        INIT : begin
            if (start_bit) begin
                next_state = weight_1;
            end else begin
                next_state = next_state;
            end
        end
        weight_1 : begin
            if (done_w_1) begin
                next_state = input_1;
            end else begin
                next_state = next_state;
            end
        end
        input_1 : begin
            if (done_i_1) begin
                next_state = sys_1;
            end else begin
                next_state = next_state;
            end
        end
        sys_1 : begin
            if (done_s_1) begin
                next_state = reg_1;
            end else begin
                next_state = next_state;
            end 
        end
        reg_1 : begin
            if (done_r_1) begin
                next_state = pooling_1;
            end else begin
                next_state = next_state;
            end 
        end
        pooling_1 : begin
            if (done_p_1) begin
                next_state = weight_2;
            end else begin
                next_state = next_state;
            end
        end
        weight_2 : begin
            if (done_w_2) begin
                next_state = input_2;
            end else begin
                next_state = next_state;
            end
        end
        input_2 : begin
            if (done_i_2) begin
                next_state = sys_2;
            end else begin
                next_state = next_state;
            end
        end
        sys_2 : begin
            if (done_s_2) begin
                next_state = reg_2;
            end else begin
                next_state = next_state;
            end
        end
        reg_2 : begin
            if (done_r_1) begin
                next_state = pooling_2;
            end else begin
                next_state = next_state;
            end 
        end
        pooling_2 : begin
            if (done_p_2) begin
                next_state = FC_1;
            end else begin
                next_state = next_state;
            end
        end
        FC_1 : begin
            if (done_fc_1) begin
                next_state = FC_2;
            end else begin
                next_state = next_state;
            end
        end
        FC_2 : begin
            if (done_fc_2) begin
                next_state = DONE;
            end else begin
                next_state = next_state;
            end
        end
        DONE : begin
            next_state = INIT;
        end
        default : begin
            next_state = INIT;
        end
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
    case (state)
        INIT : begin
            { w_load_1, i_load_1, s_load_1, r_load_1, p_load_1,
              w_load_2, i_load_2, s_load_2, r_load_2, p_load_2,
              srt_fc_1, srt_fc_2, done_fwd} = {4'd13*{1'b0}};
        end
        weight_1 : begin
            { i_load_1, s_load_1, r_load_1, p_load_1, 
              w_load_2, i_load_2, s_load_2, r_load_2,
              p_load_2, srt_fc_1, srt_fc_2, done_fwd} = {4'd12*{1'b0}};
            w_load_1 = 1'b1;
        end
        input_1 : begin
            { w_load_1, s_load_1, r_load_1, p_load_1, 
              w_load_2, i_load_2, s_load_2, r_load_2,
              p_load_2, srt_fc_1, srt_fc_2, done_fwd} = {4'd12*{1'b0}};
            i_load_1 = 1'b1;
        end
        sys_1 : begin
            { w_load_1, i_load_1, r_load_1, p_load_1, 
              w_load_2, i_load_2, s_load_2, r_load_2,
              p_load_2, srt_fc_1, srt_fc_2, done_fwd} = {4'd12*{1'b0}};
            s_load_1 = 1'b1;
        end
        reg_1 : begin
            { w_load_1, i_load_1, s_load_1, p_load_1, 
              w_load_2, i_load_2, s_load_2, r_load_2,
              p_load_2, srt_fc_1, srt_fc_2, done_fwd} = {4'd12*{1'b0}};
            r_load_1 = 1'b1;
        end
        pooling_1 : begin
            { w_load_1, i_load_1, s_load_1, r_load_1,
              w_load_2, i_load_2, s_load_2, r_load_2,
              p_load_2, srt_fc_1, srt_fc_2, done_fwd} = {4'd12*{1'b0}};
            p_load_1 = 1'b1;
        end
        weight_2 : begin
            { w_load_1, i_load_1, s_load_1, r_load_1,
              p_load_1, i_load_2, s_load_2, r_load_2,
              p_load_2, srt_fc_1, srt_fc_2, done_fwd} = {4'd12*{1'b0}};
            w_load_2 = 1'b1;
        end
        input_2 : begin
            { w_load_1, i_load_1, s_load_1, r_load_1,
              p_load_1, w_load_2, s_load_2, r_load_2,
              p_load_2, srt_fc_1, srt_fc_2, done_fwd} = {4'd12*{1'b0}};
            i_load_2 = 1'b1;
        end
        sys_2 : begin
            { w_load_1, i_load_1, s_load_1, r_load_1,
              p_load_1, w_load_2, i_load_2, r_load_2,
              p_load_2, srt_fc_1, srt_fc_2, done_fwd} = {4'd12*{1'b0}};
            s_load_2 = 1'b1;
        end
        reg_2 : begin
            { w_load_1, i_load_1, s_load_1, r_load_1,
              p_load_1, w_load_2, i_load_2, s_load_2,
              p_load_2, srt_fc_1, srt_fc_2, done_fwd} = {4'd12*{1'b0}};
            r_load_2 = 1'b1;
        end
        pooling_2 : begin
            { w_load_1, i_load_1, s_load_1, r_load_1,
              p_load_1, w_load_2, i_load_2, s_load_2,
              r_load_2, srt_fc_1, srt_fc_2, done_fwd} = {4'd12*{1'b0}};
            p_load_2 = 1'b1;
        end
        FC_1 : begin
            { w_load_1, i_load_1, s_load_1, r_load_1,
              p_load_1, w_load_2, i_load_2, s_load_2,
              r_load_2, p_load_2, srt_fc_2, done_fwd} = {4'd12*{1'b0}};
            srt_fc_1 = 1'b1;
        end
        FC_2 : begin
            { w_load_1, i_load_1, s_load_1, r_load_1,
              p_load_1, w_load_2, i_load_2, s_load_2,
              r_load_2, p_load_2, srt_fc_1, done_fwd} = {4'd12*{1'b0}};
            srt_fc_2 = 1'b1;
        end
        DONE : begin
            { w_load_1, i_load_1, s_load_1, r_load_1, p_load_1,
              w_load_2, i_load_2, s_load_2, r_load_2, p_load_2,
              srt_fc_1, srt_fc_2} = {4'd12*{1'b0}};
            done_fwd = 1'b1;
        end
        default : begin
            { w_load_1, i_load_1, s_load_1, p_load_1, r_load_1,
              w_load_2, i_load_2, s_load_2, p_load_2, r_load_2, 
              srt_fc_1, srt_fc_2, done_fwd} = {4'd13*{1'b0}};
        end
    endcase
end

endmodule
