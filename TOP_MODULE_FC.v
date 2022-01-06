`timescale 1ns/1ns
module TOP_MODULE_FC #(
parameter FRT_CELL = 14,
parameter MID_CELL = 10,
parameter BCK_CELL = 5)(
//input clk,
//input reset_n
);

wire we, we1, we2, we3, we_demux;
wire [15:0] data, data1, data2, data3, data_demux, re_data;
wire [15:0] addr, addr1, addr2, addr3, addr_demux;
wire [15:0] mem_val1, mem_val2, mem_val3, mem_mux;

wire fc1_com_end, fc2_com_end, all_end;
wire enable;

multi_one_to_two_demux #(
.FRT_CELL(FRT_CELL),
.MID_CELL(MID_CELL)) memory_access1(
.we(we),
.data(data),
.addr(addr),
.select(fc1_com_end),

//first MEM
.we1(we1), .data1(data1), .addr1(addr1),
//second, third MEM
.we2(we_demux), .data2(data_demux), .addr2(addr_demux)
);

multi_one_to_two_demux #(
.FRT_CELL(FRT_CELL),
.MID_CELL(MID_CELL)) memory_access2(
.we(we_demux),
.data(data_demux),
.addr(addr_demux),
.select(fc2_com_end),

//second MEM
.we1(we2), .data1(data2), .addr1(addr2),
//third MEM
.we2(we3), .data2(data3), .addr2(addr3)
);

//0 ~ (FRT_CELL-1) : cell value
//FRT_CELL ~ (FRT_CELL + FRT_CELL*MID_CELL - 1) : weight value
ram1 #(
.FRT_CELL(FRT_CELL),
.BCK_CELL(MID_CELL)) MEM1(
.data(data1),
.addr(addr1),
.we(we1),
.clk(clk),
.reset_n(reset_n),
.q(mem_val1)
);

//0 ~ (MID_CELL-1) : cell value
//MID_CELL ~ (MID_CELL + MID_CELL*BCK_CELL - 1) : weight value
ram2 #(
.FRT_CELL(MID_CELL),
.BCK_CELL(BCK_CELL)) MEM2(
.data(data2),
.addr(addr2),
.we(we2),
.clk(clk),
.reset_n(reset_n),
.q(mem_val2)
);

//0 ~ (BCK_CELL-1) : cell value
single_port_ram #(
.FRT_CELL(1),
.BCK_CELL(BCK_CELL)) MEM3(
.data(data3),
.addr(addr3),
.we(we3),
.clk(clk),
.q(mem_val3)
);

two_to_one_mux_16_bit mux_mem23(.a(mem_val2), .b(mem_val3), .s(fc2_com_end), .out(mem_mux));
two_to_one_mux_16_bit mux_mem123(.a(mem_val1), .b(mem_mux), .s(fc1_com_end), .out(re_data));

//FC module
FCs #(
.FRT_CELL(FRT_CELL),
.MID_CELL(MID_CELL),
.BCK_CELL(BCK_CELL)) FCs(
.clk(clk),
.reset_n(reset_n),
.enable(enable),
.input_value(re_data),

.all_end(all_end),
.we(we),
.data(data),
.addr(addr),
.fc1_com_end(fc1_com_end),
.fc2_com_end(fc2_com_end)
);




//-----------------------------------testbench-----------------------------------------
reg CLK;
reg RESET_N;
reg ENABLE;

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

assign clk = CLK;
assign reset_n = RESET_N;
assign enable = ENABLE;

initial
begin
	RESET_N = 1'b0; ENABLE = 1'b0;
	#10 RESET_N = 1'b1;
	#10 ENABLE = 1'b1;
	#5000 $stop;
end

endmodule