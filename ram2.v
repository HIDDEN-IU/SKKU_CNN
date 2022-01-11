module ram2 #(
parameter FRT_CELL = 10,
parameter BCK_CELL = 5)(
input [15:0] data,
input [15:0] addr,
input we,
input clk,
input reset_n,
output [15:0] q
);

// Declare the RAM variable
reg [15:0] ram[65535:0];

// Variable to hold the registered read address
reg [15:0] addr_reg;

reg [15:0] i;

always @ (posedge clk or negedge reset_n)
begin
// Write
	if (!reset_n) begin
		for (i=FRT_CELL; i<(FRT_CELL * BCK_CELL + FRT_CELL); i = i+1) begin
			ram[i] <= -250 + 10*(i-FRT_CELL);
		end
	end else begin
		if (we) begin
			ram[addr] <= data;
		end
		addr_reg <= addr;
	end
end

assign q = ram[addr_reg];

endmodule
