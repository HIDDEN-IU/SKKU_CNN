module FCs #(
parameter FRT_CELL = 32,
parameter MID_CELL = 20,
parameter BCK_CELL = 10)(
input clk,
input reset_n,
input enable,
input [15:0] input_value,
//input fc_bck_prop_end,

output all_end,
output reg we,
output reg [15:0] data,
output reg [15:0] addr,
output fc1_com_end,
output fc2_com_end
);

reg [15:0] value1, value2;
wire [15:0] data1, data2;
wire [15:0] addr1, addr2;
wire layer_end, we1, we2;


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

always @(*)
begin : demux1
    case(layer_end)
        1'b0 : begin
            value1 = input_value;
            value2 = 1'b0;
        end
        1'b1 : begin
            value2 = input_value;
            value1 = 1'b0;
        end
        default begin
            value1 = 1'b0;
            value2 = 1'b0;
        end
    endcase
end

always @(*)
begin : mux1
    case(layer_end)
        1'b0 : begin
            we = we1;
            data = data1;
            addr = addr1;
        end
        1'b1 : begin
            we = we2;
            data = data2;
            addr = addr2;
        end
        default begin
            we = 1'b0;
            data = 1'b0;
            addr = 1'b0;
        end
    endcase
end

endmodule