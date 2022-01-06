module multi_one_to_two_demux #(
parameter FRT_CELL = 120,
parameter MID_CELL = 84)(
input we,
input [15:0]data,
input [15:0]addr,
input select,

output reg we1,
output reg [15:0]data1,
output reg [15:0]addr1,
output reg we2,
output reg [15:0]data2,
output reg [15:0]addr2
);

always @(we or data or addr or select)
begin
	{we1, data1, addr1} = 1'b0;
	{we2, data2, addr2} = 1'b0;
	if (select == 1'b0) begin
		we1 = we;
		data1 = data;
		addr1 = addr;
		
	end	else begin
		we2 = we;
		data2 = data;
		addr2 = addr;
	end	
end


endmodule