module FC_SINGLE_LAYER #(
parameter FRT_CELL = 10,
parameter BCK_CELL = 5)(
input clk,
input reset_n,
input enable,
input signed [15:0] input_value,

output reg we,	//write enable
output reg [15:0] out,
output reg [15:0] addr,
output reg com_end,		//computation end
output reg layer_end	//layer operation end
);

`include "fixed_mult.v"
`include "ReLU.v"

reg signed [15:0] front_cell [FRT_CELL - 1:0];
reg signed [15:0] weight[BCK_CELL - 1:0][FRT_CELL - 1:0];
reg signed [15:0] back_cell [BCK_CELL - 1:0];

integer i, j, com_i, com_j, front_i, weight_i, weight_j, back_i;
reg [1:0] addr_delay;

always @(posedge clk or negedge reset_n)
begin
	if (!reset_n) begin
		for (i = 0; i < FRT_CELL; i = i + 1) begin
			front_cell[i] <= 1'b0;
		end
		for (i = 0; i < BCK_CELL; i = i + 1) begin
			for (j = 0; j < FRT_CELL; j = j + 1) begin
				weight[i][j] <= 1'b0;
			end
		end
		for (i = 0; i < BCK_CELL; i = i + 1) begin
			back_cell[i] <= 1'b0;
		end
		{com_i, com_j, front_i, weight_i, weight_j, back_i, 
		layer_end, addr_delay, com_end, we} <= 1'b0;
	end else begin
		if (enable) begin
			if (addr_delay == 2'd2) begin
				//input front cell values
				if(front_i < FRT_CELL) begin
					front_cell[front_i] <= input_value;
					front_i <= front_i + 1'b1;
					addr <= addr + 1'b1;
					//initialize address for weight address
					if(front_i == (FRT_CELL - 1'b1)) begin
						addr <= FRT_CELL + 1'b1;
					end
				//input weights
				end else if(weight_i < BCK_CELL) begin
					if (weight_j < FRT_CELL) begin
						weight[weight_i][weight_j] <= input_value;
						weight_j <= weight_j + 1'b1;
						addr <= addr + 1'b1;
						if (weight_j == (FRT_CELL - 1'b1)) begin
							weight_i <= weight_i + 1'b1;
							weight_j <= 1'b0;
							//initialize address for output
							if (weight_i == (BCK_CELL - 1'b1)) begin
								addr <= 1'sb1;
							end
						end
					end
				end else begin
				
					//compute full connected layer
					if(com_i < BCK_CELL) begin
						if(com_j < FRT_CELL) begin
							back_cell[com_i] <= back_cell[com_i] + fixed_mult(front_cell[com_j], weight[com_i][com_j]);
							com_j <= com_j + 1'b1;
						end else begin
							//Comment out the one line below and fixed_mult's shift line if you want to see if it's correct
							back_cell[com_i] <= ReLU(back_cell[com_i]);
							com_i <= com_i + 1'b1;
							com_j <= 1'b0;
							//computation end
							if ((com_i == BCK_CELL - 1) & (com_j == FRT_CELL)) begin
								com_end <= 1'b1;
							end
						end
					end else begin
						//output back cell's values
						if(back_i < BCK_CELL) begin
							out <= back_cell[back_i];
							back_i <= back_i + 1'b1;
							addr <= addr + 1'b1;
							we <= 1'b1;
						end else begin
							//all done
							layer_end <= 1'b1;
							addr_delay <= 1'b0;
							addr <= 1'b0;
							we <= 1'b0;
						end
					end
				end
			//delay 1clock from enable, initialize address 0
			end else begin
				addr_delay <= addr_delay + 1'b1;
				if (addr_delay == 2'b1) begin
					addr <= addr + 1'b1;
				end else begin
				 addr <= 1'b0;
				end
			end
		end
	end
end

endmodule