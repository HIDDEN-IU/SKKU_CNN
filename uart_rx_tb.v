
module UART_RX_TB();

reg clk, rst_n, s_in;
wire [15:0] s_out;
wire done;
integer i;
parameter clk_per_bit = 8'd21;

UART_RX #(.clk_per_bit(clk_per_bit)) RX (.clk(clk), .rst_n(rst_n), .serial_in(s_in), .serial_out(s_out), .rx_done(done));

initial
begin
    s_in = 1'b1;
    rst_n = 1'b0;
    clk = 1'b0;
    forever #10 clk = !clk;
end

initial
// serial input = 10101100
begin
    #60;
    rst_n = 1'b1;
    #40;
    s_in <= 1'b0;
    for (i = 0; i < clk_per_bit; i = i+1) begin
        @ (posedge clk);
    end
    s_in <= 1'b1;
    for (i = 0; i < clk_per_bit; i = i+1) begin
        @ (posedge clk);
    end
    s_in <= 1'b0;
    for (i = 0; i < clk_per_bit; i = i+1) begin
        @ (posedge clk);
    end
    s_in <= 1'b1;
    for (i = 0; i < clk_per_bit; i = i+1) begin
        @ (posedge clk);
    end
    s_in <= 1'b0;
    for (i = 0; i < clk_per_bit; i = i+1) begin
        @ (posedge clk);
    end
    s_in <= 1'b1;
    for (i = 0; i < clk_per_bit; i = i+1) begin
        @ (posedge clk);
    end
    s_in <= 1'b1;
    for (i = 0; i < clk_per_bit; i = i+1) begin
        @ (posedge clk);
    end
    s_in <= 1'b0;
    for (i = 0; i < clk_per_bit; i = i+1) begin
        @ (posedge clk);
    end
    s_in <= 1'b0;
    for (i = 0; i < clk_per_bit; i = i+1) begin
        @ (posedge clk);
    end
    #60;
    $stop;
end

endmodule