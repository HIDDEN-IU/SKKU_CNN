//This is for the 16bit 1:2 demux module.

module one_to_two_demux_16bit #(
parameter BITS = 16
)(a, s, out1, out2);
	input [(BITS-1):0] a;
	input s;	
	output [(BITS-1):0] out1, out2;
	reg [(BITS-1):0] out1, out2;
	
	always@(a or s)
	begin
		if (s == 1'b0)
		begin
			if(a == 8'd0)
			begin
				out1 = 8'b0;
				out2 = 8'b0;
			end
			else
			begin
				out1 = a;
				out2 = 8'b0;
			end
		end

		else
		begin
			if(a == 8'b0)
			begin
				out1 = 8'b0;
				out2 = 8'b0;
			end
			else
			begin
				out1 = 8'b0;
				out2 = a;
			end
		end	
	end

endmodule
