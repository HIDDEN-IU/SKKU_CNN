module MAX_COUNTER #(
parameter MAX = 32)(
input clk,
input reset_n,
input start,
output reg out
);

reg [15:0] count;

always @(posedge clk,negedge reset_n)
begin
    if (!reset_n) begin
        count <= 1'b0;
        out <= 1'b0;
    end else begin
        if (start) begin
            if (count == (MAX - 1)) begin
                out <= 1'b1;
                count<= 1'b0;
            end else begin
                out <= 1'b0;
                count <= count + 1'b1;
            end
        end else begin
            count <= 1'b0;
            out <= 1'b0;
        end
    end
end

endmodule