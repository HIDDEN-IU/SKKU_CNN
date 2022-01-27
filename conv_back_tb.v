`timescale 1ns/1ns
module CONV_BACK_TB();

reg [15:0] img, weight;
reg clk, rst_n, enable;
wire [15:0] result;
wire done;
integer i, j;


CONV_BACK CONV (.clk(clk), .rst_n(rst_n), .en_reg(enable), .in(img), .weight(weight), .result(result), .conv_sig(done));

initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    enable = 1'b0;
    forever #5 clk = ~clk;
end

initial begin
    #45 rst_n = 1'b1;
    #40 enable = 1'b1;
    for (i = 0; i<8; i = i+1) begin
        for (j = 0; j<16; j = j+1) begin
            img = i+j+1;
            weight = 24-(i+j+1);
            #10;
        end
    end
    for (i = 0; i<8; i = i+1) begin
        for (j = 0; j<16; j = j+1) begin
            img = 24-(i+j+1);
            weight = i+j+1;
            #10;
        end
    end
    #20 enable = 1'b0;
    #10000;
    $stop;
end

endmodule