function [15:0] ReLU(
input [15:0] in
);

begin
	if(in[15] == 1'b1) begin
		ReLU = 1'b0;
	end else if(in[15] == 1'b0) begin
		ReLU = in;
	end else begin
		ReLU = 1'b0;
	end
end

endfunction