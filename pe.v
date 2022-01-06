module PE (
input clk,
input rst_n,
input pass, //if 0, stops updating filter value.
input signed [15:0] hrzt,
input signed [15:0] vrtc,
output pass_out,
output signed [15:0] hrzt_out,
output signed [15:0] vrtc_out
);

//multiplier
`include "fixed_mult.v" 

//register holding pass value
reg pass_reg;
assign pass_out = pass_reg;

//registers holding hrzt, vrtc value
reg signed [15:0] hrzt_reg;
reg signed [15:0] vrtc_reg;
assign hrzt_out = hrzt_reg;
assign vrtc_out = vrtc_reg;

//register holding filter value
reg signed [15:0] filt_reg;

//registers holding results
wire signed [15:0] mult_out;
wire signed [15:0] add_out;
assign mult_out = fixed_mult(filt_reg, hrzt);
assign add_out  = mult_out + vrtc;

always @(posedge clk or negedge rst_n) begin : PE_REG
    if (!rst_n) begin
        filt_reg <= 16'sd0;
        pass_reg <= 1'b1;
        hrzt_reg <= 16'sd0;
        vrtc_reg <= 16'sd0;
    end else begin
        if (pass) begin //if 0, filter is fixed.
            filt_reg = vrtc;
        end
        pass_reg <= pass;
        hrzt_reg <= hrzt;
        vrtc_reg <= add_out;
    end
end
endmodule