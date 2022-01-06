module PE_TB();

reg clk;
reg rst_n;

reg signed [15:0] hrzt;
reg signed [15:0] vrtc;

reg pass;

wire signed [15:0] hrzt_out;
wire signed [15:0] vrtc_out;
wire pass_out;

PE PE1 (.clk(clk), .rst_n(rst_n), .hrzt(hrzt), .vrtc(vrtc), 
        .pass(pass), .pass_out(pass_out),
        .hrzt_out(hrzt_out), .vrtc_out(vrtc_out));

initial begin
clk = 1'b0;
rst_n = 1'b1;
pass = 1'b1;
forever #10 clk = ~clk;
end

initial begin

hrzt = 15'sd0;
vrtc = 15'sd0;

#50;
hrzt = 15'sd10;
vrtc = 15'sd10;

#50 pass = 1'b0;

hrzt = 15'sd256;

#50;
vrtc = 15'sd256;

#100;

$stop;

end

endmodule
