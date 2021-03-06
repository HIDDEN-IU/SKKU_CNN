module FCs #(
parameter FRT_CELL = 32,
parameter MID_CELL = 20,
parameter BCK_CELL = 10)(
input clk,
input reset_n,
input enable,
input [15:0] input_value,

output all_end,
output we,
output [15:0] data,
output [15:0] addr,
output fc1_com_end,
output fc2_com_end
);

wire [15:0] value1, value2;
wire [15:0] data1, data2;
wire [15:0] addr1, addr2;
wire layer_end, we1, we2;

one_to_two_demux_16bit demux1(.a(input_value), .s(layer_end), .out1(value1), .out2(value2));

two_to_one_mux_16_bit mux1(.a(data1), .b(data2), .s(layer_end), .out(data));
two_to_one_mux_16_bit mux2(.a(addr1), .b(addr2), .s(layer_end), .out(addr));
two_to_one_mux_16_bit #(.BITS(1)) mux3(.a(we1), .b(we2), .s(layer_end), .out(we));

FC_SINGLE_LAYER #(
.FRT_CELL(FRT_CELL),
.BCK_CELL(MID_CELL)) FC1(
.clk(clk),
.reset_n(reset_n),
.enable(enable),
.input_value(value1),

.we(we1),
.out(data1),
.addr(addr1),
.com_end(fc1_com_end),
.layer_end(layer_end)
);

FC_SINGLE_LAYER #(
.FRT_CELL(MID_CELL),
.BCK_CELL(BCK_CELL)) FC2(
.clk(clk),
.reset_n(reset_n),
.enable(layer_end),
.input_value(value2),

.we(we2),
.out(data2),
.addr(addr2),
.com_end(fc2_com_end),
.layer_end(all_end)
);

endmodule