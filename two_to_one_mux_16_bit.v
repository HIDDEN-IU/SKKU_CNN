//This is for the 2:1 mux module.

module two_to_one_mux_16_bit #(
parameter BITS = 16
)(a, b, s, out);
	input [(BITS-1):0] a, b;
	input s;
	output [(BITS-1):0] out;
	reg [(BITS-1):0] out;
	
	always@(a or b or s)
	begin
		if (s == 1'b0)
			out = a;
		else
			out = b;
	end

endmodule