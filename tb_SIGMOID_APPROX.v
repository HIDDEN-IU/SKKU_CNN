module SIGMOID_APPROX_tb(
);

reg CLK;
reg RESET_N;
reg ENABLE;
reg [15:0] IN;

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

SIGMOID_APPROX_FN saf(.in(IN),
.out(OUT)
);

initial
begin
	RESET_N = 1'b0;
	#10 RESET_N = 1'b1; ENABLE = 1'b1;
	IN = 16'h0700;
	#10 IN = 16'h0230;
	#10 IN = 16'h1420;
	#10 IN = 16'h0648;
	#10 IN = 16'h8000;
	#10 IN = 16'h7fff;
	#10 IN = 16'h1997;
	#10 IN = 16'h0822;
	#10 IN = 16'h0315;
	#100;
	$stop;
end

endmodule