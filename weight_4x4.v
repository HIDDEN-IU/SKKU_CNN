/*module WEIGHT_4x4(
input clk,
input rst_n,
input load,
output pass,
output signed [15:0] out1,
output signed [15:0] out2,
output signed [15:0] out3,
output signed [15:0] out4
);

reg pass_reg;
assign pass = pass_reg;

reg signed [15:0] filt [0:3][0:3];
reg signed [15:0] out1reg, out2reg, out3reg, out4reg;
reg signed [15:0] out2reg_1delay, out3reg_1delay, out3reg_2delay;
reg signed [15:0] out4reg_1delay, out4reg_2delay, out4reg_3delay;
assign {out1, out2, out3, out4} = {out1reg, out2reg_1delay, out3reg_2delay, out4reg_3delay};

reg [3:0] count;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 4'hf;
        pass_reg <= 1'b0;
        {out1reg, out2reg, out3reg, out4reg} <= {16'sd0};
        {filt[0][0],filt[0][1],filt[0][2], filt[0][3]} <= {16'sd1,16'sd2,16'sd3,16'sd4};
        {filt[1][0],filt[1][1],filt[1][2], filt[1][3]} <= {16'sd5,16'sd6,16'sd7,16'sd8};
        {filt[2][0],filt[2][1],filt[2][2], filt[2][3]} <= {16'sd9,16'sd10,16'sd9,16'sd8};
        {filt[3][0],filt[3][1],filt[3][2], filt[3][3]} <= {16'sd7,16'sd6,16'sd5,16'sd4};
    end else begin
        if (load) begin
            count <= 4'b0;
            pass_reg <= 1'b1;
        end else begin
            if (count < 4'd4) begin
                out1reg <= filt[3-count][0];
                out2reg <= filt[3-count][1];
                out3reg <= filt[3-count][2];
                out4reg <= filt[3-count][3];
                count = count + 4'b1;
            end else begin
                out1reg <= 16'sd0;
                out2reg <= 16'sd0;
                out3reg <= 16'sd0;
                out4reg <= 16'sd0;
                pass_reg <= 1'b0;
            end
        end
    end
    out2reg_1delay <= out2reg;
    {out3reg_1delay, out3reg_2delay} <= {out3reg, out3reg_1delay};
    {out4reg_1delay, out4reg_2delay, out4reg_3delay} <= {out4reg, out4reg_1delay, out4reg_2delay};
end
endmodule*/

module WEIGHT_4x4(
input clk,
input rst_n,
input load,
input signed [15:0] in,
output pass,
output signed [15:0] out1,
output signed [15:0] out2,
output signed [15:0] out3,
output signed [15:0] out4,
output done_w
);

reg [2:0] row, col;
reg load_reg;
reg pass_reg;
reg end_reg;
reg done_reg;
assign pass = pass_reg;

reg signed [15:0] filt [0:3][0:3];
reg signed [15:0] out1reg, out2reg, out3reg, out4reg;
reg signed [15:0] out2reg_1delay, out3reg_1delay, out3reg_2delay;
reg signed [15:0] out4reg_1delay, out4reg_2delay, out4reg_3delay;
reg done_1delay, done_2delay, done_3delay; 
assign {out1, out2, out3, out4} = {out1reg, out2reg_1delay, out3reg_2delay, out4reg_3delay};
assign done_w = done_3delay;

reg [3:0] count;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 4'd0;
        pass_reg <= 1'b0;
        end_reg <= 1'b0;
        done_reg <= 1'b0;
        row <= 2'd0;
        col <= 2'd0;
        {out1reg, out2reg, out3reg, out4reg} <= 16'sd0;
    end else begin
        if (!load_reg) begin
            if (end_reg) begin
                count <= 4'b0;
                pass_reg <= 1'b0;
                row <= 2'd0;
                col <= 2'd0;
            end else begin
                done_reg <= 1'b0;
            end
        end else begin
            end_reg <= 1'b1;
            if (row < 4) begin
                pass_reg <= 1'b1;
                filt[row][col] <= in;
                if (col == 3) begin
                    col <= 2'd0;
                    row <= row + 2'd1;
                end else begin
                    col <= col + 2'd1;
                end
            end else if (count < 4'd4) begin
                out1reg <= filt[3-count][0];
                out2reg <= filt[3-count][1];
                out3reg <= filt[3-count][2];
                out4reg <= filt[3-count][3];
                count = count + 4'b1;
            end else begin
                out1reg <= 16'sd0;
                out2reg <= 16'sd0;
                out3reg <= 16'sd0;
                out4reg <= 16'sd0;
                pass_reg <= 1'b0;
                end_reg <= 1'b0;
                done_reg <= 1'b1;
            end
        end
    end
    load_reg <= load;
    out2reg_1delay <= out2reg;
    {out3reg_1delay, out3reg_2delay} <= {out3reg, out3reg_1delay};
    {out4reg_1delay, out4reg_2delay, out4reg_3delay} <= {out4reg, out4reg_1delay, out4reg_2delay};
    {done_1delay, done_2delay, done_3delay} <= {done_reg, done_1delay, done_2delay};
end
endmodule