`timescale 1ns/1ns

module INPUT_TB();

reg clk;
reg send;

wire [15:0] out1;
wire [15:0] out2;
wire [15:0] out3;

parameter IMG = 8'd14;
parameter PAD = 8'd0;
parameter SIZE = IMG + 2 * PAD;

reg rst_n;

reg [0:SIZE*SIZE*16-1] img;
reg [0:9*16-1] fil;

/*/image input
integer fd;
integer code;
integer i,j;

initial begin
    $readmemh("./trainimage.txt",data);
    $display("read hexa_data:");
    for (i = 0; i<SIZE; i = i+1)begin
        for(j = 0; j<SIZE; j = j+1)begin
            $display("%h",data[i][j]);
        end
    end
    for (i = 0; i<3; i = i+1)begin
        for(j = 0; j<3; j = j+1)begin
            filt [(3*i+j)*16+:8] = count;
            count = count+1;
        end
    end
end
//end of image input*/

//integer input
integer i,j;
integer count;

initial begin
    count = 0;
    for (i = 0; i<SIZE; i = i+1)begin
        for(j = 0; j<SIZE; j = j+1)begin
            img [(SIZE*i+j)*16+:16] = count;
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
//end of integer input*/

wire pass;
INPUT #(.IMG(IMG),.PAD(PAD)) INPUT1 (.clk(clk), .rst_n(rst_n), .pass(pass),
                                     .send(send), .img_in(img), .fil_in(fil),
                                     .out1(out1), .out2(out2), .out3(out3));
initial begin
    clk = 1'b0;
    rst_n = 1'b1;
    send = 1'b0;
    forever begin 
        #10 clk = !clk;
    end
end

initial begin
    #40 rst_n = 1'b0;
    #40 send = 1'b1;
end


endmodule
