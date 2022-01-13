module ReLU6_tb(
);

`include "ReLU6.v"

reg CLK;
reg signed [15:0] IN;

wire [15:0] OUT;

initial
begin
CLK = 0;
end

initial
begin
	forever
	begin
		#5 CLK = !CLK;
	end
end

assign OUT = ReLU6(IN);

initial
begin
	IN = 16'h0700;
	#10 IN = 16'h0230;
	#10 IN = 16'h1420;
	#10 IN = 16'ha648;
	#10 IN = 16'h8000;
	#10 IN = 16'h7fff;
	#10 IN = 16'h1997;
	#10 IN = 16'he822;
	#10 IN = 16'h0315;
	#100;
	$stop;
end

endmodule