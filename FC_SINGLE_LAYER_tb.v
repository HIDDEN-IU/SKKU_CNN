module FC_SINGLE_LAYER_tb(
);

parameter FRT_CELL = 5'd14;
parameter BCK_CELL = 5'd10;
parameter ADDR_BITS = 10;

reg CLK;
reg RESET_N;
reg ENABLE;

reg signed [15:0] CELL_VALUE;

wire signed [15:0] OUT;
wire [15:0] addr;
wire layer_end, com_end;
wire we;

integer signed i, j;

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

FC_SINGLE_LAYER #(
.FRT_CELL(FRT_CELL),
.BCK_CELL(BCK_CELL)) fc_single_layer(
.clk(CLK),
.reset_n(RESET_N),
.enable(ENABLE),
.input_value(CELL_VALUE),
.we(we),
.out(OUT),
.addr(addr),
.com_end(com_end),
.layer_end(layer_end)
);

initial
begin
	RESET_N = 1'b0; ENABLE = 1'b0;
	#10 RESET_N = 1'b1;
	#10 ENABLE = 1'b1;
	#10;
	for (i = 1; i< 15; i = i+1)
		#10 CELL_VALUE = i;
	for (j = -250; j<250; j=j+3)
		#10 CELL_VALUE = j;
	#2000;
	$stop;
end

endmodule