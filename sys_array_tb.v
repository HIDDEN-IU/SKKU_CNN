`timescale 1ns/1ns

module SYS_ARRAY_TB ();


parameter IMG = 6'd7;
parameter PAD  = 6'd1;

localparam SIZE = IMG + 6'd2 * PAD;

reg [0:IMG*IMG*16-1] img;
reg [0:9*16-1] fil;

//integer input
integer i,j;
integer count;

initial begin
    count = 0;
    for (i = 0; i<IMG; i = i+1)begin
        for(j = 0; j<IMG; j = j+1)begin
            img [(IMG*i+j)*16+:16] = count;
            count = count+1;
        end
    end
    count = 1;
    for (i = 0; i<3; i = i+1)begin
        for(j = 0; j<3; j = j+1)begin
            fil [(3*i+j)*16+:16] = count;
            count = count+1;
        end
    end
end
reg clk, rst_n;
wire pass;
reg send;
wire signed [15:0] io1,io2,io3;

INPUT #(.IMG(IMG),.PAD(PAD)) INPUT1 (.clk(clk), .send(send), .rst_n(rst_n), .pass(pass),
                                     .img_in(img), .fil_in(fil),
                                     .out1(io1), .out2(io2), .out3(io3));
                              
wire [0:(SIZE-2)*(SIZE-2)*16-1] result;
wire end_sig;

SYS_ARRAY #(.SIZE(SIZE)) SYS1 (.clk(clk), .rst_n(rst_n), .pass(pass),
                               .in1(io1), .in2(io2), .in3(io3),
                               .result(result), .end_sig(end_sig));

initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    send = 1'b0;
    forever #10 clk = !clk;
end

initial begin
    #30;
    rst_n = 1'b1;
    #30;
    send = 1'b1;
    @(posedge end_sig);
    #100;
    $stop;
end

endmodule

