module FREQ_DIV #(
parameter MAGNIFICATION = 32)(  //MAGNIFICATION must be a multiple of 2. 
input clk,
input reset_n,
output reg out
);

`include "bits_required.v"

localparam NBITS = bits_required(MAGNIFICATION);

reg [NBITS-1:0] q;

always @(posedge clk or negedge reset_n)
begin
    if (!reset_n) begin
        out <= 1'b0;
        q <= 1'b0;
    end else begin
        if (q == ((MAGNIFICATION-1) >> 1)) begin
            out <= ~out;
            q <= 1'b0;
        end else begin
            q <= q + 1'b1;
        end
    end
end

endmodule