
module CONTROLLER (
input clk,
input reset_n
input start_bit,
input done_comp_1,
input done_comp_2,
input done_fc_1,
input done_fc_2,
output w_load_1,
output w_load_2,
output srt_fc_1,
output srt_fc_2,
output done_fwd
);

localparam INIT = ;
localparam COMP_1 = ;
localparam COMP_2 = ;
localparam 

reg state;
reg next_state;

always @ (posedge clk or negedge reset_n)
begin : SIG_GEN
    






