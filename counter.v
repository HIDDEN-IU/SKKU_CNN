module COUNTER (
input [7:0] size,
input clk,
input rst_n,
input enable,
output [15:0] count
);

reg [15:0] count_reg;
reg [7:0] row, col;

assign count = count_reg;

always @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin
        count_reg <= 16'd0;
        row <= 8'd0;
        col <= 8'd0;
    end else begin
        if (!enable) begin
            count_reg <= 16'd0;
            row <= 8'd0;
            col <= 8'd0;
        end else begin
            if (row < size-1'b1) begin
                if (col == size) begin
                    row <= row + 1'b1;
                    col <= 8'd0;
                end else begin
                    col <= col + 1'b1;
                end
                    count_reg <= count_reg + 1'b1;
            end
        end
    end
end


endmodule