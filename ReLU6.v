
function [15:0] ReLU6(
input [15:0] in
);
begin
	if(in[15] == 1'b1) begin
		ReLU6 = 1'b0;
    end else if (in >= (16'd1536)) begin
        ReLU6 = 16'd1536;
	end else if(in[15] == 1'b0) begin
		ReLU6 = in;
	end else begin
		ReLU6 = 1'b0;
	end
end
endfunction