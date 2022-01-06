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
reg [7:0] i, j, count, count_end, row, col, addr_reg;
reg [2:0] pass;
reg done;

always @ (posedge clk or negedge reset_n)
begin : OUT_GEN
    if (~ reset_n) begin
        i <= 0;
        j <= 0;
        pass <= 0;
        addr_reg <= 0;
        count <= 0;
        count_end <= 0;
        row <= 0;
        col <= 0;
        done <= 0;
    end else if (en_reg) begin
        if (j == n+n-1) begin
            input_arr[i][j] <= conv_out;
            pass <= pass + 1;
            if (pass == 2) begin
                i <= i + 1;
                j <= 0;
                pass <= 0;
            end
        end else begin
            j <= j + 1;
            input_arr[i][j] <= conv_out;
        end
    end else if (en_pooling) begin
        if (count_end !== n) begin
            addr_reg <= addr_reg + 1;
            if (count == 0) begin
                row <= 0;
                col <= 0;
                count <= count + 1;
            end else if (count == n) begin
                row <= row + 2;
                col <= 0;
                count <= 1;
                count_end <= count_end + 1;
            end else begin
                col <= col + 2;
                count <= count + 1;
                if (count_end == n-1 && count == n-1)
                    count_end <= count_end + 1;
            end
        end else
            done <= 1'b1;
    end
end

FIND_MAX MAX (.c11(input_arr[row][col]),
              .c12(input_arr[row][col + 1]),
              .c21(input_arr[row + 1][col]),
              .c22(input_arr[row + 1][col + 1]),
              .pooled_val(pooling_out));

assign addr = addr_reg;
assign done_pooling = done;

endmodule

/*module POOLING_MEMORY (
input clk,
input reset_n
input en,
input [15:0] data,
input [7:0] address,
output [15:0] c11,
output [15:0] c12,
output [15:0] c21, 
output [15:0] c22
);
reg we, en;
reg [7:0] addr_reg_1, addr_reg_2, addr_reg_3, addr_reg_4;
reg [15:0] data_reg;
wire [15:0] c11, c12, c21, c22;

always @ (*)
    if (en) begin
        we = 1;
        data_reg = data;
        addr_reg_1 = address;
        addr_reg_2 = address;
        addr_reg_3 = address;
        addr_reg_4 = address;
    end else begin
        we = 0;

        addr_reg_1 = c11;
        addr_reg_2 = c12;
        addr_reg_3 = c21;
        addr_reg_4 = c22;
    end
end

single_port_ram RAM1 (.data(data_reg), .addr(addr_reg_1), .we(we), .clk(clk), .q(c11));
single_port_ram RAM2 (.data(data_reg), .addr(addr_reg_2), .we(we), .clk(clk), .q(c12));
single_port_ram RAM3 (.data(data_reg), .addr(addr_reg_3), .we(we), .clk(clk), .q(c21));
single_port_ram RAM4 (.data(data_reg), .addr(addr_reg_4), .we(we), .clk(clk), .q(c22));

endmodule*/


module FIND_MAX(
input [15:0] c11,
input [15:0] c12,
input [15:0] c21,
input [15:0] c22,
output [15:0] pooled_val
);

/*parameter pool_len = 2;
reg [7:0] array [0 : pool_len*pool_len - 1];*/

wire [15:0] max_12;
wire [15:0] max_123;

assign max_12 = c11>=c12 ? c11:c12;
assign max_123 = max_12>=c21 ? max_12:c21; 
assign pooled_val = max_123>=c22 ? max_123:c22;

/*function [7:0] MAX(
    input [7:0] A, B
);
begin
    if (A > B)
        MAX = A;
    else
        MAX = B;
end
endfunction*/

endmodule