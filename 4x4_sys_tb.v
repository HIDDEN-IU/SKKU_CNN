`timescale 1ns/1ns

module SYS_ARRAY_4x4_TB ();

parameter IMG = 6'd6;
parameter PAD  = 6'd0;

localparam SIZE = IMG + 6'd2 * PAD;

reg [15:0] img;
reg [15:0] weight;
reg clk, rst_n;
reg i_load, w_load;
wire pass, done_w, done_i;
wire signed [15:0] w_out1, w_out2, w_out3, w_out4;
wire signed [15:0] io1, io2, io3, io4;
wire signed [15:0] result;
wire end_sig, srt_sig;

//integer input
integer i,j;
integer count;

INPUT_4x4 #(.IMG(IMG),.PAD(PAD)) INPUT1 (.clk(clk), .rst_n(rst_n), .load(i_load),
                                         .img_in(img), .srt_sig(srt_sig),
                                         .out1(io1), .out2(io2), .out3(io3), .out4(io4));
                                         
WEIGHT_4x4 WEIGHT1 (.clk(clk), .rst_n(rst_n),
                    .load(w_load), .in(weight), .pass(pass),
                    .out1(w_out1), .out2(w_out2), .out3(w_out3), .out4(w_out4), .done_w(done_w));


SYS_ARRAY_4x4 #(.SIZE(SIZE)) SYS1 (.clk(clk), .rst_n(rst_n), .pass(pass), .srt_sig(srt_sig),
                                   .in_hrzt1(io1), .in_hrzt2(io2), .in_hrzt3(io3), .in_hrzt4(io4),
                                   .in_vrtc1(w_out1), .in_vrtc2(w_out2), .in_vrtc3(w_out3), .in_vrtc4(w_out4),
                                   .result(result), .end_sig(end_sig), .done_sig(done_i));

initial begin
    forever #5 clk = !clk;
end

initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    i_load = 1'b0;
    w_load = 1'b0;
    #40 rst_n = 1'b1;
    #60;
    count = 0;
    #20 w_load = 1'b1;
    for (i = 0; i<4; i = i+1) begin
        for (j = 0; j<4; j = j+1) begin
            #10;
            weight = count;
            count = count+1;
        end
    end
    #85 w_load = 1'b0;
    #20 i_load = 1'b1;
    count = 0;
    for (i = 0; i<SIZE; i = i+1) begin
        for(j = 0; j<SIZE; j = j+1) begin
            img = count;
            #10;
            count = count+1;
        end
    end
    #2000 i_load = 1'b0;
    #10000;
    $stop;
end

endmodule
