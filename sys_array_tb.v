`timescale 1ns/1ns

module SYS_ARRAY_TB ();


parameter SIZE = 8'd14;


//integer input

reg clk, rst_n;
reg i_load, w_load, i_we, w_we;
reg signed [15:0] w_data, i_data;
reg [7:0] size;
wire res_sig;
reg cnt_en;
wire signed [15:0] addr, i_in, w_in, result;

SYS_ARRAY #(
    .SIZE(SIZE)) SYS1 
    (
    .clk    (clk), 
    .rst_n  (rst_n), 
    .i_load (i_load), 
    .w_load (w_load), 
    .i_in   (i_in),
    .w_in   (w_in),
    .result (result), 
    .res_sig(res_sig)
    );
    
MEM #(
    .SIZE(SIZE)) I_MEM1
    (
    .clk    (clk),
    .we     (i_we),
    .data_in(i_data),
    .addr   (addr),
    .data_out(i_in)
    );
    
MEM #(
    .SIZE(3)) W_MEM1
    (
    .clk    (clk),
    .we     (w_we),
    .data_in(w_data),
    .addr   (addr),
    .data_out(w_in)
    );
wire end_sig;
COUNTER COUNTER1 (
    .clk    (clk), 
    .rst_n  (rst_n), 
    .size   (size), 
    .enable (cnt_en), 
    .count  (addr),
    .end_sig(end_sig)
    );
    

integer i,j,c;

initial begin
    //reset
    rst_n = 1'b0;
    w_we = 1'b0;
    i_we = 1'b0;
    i_load = 1'b0;
    w_load = 1'b0;
    cnt_en = 1'b0;
    #50;
    rst_n = 1'b1;

    //weight save
    size = 3;
    c = 1;
    w_we = 1'b1;
    cnt_en = 1'b1;
    for (i = 0; i<3; i = i+1)begin
        for(j = 0; j<3; j = j+1)begin
            w_data = c;
            #20;
            c = c+1;

        end
    end
    cnt_en = 1'b0;
    w_we = 1'b0;
    //input save
    #100;
    c = 0;
    size = 14;
    cnt_en = 1'b1;
    i_we = 1'b1;
    for (i = 0; i<SIZE; i = i+1)begin
        for(j = 0; j<SIZE; j = j+1)begin
            i_data = c;
            #20;
            c = c+1;

        end
    end
    cnt_en = 1'b0;
    i_we = 1'b0;
    #40;
    // weight load 
    w_load = 1'b1;
    size = 3;
    cnt_en = 1'b1;
    #1000;
    w_load = 1'b0;
    cnt_en = 1'b0;
    #30;
    i_load = 1'b1;
    size = 14;
    cnt_en = 1'b1;
    #5000;
    $stop;

end


initial begin
    clk = 1'b0;
    forever #10 clk = !clk;
end

endmodule

