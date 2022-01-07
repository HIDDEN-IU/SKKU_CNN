//MAIN MODULE
module MEM_TEST#(
parameter IMG = 6'd7,
parameter PAD = 6'd1)(
input clk,
input rst_n,
input load,//single clock signal
input  signed [15:0] img_in,
output [15:0] addr,
output srt_sig,
output signed [15:0] out1,
output signed [15:0] out2,
output signed [15:0] out3
);

localparam SIZE = IMG + 6'd2*PAD;



//to send output to SA in certain pattern.
reg signed [15:0] out1reg,out2reg,out3reg;
reg signed [15:0] out2reg_1delay, out3reg_1delay, out3reg_2delay;
assign {out1, out2, out3} = {out1reg, out2reg_1delay, out3reg_2delay};

reg srt_reg;
assign srt_sig = srt_reg;

//input matrix memory
reg signed [15:0] img [0:SIZE-1][0:SIZE-1];

//counter for img and padded image
reg [7:0] row_img, col_img, row_pad, col_pad;
assign addr = {row_img, col_img};
//for reset
reg [7:0] i,j;

always @(posedge clk or negedge rst_n) begin : SEND
    if (!rst_n) begin
        {row_img, col_img, row_pad, col_pad} <= 32'hffffffff;
        srt_reg <= 1'b0;

        for (i = 0; i<SIZE; i = i + 1)
            for (j = 0; j<SIZE; j = j + 1)
                img[i][j] <= 16'sd0;
    end else begin
        if (load) begin
            {row_img, col_img, row_pad, col_pad} <= 32'd0;
            srt_reg <= 1'b0;
        end else begin
            if (row_img < IMG) begin
                img[row_img+PAD][col_img+PAD] <= img_in;
                if (col_img == IMG-1) begin
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
    out2reg_1delay <= out2reg;
    {out3reg_1delay, out3reg_2delay} <= {out3reg, out3reg_1delay};
end
endmodule

//MEMORY MODULE
module ARR_MEM #(
parameter ROW = 2'd3,
parameter COL = 2'd3)(
input        clk,
input        we,
input [15:0] data_in,
input [15:0] addr_write,
input [15:0] addr_read,
output[15:0] data_out
);

reg [15:0] data_reg;

assign data_out = data_reg;

reg [7:0] addr_row, addr_col;
reg signed [15:0] ram [0:ROW-1] [ 0:COL-1];

always @(*) begin : MUX
    if (we) begin
        {addr_row, addr_col} = addr_write;
    end else begin
        {addr_row, addr_col} = addr_read;
    end
end

always @ (posedge clk) begin : WRITE
    if (we)
        ram[addr_row][addr_col] <= data_in;
    else
        data_reg <= ram[addr_row][addr_col];
end

endmodule


//Testbench
module MEM_TEST_TB();

parameter IMG = 8'd14;
parameter PAD = 8'd1;
parameter SIZE = 8'd16;

reg rst_n, clk;

wire [15:0] addr_write, addr_read;
reg we;

reg [15:0] count;

reg [7:0] i,j;
assign addr_write = {i,j};
wire [15:0] data_out;
reg [15:0] img_in;

reg i_load;
wire [15:0] out1, out2, out3;

ARR_MEM #(.ROW(IMG), .COL(IMG)) 
        ARR_MEM1(
        .clk(clk), .we(we), 
        .addr_write(addr_write), .addr_read(addr_read),
        .data_in(img_in), .data_out(data_out)
        );
assign data_in_wire = img_in;
        
MEM_TEST #(.IMG(IMG))
        MEM_TEST1(
        .clk(clk), .rst_n(rst_n),
        .load(i_load), .img_in(data_out),
        .addr(addr_read), .srt_sig(srt_sig),
        .out1(out1), .out2(out2), .out3(out3));
   
initial begin : CLK
    clk = 1'b0;
    forever begin 
        #10 clk = !clk;
    end
end

   
initial begin
    rst_n = 1'b0;
    i = 8'd0;
    j = 8'd0;
    i_load = 1'b0;
    count = 16'b0;
    #50;
    
    rst_n = 1'b1;

    we = 1'b1;
    
    for (i = 0; i<IMG; i = i+1)begin
        for(j = 0; j<IMG; j = j+1)begin
            img_in = count;
            #20;
            count = count+1;
        end
    end
    
    we = 1'b0;
    #30;
    i_load = 1'b1;
    #30;
    i_load = 1'b0;
    
end


endmodule