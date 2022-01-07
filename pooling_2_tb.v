`timescale 1ns/1ns

module pooling_2_tb();

parameter f_size = 4;
parameter LEN = 8;
reg clk, reset, en_reg, en_pooling;
reg [15:0] conv_out;
//wire [15:0] c11, c12, c21, c22;
wire [15:0] result;
wire [15:0] address;
wire done;
integer i;

POOLING #(.n(f_size)) S2 (.clk(clk), .reset_n(reset), .en_reg(en_reg), .en_pooling(en_pooling),
                             .conv_out(conv_out), .pooling_out(result), .addr(address), .done_pooling(done));

initial begin
    clk = 1'b0;
    reset = 1'b0;
    en_reg = 1'b0;
    en_pooling = 1'b0;
    conv_out = 0;
    forever begin 
        #10 clk = !clk;
    end
end

initial begin
    #25 reset = 1'b1;
    #10 en_reg = 1'b1;
    @(posedge clk);
    for (i = 1; i < LEN * LEN + 1; i = i+1) begin
        conv_out = i;
        #20;
        if (i % LEN == 0)begin
            #40;
        end
    end
    en_reg = 1'b0;
    en_pooling = 1'b1;

end

endmodule