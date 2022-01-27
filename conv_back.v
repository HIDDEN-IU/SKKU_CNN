module CONV_BACK #(
parameter SIZE = 5'd16)(
input clk,
input rst_n,
input en_reg, //enable register
input signed [15:0] in, //16x16 input
input signed [15:0] weight, //16x16 weight
output signed [15:0] result,
output conv_sig
);

reg signed [15:0] input_arr [0:SIZE+1][0:SIZE+1]; // 18*18 input register
reg signed [15:0] weight_arr [0:SIZE-1][0:SIZE-1]; // 16*16 weight register
reg [15:0] w_in[0:SIZE-1]; //input for WEIGHT module
reg [15:0] i_in[0:SIZE-1]; //input for INPUT module
reg [4:0] row_i, col_i;
reg [4:0] row_w, col_w;
reg [3:0] state, nextstate; //state register
reg [3:0] x, y, a, b; //for loop variable
reg i_load, w_load; //load signal for input and weight
reg end_reg; //conv_sig register
reg load_reg;

wire [15:0] pass, done_w, done_i; //done signal of weight and input
wire [15:0] srt_sig; // end of INPUT and start SYS_ARRAY
wire [15:0] end_sig; // end of SYS_ARRAY
wire signed [15:0] i_out1 [0:SIZE-1];
wire signed [15:0] i_out2 [0:SIZE-1];
wire signed [15:0] i_out3 [0:SIZE-1];
wire signed [15:0] i_out4 [0:SIZE-1];
wire signed [15:0] w_out1 [0:SIZE-1];
wire signed [15:0] w_out2 [0:SIZE-1];
wire signed [15:0] w_out3 [0:SIZE-1];
wire signed [15:0] w_out4 [0:SIZE-1];
wire signed [15:0] result_reg[0:SIZE-1]; //output of SYS_ARRAY

localparam INIT   = 1;
localparam ARRAY  = 2;
localparam WEIGHT = 3;
localparam IN     = 4;
localparam IMG = 4'd6;
localparam PAD = 4'd0;
integer i, j;

assign conv_sig = end_reg;

always @ (*)
begin : STATE_GEN
    case(state)
        INIT : begin
            if (en_reg) nextstate = ARRAY; 
            else nextstate = nextstate; 
        end
        ARRAY : begin
            if (!en_reg) nextstate = WEIGHT;
            else nextstate = nextstate;
        end
        WEIGHT : begin
            if (done_w) nextstate = IN;
            else nextstate = nextstate;
        end
        IN : begin
            if (done_i) nextstate = INIT;
            else nextstate = nextstate;
        end
        default : begin
            nextstate = INIT;
        end
    endcase
end

        
always @ (posedge clk or negedge rst_n)
begin : VAL_GEN
    state <= nextstate;
    if (~rst_n) begin
        for (i=0;i<=SIZE+1;i=i+1) begin
            for (j=0;j<=SIZE+1;j=j+1) begin
                input_arr[i][j] <= 16'sd0;
            end
        end
        for (i=0;i<=SIZE-1;i=i+1)begin
            for (j=0;j<=SIZE-1;j=j+1) begin
                weight_arr[i][j] <= 16'sd0;
            end
        end
        {col_i, row_i} <= {5'd1, 5'd1}; //starting from 1 because of padding
        {col_w, row_w} <= {5'd0, 5'd0};
        {x, y, a, b} <= 4'd0;
        state <= INIT;
        end_reg <= 1'b0;
        load_reg <= 1'b0;
    end else begin
        if (en_reg) begin
            //Saving 16*16 inputs in register for every clock
            if (row_i <= SIZE) begin
                input_arr[row_i][col_i] <= in;
                if (col_i < SIZE) begin
                    col_i <= col_i + 5'd1;
                end else begin
                    if (row_i !== SIZE) begin
                        row_i <= row_i + 5'd1;
                        col_i <= 5'd1;
                    end
                end
            end 
            //Saving 16*16 weights in register for every clock 
            if (row_w <= SIZE-1) begin
                weight_arr[row_w][col_w] <= weight;
                if (col_w < SIZE-1) begin
                    col_w <= col_w + 5'd1;
                end else begin
                    if (row_w !== SIZE-1) begin
                        row_w <= row_w + 5'd1;
                        col_w <= 5'd0;
                    end
                end
            end
        end else begin
            {row_i, col_i} <= {5'd1, 5'd1};
            {row_w, col_w} <= {5'd0, 5'd0};
        end
        if (w_load) begin
            // 4x4 array weight for each 16 systolic array 
            if (x <= 3) begin
                w_in[0] <= weight_arr[x][y];
                w_in[1] <= weight_arr[x][y+4];
                w_in[2] <= weight_arr[x][y+8];
                w_in[3] <= weight_arr[x][y+12];
                w_in[4] <= weight_arr[x+4][y];
                w_in[5] <= weight_arr[x+4][y+4];
                w_in[6] <= weight_arr[x+4][y+8];
                w_in[7] <= weight_arr[x+4][y+12];
                w_in[8] <= weight_arr[x+8][y];
                w_in[9] <= weight_arr[x+8][y+4];
                w_in[10] <= weight_arr[x+8][y+8];
                w_in[11] <= weight_arr[x+8][y+12];
                w_in[12] <= weight_arr[x+12][y];
                w_in[13] <= weight_arr[x+12][y+4];
                w_in[14] <= weight_arr[x+12][y+8];
                w_in[15] <= weight_arr[x+12][y+12];
                if (y < 3) begin
                    y <= y + 4'd1;
                end else begin
                    if (x !== 3) begin
                        x <= x + 4'd1;
                        y <= 4'd0;
                    end
                end
            end
        end else begin
            x <= 4'd0;
            y <= 4'd0;
        end
        if (i_load) begin
            // 6x6 array input for each 16 systolic array 
            load_reg <= 1'b1;
            if (a <= 5) begin
                i_in[0] <= input_arr[a][b];
                i_in[1] <= input_arr[a][b+4];
                i_in[2] <= input_arr[a][b+8];
                i_in[3] <= input_arr[a][b+12];
                i_in[4] <= input_arr[a+4][b];
                i_in[5] <= input_arr[a+4][b+4];
                i_in[6] <= input_arr[a+4][b+8];
                i_in[7] <= input_arr[a+4][b+12];
                i_in[8] <= input_arr[a+8][b];
                i_in[9] <= input_arr[a+8][b+4];
                i_in[10] <= input_arr[a+8][b+8];
                i_in[11] <= input_arr[a+8][b+12];
                i_in[12] <= input_arr[a+12][b];
                i_in[13] <= input_arr[a+12][b+4];
                i_in[14] <= input_arr[a+12][b+8];
                i_in[15] <= input_arr[a+12][b+12];
                if (b < 5) begin
                    b <= b + 4'd1;
                end else begin
                    if (a !== 5) begin
                        a <= a + 4'd1;
                        b <= 4'd0;
                    end
                end
            end
        end else begin
            a <= 4'd0;
            b <= 4'd0;
            load_reg <= 1'b0;
        end
    end
end

/* Load Generator : w_load = 1 at WEIGHT state
                    i_load = 1 at IN state     */
always @ (state)
begin : LOAD_GEN
    case (state)
        INIT : begin
            w_load = 4'd0;
            i_load = 4'd0;
        end
        ARRAY : begin
            w_load = 4'd0;
            i_load = 4'd0;
        end
        WEIGHT : begin
            w_load = 4'd1;
            i_load = 4'd0;
        end
        IN : begin
            w_load = 4'd0;
            i_load = 4'd1;
            if (done_i) end_reg = 1'b1;
            else end_reg = 1'b0;
        end
        default : begin
            w_load = 4'd0;
            i_load = 4'd0;
        end
    endcase
end

/* Adding results of 16 4x4 systolic arrays */
assign result = result_reg[0]+result_reg[1]+result_reg[2]+result_reg[3]+
                 result_reg[4]+result_reg[5]+result_reg[6]+result_reg[7]+
                 result_reg[8]+result_reg[9]+result_reg[10]+result_reg[11]+
                 result_reg[12]+result_reg[13]+result_reg[14]+result_reg[15];

/* Generating 16 systolic arrays*/
genvar num;
generate
    for (num=0; num<SIZE; num=num+1) begin
    
        WEIGHT_4x4 WEIGHT (.clk(clk), .rst_n(rst_n), .load(w_load), .in(w_in[num]), .pass(pass[num]),
                            .out1(w_out1[num]), .out2(w_out2[num]), .out3(w_out3[num]), .out4(w_out4[num]), .done_w(done_w[num]));

        INPUT_4x4 #(.IMG(IMG),.PAD(PAD)) INPUT (.clk(clk), .rst_n(rst_n), .load(load_reg),
                                                 .img_in(i_in[num]), .srt_sig(srt_sig[num]),
                                                 .out1(i_out1[num]), .out2(i_out2[num]), .out3(i_out3[num]), .out4(i_out4[num]));
                                                                                  
        SYS_ARRAY_4x4 #(.SIZE(6)) SYS (.clk(clk), .rst_n(rst_n), .pass(pass[num]), .srt_sig(srt_sig[num]),
                                           .in_hrzt1(i_out1[num]), .in_hrzt2(i_out2[num]), .in_hrzt3(i_out3[num]), .in_hrzt4(i_out4[num]),
                                           .in_vrtc1(w_out1[num]), .in_vrtc2(w_out2[num]), .in_vrtc3(w_out3[num]), .in_vrtc4(w_out4[num]),
                                           .result(result_reg[num]), .end_sig(end_sig[num]), .done_sig(done_i[num]));
    end
endgenerate

endmodule                             