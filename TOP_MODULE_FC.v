`timescale 1ns/1ns
module TOP_MODULE_FC #(
parameter FRT_CELL = 14,
parameter MID_CELL = 10,
parameter BCK_CELL = 5)(
input clk,
input reset_n,
input enable,               //FC start when 1
input ex_we,              //flatten input write enable
input [15:0] ex_value,    //flatten input data
input [15:0] ex_addr,     //flatten input address
input bck_prop_start,       //back propagation start when 1
input batch_end,            //32 mini batch finished
input weight1,              //FC weight1 in when 1
input weight2,              //FC weight2 in when 1
input right_answer,         //final 10 right answer when 1

output all_end,             //signal to controller, FC finished when 1
output fc_bck_prop_end,     //propagation in FC finished when 1
output [15:0] fc_err_prop,  //propagation error from final result
output [15:0] fc_err_addr,   //propagation address
output fc_batch_end
);

wire [15:0] re_data, data, addr;
wire fc1_com_end, fc2_com_end, we;

reg [15:0] data_in, addr_in;
reg we_in, select1, select2;

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

.fc1_com_end(select1),
.fc2_com_end(select2),
.bck_prop_start(bck_prop_start),
.batch_end(batch_end),

.re_data(re_data),
.fc_bck_prop_end(fc_bck_prop_end),
.fc_err_prop(fc_err_prop),
.fc_err_addr(fc_err_addr),
.fc_batch_end(fc_batch_end)
);

always @(*)
begin : DATA_SELECTOR
    case(enable)
        1'b0 : begin
            we_in = ex_we;
            data_in = ex_value;
            addr_in = ex_addr;
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

always @(*)
begin : EX_DATA_ENCODER
    case({fc1_com_end, fc2_com_end, enable, weight1, weight2, right_answer})
        6'b000100 : {select1, select2} = 2'b00;  //weight1 in
        6'b000010 : {select1, select2} = 2'b10;  //weight2 in
        6'b000001 : {select1, select2} = 2'b11;  //right answer in
        6'b001000 : {select1, select2} = 2'b00;  //enable  -> FC start
        6'b101000 : {select1, select2} = 2'b10;  //FC1 computation end, output cell2 value
        6'b111000 : {select1, select2} = 2'b11;  //FC2 computation end, output cell3 value
        default : {select1, select2} = 2'b00;
    endcase
end

endmodule