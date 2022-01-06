module SYS_ARRAY #(
parameter SIZE = 6'd7)(
input clk,
input rst_n,
input pass,
input srt_sig, // start signal
input signed [15:0] in_hrzt1,
input signed [15:0] in_hrzt2,
input signed [15:0] in_hrzt3,
input signed [15:0] in_vrtc1,
input signed [15:0] in_vrtc2,
input signed [15:0] in_vrtc3,
output signed [15:0] result,
output srt_pool,
output end_sig
);

`include "ReLU.v"
//wires between PEs and I/O.
wire               pass_wire [1:3][0:3];
wire signed [15:0] in_h      [1:3];
wire signed [15:0] in_v      [1:3];
wire signed [15:0] hrzt_wire [1:3][0:3];
wire signed [15:0] vrtc_wire [1:3][0:3];
wire signed [15:0] out       [1:3];

//for easier use of input
assign {in_h[1],in_h[2],in_h[3]} = {in_hrzt1, in_hrzt2, in_hrzt3};
assign {in_v[1],in_v[2],in_v[3]} = {in_vrtc1, in_vrtc2, in_vrtc3};

//used to match timing of operations
reg         [7:1]  srt_sig_delay;
reg signed [15:0] out1_delay [1:4];
reg signed [15:0] out2_delay [1:2];

//iterator to make result
reg [7:0] res_row,res_col;

//final output
reg [15:0] res_reg;
assign result = res_reg;

//end indicator
reg end_reg;
assign end_sig = end_reg;

//makes pooling module to catch data
reg srt_pool_reg;
assign srt_pool = srt_pool_reg;

genvar i, j;
generate
    //3*3 = 9 PEs, 3*4 = 12 horizontal wires, 3*4 = 12 vertical wires
    for (i = 1; i <= 3; i = i + 1) begin
        for (j = 1; j <= 3; j = j + 1) begin : PE
            PE PE (.clk(clk), .rst_n(rst_n), 
                   .pass(pass_wire[j][i-1]),
                   .pass_out(pass_wire[j][i]),
                   .hrzt(hrzt_wire[j][i-1]),
                   .hrzt_out(hrzt_wire[j][i]),
                   .vrtc(vrtc_wire[i][j-1]), 
                   .vrtc_out(vrtc_wire[i][j]));
            end
        //assign wires to leftmost or topmost PEs
        assign pass_wire[i][0] = pass;
        assign vrtc_wire[i][0] = in_v[i];
        assign hrzt_wire[i][0] = in_h[i];
        //get output from bottom PEs
        assign out[i] = vrtc_wire[i][3];
    end
endgenerate

always @(posedge clk, negedge rst_n) begin : ACCUMULATOR
    if (!rst_n | pass) begin
        end_reg <= 1'b0;
        res_row <= 8'd0;
        res_col <= 8'd0;
        res_reg <= 16'sd0;
        srt_pool_reg <= 1'b0;
    end else begin
        if (srt_sig_delay[7]) begin //certain time passed after first input
            srt_pool_reg <= 1'b1;
            if (res_row < SIZE-2) begin
                if (res_col < SIZE-2) begin
                    res_reg <= out1_delay[4] + out2_delay[2] + out[3];
                    res_col <= res_col + 8'd1;
                end else if (res_col < SIZE-1) begin //have to rest 2 clocks
                    res_col <= res_col + 8'd1;
                end else begin
                    res_col <= 8'd0;
                    res_row <= res_row + 8'd1;
                end
            end else begin
                //result array is completed.
                srt_pool_reg <= 1'b0;
                end_reg <= 1'b1;
            end
        end
    end
    //delay signals
    srt_sig_delay <= {srt_sig_delay[6:1],srt_sig};

    {out1_delay[1], out1_delay[2], out1_delay[3], out1_delay[4]} <= 
    {out[1],        out1_delay[1], out1_delay[2], out1_delay[3]};

    {out2_delay[1], out2_delay[2]} <= 
    {out[2],        out2_delay[1]};
end
endmodule