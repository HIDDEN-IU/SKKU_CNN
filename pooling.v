module POOLING #(
parameter n = 3,
parameter SIZE = n + n)(
input clk,
input reset_n,
input en_reg,
input en_pooling, //pooling enable
input [15:0] conv_out,
output [15:0] pooling_out,
output [5:0] addr,
output [2:0] history,
output done_pooling
);
reg [15:0] input_arr [0:SIZE-1] [0:SIZE-1];
reg [15:0] pooled_val;
reg [5:0] i, j, count, count_end, row, col, addr_reg;
reg [2:0] pass;
reg done;

reg [15:0] max_12, max_123;
reg [2:0] max_12_his, max_123_his, his_reg;

always @ (posedge clk or negedge reset_n)
begin : OUT_GEN
    if (~ reset_n) begin
        i <= 6'd0;
        j <= 6'd0;
        pass <= 3'd0;
        addr_reg <= 6'd0;
        count <= 6'd0;
        count_end <= 6'd0;
        row <= 6'd0;
        col <= 6'd0;
        done <= 1'b0;
    end else if (en_reg) begin
        if (j == n+n-1) begin
            input_arr[i][j] <= conv_out;
            pass <= pass + 3'd1;
            if (pass == 2) begin
                i <= i + 6'd1;
                j <= 6'd0;
                pass <= 3'd0;
            end
        end else begin
            j <= j + 6'd1;
            input_arr[i][j] <= conv_out;
        end
    end else if (en_pooling) begin
        if (count_end !== n) begin
            if (count == 0) begin
                row <= 6'd0;
                col <= 6'd0;
                count <= count + 1;
                addr_reg <= 6'd0;
            end else if (count == n) begin
                row <= row + 6'd2;
                col <= 6'd0;
                count <= 6'd1;
                count_end <= count_end + 6'd1;
                addr_reg <= addr_reg + 6'd1;
            end else begin
                col <= col + 6'd2;
                count <= count + 6'd1;
                addr_reg <= addr_reg + 6'd1;
                if (count_end == n-1 && count == n-1) begin
                    count_end <= count_end + 6'd1;
                end
            end
        end else begin
            done <= 1'b1;
        end
    end
end

always @ (*)
begin
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

assign pooling_out = pooled_val;
assign history = his_reg;
assign addr = addr_reg;
assign done_pooling = done;

endmodule
