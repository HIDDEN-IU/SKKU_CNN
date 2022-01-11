`timescale 1ns/1ns
module TOP_MODULE_FC #(
parameter FRT_CELL = 14,
parameter MID_CELL = 10,
parameter BCK_CELL = 5)(
input clk,
input reset_n,
input enable,               //FC start
input flat_we,              //flatten input write enable
input [15:0] flat_value,    //flatten input data
input [15:0] flat_addr,     //flatten input address
input bck_prop_start,

output all_end,             //signal to controller, FC finished
output fc_bck_prop_end,     //propagation in FC finished
output [15:0] fc_err_prop,  //propagation error from final result
output [15:0] fc_err_addr   //propagation address
);

wire [15:0] re_data, data, addr;
wire fc1_com_end, fc2_com_end, we;

reg [15:0] data_in, addr_in;
reg we_in;

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

FC_MEMORY #(
.FRT_CELL(FRT_CELL),
.MID_CELL(MID_CELL),
.BCK_CELL(BCK_CELL)) FC_MEM(
.clk(clk),
.reset_n(reset_n),

.we(we_in),
.data(data_in),
.addr(addr_in),

.fc1_com_end(fc1_com_end),
.fc2_com_end(fc2_com_end),
.bck_prop_start(bck_prop_start),

.re_data(re_data),
.fc_bck_prop_end(fc_bck_prop_end),
.fc_err_prop(fc_err_prop),
.fc_err_addr(fc_err_addr)
);

always @(*)
begin : DATA_SELECTOR
    case(enable)
        1'b0 : begin
            we_in = flat_we;
            data_in = flat_value;
            addr_in = flat_addr;
        end
        1'b1 : begin
            we_in = we;
            data_in = data;
            addr_in = addr;
        end
        default begin
            we_in = 1'b0;
            data_in = 1'b0;
            addr_in = 1'b0;
        end
    endcase
end

endmodule