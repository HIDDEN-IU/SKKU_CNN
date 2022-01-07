module POOLING #(
parameter n = 3,
parameter SIZE = n + n)(
input clk,
input reset_n,
input en_reg,
input en_pooling, //pooling enable
input [15:0] conv_out,
output [15:0] pooling_out,
output [15:0] addr,
output done_pooling
);
reg [15:0] input_arr [0:SIZE-1] [0:SIZE-1];
reg [15:0] pooled_val;
reg [7:0] i, j, count, count_end, row, col, addr_reg;
reg [2:0] pass;
reg done;

reg [15:0] max_12;
reg [15:0] max_123;

always @ (posedge clk or negedge reset_n)
begin : OUT_GEN
    if (~ reset_n) begin
        i <= 8'd0;
        j <= 8'd0;
        pass <= 3'd0;
        addr_reg <= 8'd0;
        count <= 8'd0;
        count_end <= 8'd0;
        row <= 8'd0;
        col <= 8'd0;
        done <= 1'b0;
    end else if (en_reg) begin
        if (j == n+n-1) begin
            input_arr[i][j] <= conv_out;
            pass <= pass + 3'd1;
            if (pass == 2) begin
                i <= i + 8'd1;
                j <= 8'd0;
                pass <= 3'd0;
            end
        end else begin
            j <= j + 8'd1;
            input_arr[i][j] <= conv_out;
        end
    end else if (en_pooling) begin
        if (count_end !== n) begin
            addr_reg <= addr_reg + 8'd1;
            if (count == 0) begin
                row <= 8'd0;
                col <= 8'd0;
                count <= count + 1;
            end else if (count == n) begin
                row <= row + 8'd2;
                col <= 8'd0;
                count <= 8'd1;
                count_end <= count_end + 8'd1;
            end else begin
                col <= col + 8'd2;
                count <= count + 8'd1;
                if (count_end == n-1 && count == n-1)
                    count_end <= count_end + 8'd1;
            end
        end else
            done <= 1'b1;
    end
end

always @ (*)
begin
    if (en_pooling) begin
        max_12 = input_arr[row][col]>=input_arr[row][col + 8'd1] ? input_arr[row][col]:input_arr[row][col + 8'd1];
        max_123 = max_12>=input_arr[row + 8'd1][col] ? max_12:input_arr[row + 8'd1][col];
	pooled_val = max_123>=input_arr[row + 8'd1][col + 8'd1] ? max_123:input_arr[row + 8'd1][col + 8'd1];
    end else begin
	pooled_val = 0;
    end
end

assign pooling_out = pooled_val;
assign addr = addr_reg;
assign done_pooling = done;

endmodule