
`timescale 1ns/1ns

module CONV_TOP_TB();

reg clk;

wire [15:0] out1;
wire [15:0] out2;
wire [15:0] out3;

parameter IMG = 8'd14;
parameter PAD = 8'd1;
parameter SIZE = 8'd16;

reg rst_n;

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
reg signed [15:0] img_in;


//end of integer input*/

wire pass;
reg i_load, w_load;
wire signed [15:0] result;
wire signed [15:0] pooling_out;
wire done_pooling;

wire end_sig, srt_sig;

CONV_TOP   #(.IMG(IMG), .PAD(PAD)) CONVTOP1(
                    .clk(clk), .rst_n(rst_n),
                    .i_load(i_load), 
                    .w_load(w_load),
                    .img_in(img_in),
                    .pooling_out(pooling_out),
                    .done_pooling(done_pooling));

initial begin
    forever begin 
        #10 clk = !clk;
    end
end
reg load_reg;
assign load = load_reg;
initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    i_load = 1'b0;
    w_load = 1'b0;
    #80 rst_n = 1'b1;
    #50 w_load = 1'b1;
    #30 w_load = 1'b0;
    #300;
    #40 i_load = 1'b1;
    #30 i_load = 1'b0;
    count = 0;
    for (i = 0; i<SIZE; i = i+1)begin
        for(j = 0; j<SIZE; j = j+1)begin
            img_in = count;
            #20;
            count = count+1;
        end
    end
    #200;
    $stop;
	i
end

endmodule
