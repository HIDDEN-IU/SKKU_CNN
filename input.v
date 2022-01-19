//input matrix into SA.
module INPUT #(
parameter            SIZE = 7)(

input                clk,
input                rst_n,
input                load,//single clock signal
input  signed [15:0] in,

output               srt_sig,
output signed [15:0] out1,
output signed [15:0] out2, 
output signed [15:0] out3
);

reg load_reg;

//to send output to SA in certain pattern.
reg signed [15:0] out1reg,out2reg,out3reg;
reg signed [15:0] out2reg_1delay, out3reg_1delay, out3reg_2delay;

assign {out1, out2, out3} = {out1reg, out2reg_1delay, out3reg_2delay};

//start signal heading to SA
reg srt_reg;
assign srt_sig = srt_reg;

//input matrix memory
reg signed [15:0] img [0:SIZE-1][0:SIZE-1];

//counter for img and padded image
reg [7:0] row_img, col_img, row_pad, col_pad;

//for reset
reg [7:0] i,j;

always @(posedge clk or negedge rst_n) begin : SEND
    if (!rst_n) begin : RESET
        {row_img, col_img, row_pad, col_pad} <= 32'd0;
        srt_reg <= 1'b0;
        out1reg <= 16'sd0;
        out2reg <= 16'sd0;
        out3reg <= 16'sd0;
    end else begin
        if (!load_reg) begin : WAIT
            {row_img, col_img, row_pad, col_pad} <= 32'd0;
            srt_reg <= 1'b0;
        end else begin
            if (row_img < SIZE) begin
                img[row_img][col_img] <= in;
                if (col_img == SIZE-1) begin
                    col_img <= 8'd0;
                    row_img <= row_img + 8'd1;
                end else begin
                    col_img <= col_img + 8'd1;
                end
            end
        end
        if (row_img > 2) begin
            if (row_pad < SIZE-2) begin
                srt_reg <= 1'b1;
                out1reg <= img[row_pad  ][col_pad];
                out2reg <= img[row_pad+1][col_pad];
                out3reg <= img[row_pad+2][col_pad];
                if (col_pad == SIZE-1) begin
                    col_pad <= 8'd0;
                    row_pad <= row_pad + 8'd1;
                end else begin
                    col_pad <= col_pad + 8'd1;
                end
            end else begin
                {out1reg, out2reg, out3reg} <= {2'd3*{16'sd0}};
            end
        end
    end
    //delay output signals for a certain amount
    load_reg <= load;
    out2reg_1delay <= out2reg;
    {out3reg_1delay, out3reg_2delay} <= {out3reg, out3reg_1delay};
end
endmodule