module UNPOOLING #(
parameter SIZE = 4'd8)(
input clk,
input reset_n,
input unpool_start,
input [2:0] history_value,
input [15:0] pooled_value,

output reg [15:0] unpooled_value,
output reg unpool_end,
output reg out_end
);

`include "bits_required.v"

parameter NBITS_i = bits_required(SIZE);
parameter NBITS_j = bits_required(2*SIZE);

reg signed [15:0] unpooled [(2*SIZE - 1): 0][(2*SIZE - 1):0];
reg signed [15:0] pooled [(SIZE - 1):0][(SIZE - 1):0];
reg signed [2:0] history [(SIZE - 1):0][(SIZE - 1):0];
reg signed [NBITS_i:0] small_i, small_j;
reg signed [NBITS_j:0] large_i, large_j, out_i, out_j;

always @(posedge clk or negedge reset_n)
begin : UNPOOL
    if (!reset_n) begin
        for (large_i = 0; large_i < 2*SIZE; large_i = large_i + 1) begin
            for (large_j = 0; large_j < 2*SIZE; large_j = large_j + 1) begin
                unpooled[large_i][large_j] <= 1'b0;
            end
        end
    end else begin
        if (unpool_start) begin
            if (small_i >= 0) begin
                if (small_i < SIZE) begin
                    if (small_j < SIZE) begin
                        pooled[small_i][small_j] <= pooled_value;
                        history[small_i][small_j] <= history_value;
                        small_j <= small_j + 1'b1;
                        if (small_j == SIZE - 1) begin
                            small_j <= 1'b0;
                            small_i <= small_i + 1'b1;
                        end
                    end
                //unpooling
                end else begin
                    if (large_i < (2*SIZE - 1)) begin
                        if (large_j < (2*SIZE - 1)) begin
                            if ((history[(large_i>>1)][(large_j>>1)] == 3'd0) | (history[(large_i>>1)][(large_j>>1)] == 3'd1)) begin
                                unpooled[large_i][large_j + history[(large_i>>1)][(large_j>>1)]] 
                                    <= pooled[(large_i>>1)][(large_j>>1)];
                            end else begin
                                unpooled[large_i + 1][large_j + history[(large_i>>1)][(large_j>>1)]-2] 
                                    <= pooled[(large_i>>1)][(large_j>>1)];
                            end
                            if (large_j == 2*SIZE - 2) begin
                                large_j <= 1'b0;
                                large_i <= large_i + 2'd2;
                                if(large_i == 2*SIZE - 2) begin
                                    unpool_end <= 1'b1;
                                end
                            end else begin
                                large_j <= large_j + 2'b10;
                            end
                        end
                    //output
                    end else begin
                        if (out_i < 2*SIZE) begin
                            if(out_j <2*SIZE) begin
                                unpooled_value <= unpooled[out_i][out_j];
                                out_j <= out_j + 1'b1;
                                if (out_j == (2*SIZE - 1)) begin
                                    out_j <= 1'b0;
                                    out_i <= out_i + 1'b1;
                                end
                            end
                        end else begin
                            out_end <= 1'b1;
                        end
                    end
                end
            end else begin
                {small_j, large_i, large_j, out_i, out_j} <= 1'b0;
                small_i <= small_i + 1'b1;
            end
        end else begin
            {small_j, large_i, large_j, out_i, out_j} <= -1'b1;
            small_i <= -1'd1;
            {out_end, unpool_end} <= 1'b0;
        end
    end
end

endmodule