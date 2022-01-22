module POOLING #(
parameter n = 3)(
input clk,
input rst_n,
input load,
input [15:0] in,
output [15:0] result,
output [5:0] addr,
output [2:0] history,
output reg_sig,
output done_pl
);

localparam SIZE = n + n;

reg [15:0] input_arr [0:SIZE-1] [0:SIZE-1];
reg [15:0] pooled_val;
reg [5:0] i, j, count, count_end, row, col, addr_reg;
reg [2:0] pass;
reg en_pooling, done_reg;

reg [15:0] max_12, max_123;
reg [2:0] max_12_his, max_123_his, his_reg;

always @ (posedge clk or negedge rst_n)
begin : OUT_GEN
    if (~ rst_n) begin
        i <= 6'd0;
        j <= 6'd0;
        en_pooling = 1'b0;
        pass <= 3'd0;
        addr_reg <= 6'd0;
        count <= 6'd0;
        count_end <= 6'd0;
        row <= 6'd0;
        col <= 6'd0;
        done_reg <= 1'b0;
    end else begin
        done_reg <= 1'b0;
        if (load) begin
            input_arr[i][j] <= in;
            if (j == SIZE-1) begin
                pass <= pass + 3'd1;
                if (pass == 2) begin
                    i <= i + 6'd1;
                    j <= 6'd0;
                    pass <= 3'd0;
                end
                if (i == SIZE - 1) begin
                    en_pooling <= 1'b1;
                end
            end else begin
                j <= j + 6'd1;
            end
        end
        if (en_pooling) begin
            if (count_end < n) begin
                addr_reg <= addr_reg + 6'd1;
                if (count < n-1) begin
                    col <= col + 6'd2;
                    count <= count + 6'd1;
                end else begin
                    row <= row + 6'd2;
                    col <= 6'd0;
                    count <= 6'd0;
                    count_end <= count_end + 6'd1;
                    if (count_end == n-1) begin
                        {row, col, count, count_end} <= 6'd0;
                        en_pooling <= 1'b0;
                        addr_reg <= 6'd0;
                        done_reg <= 1'b1;
                    end
                end
            end else begin
                {row, col, count, count_end} <= 6'd0;
                en_pooling <= 1'b0;
            end
        end
    end
end

always @ (*)
begin : FIND_MAX
    if (en_pooling) begin
        //1st value vs. 2nd value
        {max_12, max_12_his} = input_arr[row][col] >= input_arr[row][col + 6'd1] ?
                              {input_arr[row][col], 3'd0} : {input_arr[row][col + 6'd1], 3'd1};
        //max_12 vs. 3rd value
        {max_123, max_123_his} = max_12 >= input_arr[row + 6'd1][col] ?
                                {max_12, max_12_his} : {input_arr[row + 6'd1][col], 3'd2};
        //max_123 vs. 4th value
        {pooled_val, his_reg} = max_123 >= input_arr[row + 6'd1][col + 6'd1] ? 
                               {max_123, max_123_his} : {input_arr[row + 6'd1][col + 6'd1], 3'd3};
    end else begin
        pooled_val = 15'd0;
        his_reg = 3'd0;
    end
end

assign result = pooled_val;
assign history = his_reg;
assign addr = addr_reg;
assign reg_sig = en_pooling;
assign done_pl = done_reg;

endmodule
