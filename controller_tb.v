`timescale 1ns/1ns

module CONTROLLER_TB ();

reg clk, reset_n, srt,
    w1, i1, s1, r1, p1,
    w2, i2, s2, r2, p2,
    fc1, fc2;

wire wl1, il1, sl1, rl1, pl1,
     wl2, il2, sl2, rl2, pl2,
     sfc1, sfc2, done;

CONTROLLER C1(.clk(clk), .reset_n(reset_n), .start_bit(srt), 
              .done_w_1(w1), .done_i_1(i1), .done_s_1(s1), .done_r_1(r1), .done_p_1(p1),
              .done_w_2(w2), .done_i_2(i2), .done_s_2(s2), .done_r_2(r2), .done_p_2(p2),
              .done_fc_1(fc1), .done_fc_2(fc2), 
              .w_load_1(wl1), .i_load_1(il1), .s_load_1(sl1), .r_load_1(rl1), .p_load_1(pl1),
              .w_load_2(wl2), .i_load_2(il2), .s_load_2(sl2), .r_load_2(rl2), .p_load_2(pl2),
              .srt_fc_1(sfc1), .srt_fc_2(sfc2), .done_fwd(done));

initial begin
    clk = 1'b0;
    reset_n = 1'b0;
    srt = 1'b0;
    forever #10 clk = !clk;
end

initial begin
    # 30 reset_n = 1'b1;
    # 50 srt = 1'b1;
    # 50 w1 = 1'b1;
    # 60 i1 = 1'b1;
    # 50 s1 = 1'b1;
    # 50 r1 = 1'b1;
    # 50 p1 = 1'b1;
    # 50 w2 = 1'b1;
    # 60 i2 = 1'b1;
    # 50 s2 = 1'b1;
    # 50 r2 = 1'b1;
    # 50 p2 = 1'b1;
    # 70 fc1 = 1'b1;
    # 70 fc2 = 1'b1;
end

endmodule