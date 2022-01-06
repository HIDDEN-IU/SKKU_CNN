module WEIGHT(
input clk,
input rst_n,
input load,
output pass,
output signed [15:0] out1,
output signed [15:0] out2,
output signed [15:0] out3
);

reg pass_reg;
assign pass = pass_reg;

reg signed [15:0] filt [0:2][0:2];
reg signed [15:0] out1reg, out2reg, out3reg;
reg signed [15:0] out2reg_1delay, out3reg_1delay, out3reg_2delay;
assign {out1, out2, out3} = {out1reg, out2reg_1delay, out3reg_2delay};

reg [3:0] count;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 4'hf;
        pass_reg <= 1'b0;
        {out1reg, out2reg, out3reg} <= {2'd3*{16'sd0}};
        {filt[0][0],filt[0][1],filt[0][2]} = {16'sd1,16'sd2,16'sd3};
        {filt[1][0],filt[1][1],filt[1][2]} = {16'sd4,16'sd5,16'sd6};
        {filt[2][0],filt[2][1],filt[2][2]} = {16'sd7,16'sd8,16'sd9};
    end else begin
        if (load) begin
            count <= 4'b0;
            pass_reg <= 1'b1;
        end else begin
            if (count < 4'd3) begin
                out1reg <= filt[2-count][0];
                out2reg <= filt[2-count][1];
                out3reg <= filt[2-count][2];
                count = count + 4'b1;
            end else begin
                out1reg <= 16'sd0;
                out2reg <= 16'sd0;
                out3reg <= 16'sd0;
                pass_reg <= 1'b0;
            end
        end
    end
    out2reg_1delay <= out2reg;
    {out3reg_1delay, out3reg_2delay} <= {out3reg, out3reg_1delay};
end
endmodule