//MEMORY MODULE
module MEM #(
parameter SIZE = 3)(
input        clk,
input        we,
input [15:0] data_in,
input [15:0] addr,
output[15:0] data_out
);

reg signed [15:0] ram [0:SIZE**2 -1];
reg [15:0] addr_reg;
	

always @ (posedge clk) begin : WRITE
    if (we)
        ram[addr] <= data_in;
    addr_reg <= addr;
end

assign data_out = ram[addr_reg];

endmodule