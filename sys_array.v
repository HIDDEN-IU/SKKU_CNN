module SYS_ARRAY #(
parameter SIZE = 6'd7)(
input clk,
input rst_n,
input i_load,
input w_load,
input signed [15:0] i_in,
input signed [15:0] w_in,

output signed [15:0] result,
output res_sig
);

wire pass; 
wire srt_sig;

`include "ReLU6.v"
//wires between PEs and I/O.
wire               pass_wire [1:3][0:3];
wire signed [15:0] in_h      [1:3];
wire signed [15:0] in_v      [1:3];
wire signed [15:0] hrzt_wire [1:3][0:3];
wire signed [15:0] vrtc_wire [1:3][0:3];
wire signed [15:0] out       [1:3];

//used to match timing of operations
reg         [7:1]  srt_sig_delay;
reg signed [15:0] out1_delay [1:4];
reg signed [15:0] out2_delay [1:2];

//iterator to make result
reg [7:0] res_row,res_col;

//final output
reg [15:0] res_reg;
assign result = ReLU6(res_reg);

//makes pooling module to catch data
reg res_sig_reg;
assign res_sig = res_sig_reg;

INPUT #(
    .SIZE(SIZE)) INPUT1 
    (
    .clk(clk),
    .rst_n(rst_n),
    .load(i_load),
    .in(i_in),
    .srt_sig(srt_sig),
    .out1(in_h[1]),
    .out2(in_h[2]),
    .out3(in_h[3])
    );

WEIGHT WEIGHT1 
    (
    .clk(clk),
    .rst_n(rst_n),
    .load(w_load),
    .in(w_in),
    .pass(pass),
    .out1(in_v[1]),
    .out2(in_v[2]),
    .out3(in_v[3])
    );


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
    if (!rst_n) begin
        res_sig_reg <= 1'b0;
        res_row <= 8'd0;
        res_col <= 8'd0;
        res_reg <= 16'sd0;
    end else begin
            $display ("%t",$realtime);
        if (srt_sig_delay[7]) begin //certain time passed after first input
            if (res_row < SIZE-2) begin
                if (res_col < SIZE-2) begin
                    res_sig_reg <= 1'b1;
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
                res_sig_reg <= 1'b0;
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