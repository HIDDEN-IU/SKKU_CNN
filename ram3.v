module ram3 #(
parameter FRT_CELL = 32,
parameter BCK_CELL = 10)(
input [15:0] data,
input [15:0] addr,
input we,
input clk,
input reset_n,

input bck_prop_start,
output [15:0] q,
output error_end,
output [15:0] addr_mem
);

// Declare the RAM variable
reg [15:0] ram[65535:0];

// Variable to hold the registered read address
reg [15:0] addr_reg;

reg signed[15:0] i,back_i;


/*------------------------------------------------
0~9(0~BCK_CELL-1): forward propagation cell result
10~19(BCK_CELL~2*BCK_CELL-1) : accumulated error
20~29(2*BCK_CELL~3*BCK_CELL-1) : first error
30~39(3*BCK_CELL~4*BCK_CELL-1) : second error
40~49(4*BCK_CELL~5*BCK_CELL-1) : third error...
------------------------------------------------*/
always @ (posedge clk or negedge reset_n)
begin
// Write
	if (!reset_n) begin
		for (i=BCK_CELL; i<(2 * BCK_CELL); i = i+1) begin
			ram[i] <= 1'b0;
		end
        //write # at ram[BCK_CELL + #] to correct order,
        //if 5 is correct number, # = 5 - 1 = 4
        ram[2*BCK_CELL + 2] <= (1'b1 << 10) + (1'b1 << 9);
	end else begin
		if (we) begin
			ram[addr] <= data;
		end
		addr_reg <= addr;
        
        if (bck_prop_start) begin
            if ((back_i >= 0) & (back_i < BCK_CELL)) begin
                ram[back_i + BCK_CELL] = ram[back_i + BCK_CELL] + (ram[back_i + 2*BCK_CELL] - ram[back_i]);
                back_i <= back_i + 1'b1;
            end else if (back_i == BCK_CELL) begin
                error_end <= ~error_end;
                addr_reg <= 
                addr_mem <= 
            end else begin
                back_i <= 1'b0;
            end
        end else begin
            back_i <= -1'b1;
            error_end <= 1'b0;
        end
	end
end

assign q = ram[addr_reg];

endmodule
