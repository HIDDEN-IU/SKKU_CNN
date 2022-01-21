
module COMPUTATION #(
parameter FRT = 6'd14,
parameter PAD = 6'd2)(
input clk,
input reset_n,
input i_load,
input w_load,
input signed [15:0] i_in,
input signed [15:0] w_in,

output [15:0] pool_result,
output [15:0] addr,
output [1:0] history,
output com_end

);

parameter SIZE = FRT + PAD;

wire signed [15:0] sys_result;
wire res_sig;

SYS_ARRAY #(
.SIZE(SIZE)) sys_array(
.clk(clk),
.rst_n(reset_n),
.i_load(i_load),
.w_load(w_load),
.i_in(i_in),
.w_in(w_in),

.result(sys_result),
.res_sig(res_sig)
);

POOLING #(
.SIZE(SIZE/2)) pooling(
.clk(clk),
.rst_n(reset_n),
.load(res_sig),
.in(sys_result),

.result(pool_result),
.addr(addr),
.history(history),
.reg_sig(com_end)
);

endmodule