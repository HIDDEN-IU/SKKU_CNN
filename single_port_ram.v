module single_port_ram #(
parameter FRT_CELL = 10,
parameter BCK_CELL = 5)(
input [15:0] data,
input [15:0] addr,
input we,
input clk,
output [15:0] q
);

`include "bits_required.v"

// Declare the RAM variable
reg [15:0] ram[65535:0];

// Variable to hold the registered read address
reg [15:0] addr_reg;

always @ (posedge clk)
begin
// Write
	if (we)
		ram[addr] <= data;
	
	addr_reg <= addr;
end
	
// Continuous assignment implies read returns NEW data.
// This is the natural behavior of the TriMatrix memory
// blocks in Single Port mode.  
assign q = ram[addr_reg];

endmodule
