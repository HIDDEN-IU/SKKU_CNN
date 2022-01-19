module COUNTER_TB();

reg clk, rst_n, enable;

reg [7:0] size;
wire [15:0] address;

COUNTER COUNTER1 (.clk(clk), .rst_n(rst_n), .enable(enable), .size(size), .address(address));

initial begin
    clk = 1'b0;
    forever begin 
        #10 clk = !clk;
    end
end


initial begin
    rst_n = 1'b0;
    enable = 1'b0;
    #50;
    rst_n = 1'b1;
    size = 8'd7;
    enable = 1'b1;
    
    #1000;
    enable = 1'b0;
    size = 8'd14;
    #50;
    enable = 1'b1;
    #5000;
    $stop;
end

endmodule