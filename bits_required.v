function integer bits_required (
    input integer val
);
integer remainder;
begin
    remainder = val;
    bits_required = 0;

    // Iteration for each bit
    while (remainder > 0) begin
        bits_required = bits_required + 1;
        remainder = remainder >> 1;
    end
end
endfunction