`timescale 1ns/1ns

module INPUT_TB();

reg clk, rst_n;
reg i_load, enable;
reg [15:0] count;

wire [15:0] out1;
wire [15:0] out2;
wire [15:0] out3;

wire [15:0] addr;
reg [15:0] w_addr;

reg [7:0] size;

parameter IMG = 8'd14;
parameter PAD = 8'd0;
parameter SIZE = IMG + 2 * PAD;

reg [0:SIZE*SIZE*16-1] img;
reg [0:9*16-1] fil;

reg we;
reg signed [15:0] mem_in;
wire signed [15:0] mem_out;

//integer input
reg [7:0] i,j;
reg [15:0] addr;

initial begin
    rst_n = 1'b0;
    i_load = 1'b0;
    size = SIZE;
    we = 1'b0;
    #60;
    rst_n = 1'b1;
// saving weight

// saving input

    we = 1'b1;
    count = 0;
    enable =1'b1;
    for (i = 0; i<SIZE; i = i+1)begin
        for(j = 0; j<SIZE; j = j+1)begin
            w_addr = {i,j};
            #20;
            count = count+1;
        end
    end
    we = 1'b0;
    enable = 1'b0;
    #40;
// load input
    i_load = 1'b1;
    enable = 1'b1;
    
/*     count = 1;
    for (i = 0; i<3; i = i+1)begin
        for(j = 0; j<3; j = j+1)begin
            fil [(3*i+j)*16+:16] = count;
            count = count+1;
        end
    end */
    
    #5000;
    
    $stop;

end
//end of integer input*/

wire srt_sig;

INPUT #(.SIZE(SIZE)) INPUT1 (.clk(clk), .rst_n(rst_n), .srt_sig(srt_sig),
                                     .load(i_load), .img_in(mem_out),
                                     .out1(out1), .out2(out2), .out3(out3));
                                     
MEM #(.SIZE(SIZE)) I_MEM (.clk(clk), .addr(addr), .data_in(count), .data_out(mem_out),
                    .we(we));


COUNTER COUNTER1 (.clk(clk), .rst_n(rst_n), .size(size), .enable(enable), .address(addr));

initial begin
    clk = 1'b0;
    forever begin 
        #10 clk = !clk;
    end
end

endmodule