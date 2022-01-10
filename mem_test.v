<<<<<<< Updated upstream
//MAIN MODULE
module MEM_TEST(
);



endmodule

//MEMORY MODULE
module ARR_MEM #(
parameter ROW = 2'd3,
parameter COL = 2'd3)(
input        clk,
input        we,
input [15:0] data_in,
input [15:0] addr_write,
input [15:0] addr_read,
output[15:0] data_out
);

reg [7:0] addr_row, addr_col;
reg signed [15:0] ram [0:ROW-1] [ 0:COL-1];

always @(*) begin : MUX
    if (we) begin
        {addr_row, addr_col} = addr_write;
    end else begin
        {addr_row, addr_col} = addr_read;
    end
end

always @ (posedge clk) begin : WRITE
	if (we)
		ram[addr_row][addr_col] <= data_in;
end

endmodule


//Testbench
module MEM_TEST_TB();



endmodule
=======
>>>>>>> Stashed changes
