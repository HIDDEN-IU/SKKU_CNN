`timescale 1ns/1ns

module pooling_2_tb();

parameter f_size = 4;
parameter LEN = 8;
reg clk, reset, en_reg, en_pooling;
reg [15:0] in1 [7:0];
reg [15:0] in2 [7:0];
reg [15:0] in3 [7:0];
reg [15:0] in4 [7:0];
reg [15:0] in5 [7:0];
reg [15:0] in6 [7:0];
reg [15:0] in7 [7:0];
reg [15:0] in8 [7:0];
reg [15:0] conv_out;

wire [15:0] result;
wire [5:0] address;
wire [2:0] his;
wire done;
integer i;

POOLING #(.n(f_size)) S2 (.clk(clk), .reset_n(reset), .en_reg(en_reg), .en_pooling(en_pooling),
                          .conv_out(conv_out), .pooling_out(result), .history(his),
                          .addr(address), .done_pooling(done));

initial begin
    clk = 1'b0;
    reset = 1'b0;
    en_reg = 1'b0;
    en_pooling = 1'b0;
    conv_out = 0;
    in1[0] = 38;
    in1[1] = 34;
    in1[2] = 25;
    in1[3] = 27;
    in1[4] = 19;
    in1[5] = 40;
    in1[6] = 21;
    in1[7] = 9;
    
    in2[0] = 45;
    in2[1] = 12;
    in2[2] = 10;
    in2[3] = 6;
    in2[4] = 30;
    in2[5] = 31;
    in2[6] = 15;
    in2[7] = 44;
    
    in3[0] = 11;
    in3[1] = 7;
    in3[2] = 45;
    in3[3] = 50;
    in3[4] = 22;
    in3[5] = 30;
    in3[6] = 58;
    in3[7] = 20;
    
    in4[0] = 1;
    in4[1] = 15;
    in4[2] = 26;
    in4[3] = 11;
    in4[4] = 38;
    in4[5] = 24;
    in4[6] = 32;
    in4[7] = 37;
    
    in5[0] = 21;
    in5[1] = 2;
    in5[2] = 3;
    in5[3] = 16;
    in5[4] = 13;
    in5[5] = 9;
    in5[6] = 23;
    in5[7] = 36;
    
    in6[0] = 28;
    in6[1] = 20;
    in6[2] = 25;
    in6[3] = 4;
    in6[4] = 31;
    in6[5] = 19;
    in6[6] = 35;
    in6[7] = 10;
    
    in7[0] = 39;
    in7[1] = 14;
    in7[2] = 6;
    in7[3] = 30;
    in7[4] = 18;
    in7[5] = 40;
    in7[6] = 7;
    in7[7] = 34;
    
    in8[0] = 27;
    in8[1] = 29;
    in8[2] = 5;
    in8[3] = 17;
    in8[4] = 12;
    in8[5] = 8;
    in8[6] = 33;
    in8[7] = 22;
    
    forever begin 
        #10 clk = !clk;
    end
end

initial begin
    #25 reset = 1'b1;
    #10 en_reg = 1'b1;
    @(posedge clk);
    for (i = 0; i < LEN; i = i+1) begin
        conv_out = in1[i];
        #20;
    end
    #40;
    
    for (i = 0; i < LEN; i = i+1) begin
        conv_out = in2[i];
        #20;
    end
    #40;
    
    for (i = 0; i < LEN; i = i+1) begin
        conv_out = in3[i];
        #20;
    end
    #40;
    
    for (i = 0; i < LEN; i = i+1) begin
        conv_out = in4[i];
        #20;
    end
    #40;
    
    for (i = 0; i < LEN; i = i+1) begin
        conv_out = in5[i];
        #20;
    end
    #40;
    
    for (i = 0; i < LEN; i = i+1) begin
        conv_out = in6[i];
        #20;
    end
    #40;
    
    for (i = 0; i < LEN; i = i+1) begin
        conv_out = in7[i];
        #20;
    end
    #40;
    
    for (i = 0; i < LEN; i = i+1) begin
        conv_out = in8[i];
        #20;
    end
    #40;
    
    en_reg = 1'b0;
    en_pooling = 1'b1;
end

endmodule


