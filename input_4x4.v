
module INPUT_4x4 #(
parameter IMG = 6'd7,
parameter PAD = 6'd1)(
input clk,
input rst_n,
input load,
input  signed [15:0] img_in,
output srt_sig,
output signed [15:0] out1,
output signed [15:0] out2,
output signed [15:0] out3,
output signed [15:0] out4
);

localparam SIZE = IMG + 6'd2*PAD;

//to send output to SA in certain pattern.
reg signed [15:0] out1reg,out2reg,out3reg, out4reg;
reg signed [15:0] out2reg_1delay, out3reg_1delay, out3reg_2delay;
reg signed [15:0] out4reg_1delay, out4reg_2delay, out4reg_3delay;
assign {out1, out2, out3, out4} = {out1reg, out2reg_1delay, out3reg_2delay, out4reg_3delay};

reg srt_reg;
assign srt_sig = srt_reg;

reg end_reg;

//input matrix memory
reg signed [15:0] img [0:SIZE-1][0:SIZE-1];

//counter for img and padded image
reg [7:0] row_img, col_img, row_pad, col_pad;

//for reset
reg [7:0] i,j;

always @(posedge clk or negedge rst_n) begin : SEND
    if (!rst_n) begin
        {row_img, col_img, row_pad, col_pad} <= 32'd0;
        srt_reg <= 1'b0;
        out1reg <= 16'sd0;
        out2reg <= 16'sd0;
        out3reg <= 16'sd0;
        out4reg <= 16'sd0;
        for (i = 0; i<SIZE; i = i + 1)
            for (j = 0; j<SIZE; j = j + 1)
                img[i][j] <= 16'sd0;
    end else begin
        if (!load && end_reg) begin
            {row_img, col_img, row_pad, col_pad} <= 32'd0;
            srt_reg <= 1'b0;
            {out1reg, out2reg, out3reg} <= 16'sd0;
        end else begin
            end_reg <= 1'b1;    
            if (row_img < SIZE) begin
                img[row_img+PAD][col_img+PAD] <= img_in;
                if (col_img == SIZE-1) begin
                    col_img <= 8'd0;
                    row_img <= row_img + 8'd1;
                end else begin
                    col_img <= col_img + 8'd1;
                end
            end
        end
        if (row_img > 3) begin
            if (row_pad < SIZE-3) begin
                srt_reg <= 1'b1;
                out1reg <= img[row_pad  ][col_pad];
                out2reg <= img[row_pad+1][col_pad];
                out3reg <= img[row_pad+2][col_pad];
                out4reg <= img[row_pad+3][col_pad];
                if (col_pad == SIZE-1) begin
                    col_pad <= 8'd0;
                    row_pad <= row_pad + 8'd1;
                end else begin
                    col_pad <= col_pad + 8'd1;
                end
            end else begin
                {out1reg, out2reg, out3reg, out4reg} <= {16'sd0};
            end
        end
    end
    //delay output signals for a certain amount
    out2reg_1delay <= out2reg;
    {out3reg_1delay, out3reg_2delay} <= {out3reg, out3reg_1delay};
    {out4reg_1delay, out4reg_2delay, out4reg_3delay} <= {out4reg, out4reg_1delay, out4reg_2delay};
end
endmodule