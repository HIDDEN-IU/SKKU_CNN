function [15:0] fixed_mult(
    input signed [15:0] a,b);

    reg signed [31:0] a_32,b_32,c_32;
    begin
        a_32 = a;
        b_32 = b;
        c_32 = a_32*b_32;
       // c_32 = (c_32 >> 8);
        fixed_mult = c_32[15:0];
    end
endfunction