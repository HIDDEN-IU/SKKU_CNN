module WEIGHT(
input clk,
input rst_n,
input load,
input signed [15:0] in,
output pass,
output signed [15:0] out1,
output signed [15:0] out2,
output signed [15:0] out3
);

reg [1:0] row, col;
reg load_reg;


reg pass_reg;
assign pass = pass_reg;

reg signed [15:0] filt [0:2][0:2];
reg signed [15:0] out1reg, out2reg, out3reg;
reg signed [15:0] out2reg_1delay, out3reg_1delay, out3reg_2delay;
assign {out1, out2, out3} = {out1reg, out2reg_1delay, out3reg_2delay};

reg [3:0] count;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 4'd0;
        pass_reg <= 1'd0;
        row <= 2'd0;
        col <= 2'd0;
        {out1reg, out2reg, out3reg} <= {2'd3*{16'sd0}};
    end else begin
        if (!load_reg) begin
            count <= 4'b0;
            pass_reg <= 1'b0;
            row <= 2'd0;
            col <= 2'd0;
        end else begin
            if (row < 3) begin
                pass_reg <= 1'b1;
                filt[row][col] <= in;
                if (col == 2) begin
                    col <= 2'd0;
                    row <= row + 2'd1;
                end else begin
                    col <= col + 2'd1;
                end
            end else if (count < 4'd3) begin
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
    load_reg <= load;
    out2reg_1delay <= out2reg;
    {out3reg_1delay, out3reg_2delay} <= {out3reg, out3reg_1delay};
end
endmodule