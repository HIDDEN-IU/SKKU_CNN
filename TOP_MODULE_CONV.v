module TOP_MODULE_CONV #(
parameter IMG_SIZE = 5'd18)(
input clk,
input reset_n,
input [15:0] data,
input [15:0] addr,
input we,
input conv_weight1,
input conv_weight2,
input conv_weight3,
input img_input,
input srt_layer1,  //
input srt_layer2,  //
input srt_layer3,  //

output done_layer1,      //
output done_layer2,      //
output done_layer3,      //
output reg [15:0] flat_out,
output reg [15:0] addr_out,
output reg we_out
);

//w is for weight
reg [15:0] w_1_addr[0:5], w_1_addr_layer1, w_2_addr [0:15], w_2_addr_layer2, w_3_addr [0:31], w_3_addr_layer3;
reg signed [15:0] w_1_din [0:5], w_2_din[0:15], w_3_din[0:31];
wire signed [15:0] w_1_dout [0:5], w_2_dout [0:15], w_3_dout [0:31];
wire [15:0] i_mem_1_addr [0:5], i_mem_2_addr [0:15];
reg w_1_we [0:5], w_2_we [0:15], w_3_we [0:31];

wire [15:0] pool_result1 [5:0];
wire [15:0] pool_result2 [15:0];

wire signed [15:0] i_1_in;
wire signed [15:0] i_2_in [15:0], i_2_in_m[5:0];
wire signed [15:0] i_3_in, i_3_in_m[15:0];

wire pool_1_end [5:0], done_pool1 [5:0];
wire pool_2_end [15:0], done_pool2 [15:0];
wire layer3_end [31:0];
wire signed [15:0] flat_wire[31:0];

reg signed [7:0] count;
reg [7:0] out_count;
reg done_layer3_reg, done1, done2, done3;
reg w_load_reg1, w_load_reg2, w_load_reg3;
reg i_load_reg1, i_load_reg2, i_load_reg3;
reg signed [15:0] j_1, j_2, j_3, k_1, k_2, k_3, m, n;
reg signed [15:0] flat_reg [31:0];

reg signed [15:0] w_data, i_data;
reg signed [15:0] w_addr, i_addr_1, i_addr_2, i_addr_3, i_addr_a, i_addr_b,
                  i_addr_delay1 [4:0],
                  i_addr_delay2 [4:0],
                  i_addr_delay3 [4:0];
reg w_we, i_we;

genvar i;
generate
    for (i = 0; i < 6; i = i + 1) begin : COM_LAYER1
        COMPUTATION #(
        .FRT(IMG_SIZE),
        .PAD(0)) layer1(
        .clk(clk),
        .reset_n(reset_n),
        .i_load(i_load_reg1),
        .w_load(w_load_reg1),
        .i_in(i_1_in),
        .w_in(w_1_dout[i]),

        .pool_result(pool_result1[i]),
        .addr(i_mem_1_addr[i]),
        .history(),
        .com_end(pool_1_end[i]),
        .done_pool(done_pool1[i])
        );
    end
   
    for (i = 0; i < 16; i = i + 1) begin : COM_LAYER2
        COMPUTATION #(
        .FRT((IMG_SIZE-2)/2),
        .PAD(0)) layer2(
        .clk(clk),
        .reset_n(reset_n),
        .i_load(i_load_reg2),
        .w_load(w_load_reg2),
        .i_in(i_2_in[i]),
        .w_in(w_2_dout[i]),

        .pool_result(pool_result2[i]),
        .addr(i_mem_2_addr[i]),
        .history(),
        .com_end(pool_2_end[i]),
        .done_pool(done_pool2[i])
        );
    end
    
    for (i = 0; i < 32; i = i + 1) begin : COM_LAYER3
        SYS_ARRAY #(
        .SIZE(((IMG_SIZE-2)/2-2)/2)) sys_array(
        .clk(clk),
        .rst_n(reset_n),
        .i_load(i_load_reg3),
        .w_load(w_load_reg3),
        .i_in(i_3_in),
        .w_in(w_3_dout[i]),

        .result(flat_wire[i]),
        .res_sig(layer3_end[i])
        );
    end
    
    MEM #(
        .SIZE(IMG_SIZE)) INPUT(
        .clk(clk),
        .addr(i_addr_1),
        .data_in(i_data),
        .data_out(i_1_in),
        .we(i_we)
        );
    
    for (i = 0; i < 6; i = i + 1) begin : INPUT_2
    MEM #(
        .SIZE((IMG_SIZE-2)/2)) INPUT_2(
        .clk(clk),
        .addr(i_addr_a),
        .data_in(pool_result1[i]),
        .data_out(i_2_in_m[i]),
        .we(pool_1_end[0])
        );
    end
    

    assign i_addr_a = srt_layer2 ? i_addr_2 : i_mem_1_addr[0];
    assign i_addr_b = srt_layer3 ? i_addr_3 : i_mem_2_addr[0];
    
    for (i = 0; i < 16; i = i + 1) begin : INPUT_3
    MEM #(
        .SIZE(((IMG_SIZE-2)/2-2)/2)) INPUT_3(
        .clk(clk),
        .addr(i_addr_b),
        .data_in(pool_result2[i]),
        .data_out(i_3_in_m[i]),
        .we(pool_2_end[0])
        );
    end
    
    for (i = 0; i < 6; i = i + 1) begin : W_MEM_1
        MEM #(
        .SIZE(3)) W_MEM_1(
        .clk(clk),
        .addr(w_1_addr[i]),
        .data_in(w_1_din[i]),
        .data_out(w_1_dout[i]),
        .we(w_1_we[i])
        );
    end
    
    for (i = 0; i < 16; i = i + 1) begin : W_MEM_2
        MEM #(
        .SIZE(3)) W_MEM_2(
        .clk(clk),
        .addr(w_2_addr[i]),
        .data_in(w_2_din[i]),
        .data_out(w_2_dout[i]),
        .we(w_2_we[i])
        );
    end
    
    for (i = 0; i < 32; i = i + 1) begin : W_MEM_3
        MEM #(
        .SIZE(3)) W_MEM_3(
        .clk(clk),
        .addr(w_3_addr[i]),
        .data_in(w_3_din[i]),
        .data_out(w_3_dout[i]),
        .we(w_3_we[i])
        );
    end
endgenerate

begin   //16 connect
assign i_2_in[0] = i_2_in_m[0] + i_2_in_m[1] + i_2_in_m[2];
assign i_2_in[1] = i_2_in_m[1] + i_2_in_m[2] + i_2_in_m[3];
assign i_2_in[2] = i_2_in_m[2] + i_2_in_m[3] + i_2_in_m[4];
assign i_2_in[3] = i_2_in_m[3] + i_2_in_m[4] + i_2_in_m[5];
assign i_2_in[4] = i_2_in_m[4] + i_2_in_m[5] + i_2_in_m[0];
assign i_2_in[5] = i_2_in_m[5] + i_2_in_m[0] + i_2_in_m[1];

assign i_2_in[6] = i_2_in_m[0] + i_2_in_m[1] + i_2_in_m[2] + i_2_in_m[3];
assign i_2_in[7] = i_2_in_m[1] + i_2_in_m[2] + i_2_in_m[3] + i_2_in_m[4];
assign i_2_in[8] = i_2_in_m[2] + i_2_in_m[3] + i_2_in_m[4] + i_2_in_m[5];
assign i_2_in[9] = i_2_in_m[3] + i_2_in_m[4] + i_2_in_m[5] + i_2_in_m[0];
assign i_2_in[10] = i_2_in_m[4] + i_2_in_m[5] + i_2_in_m[0] + i_2_in_m[1];
assign i_2_in[11] = i_2_in_m[5] + i_2_in_m[0] + i_2_in_m[1] + i_2_in_m[2];

assign i_2_in[12] = i_2_in_m[0] + i_2_in_m[1] + i_2_in_m[3] + i_2_in_m[4];
assign i_2_in[13] = i_2_in_m[1] + i_2_in_m[2] + i_2_in_m[4] + i_2_in_m[5];
assign i_2_in[14] = i_2_in_m[0] + i_2_in_m[2] + i_2_in_m[3] + i_2_in_m[5];
assign i_2_in[15] = i_2_in_m[0] + i_2_in_m[1] + i_2_in_m[2] + i_2_in_m[3] + i_2_in_m[4] + i_2_in_m[5];
end

assign done_layer1 = done_pool1[0];
assign done_layer2 = done_pool2[0];
assign done_layer3 = done_layer3_reg;

assign i_3_in = (i_3_in_m[0] + i_3_in_m[1] + i_3_in_m[2] + i_3_in_m[3] +
                 i_3_in_m[4] + i_3_in_m[5] + i_3_in_m[6] + i_3_in_m[7] +
                 i_3_in_m[8] + i_3_in_m[9] + i_3_in_m[10] + i_3_in_m[11] +
                 i_3_in_m[12] + i_3_in_m[13] + i_3_in_m[14] + i_3_in_m[15]) >>> 5;

always @(posedge clk or negedge reset_n)
begin : WEIGHT_SAVER
    if (!reset_n) begin
        for (j_1 = 0; j_1 < 6; j_1 = j_1 + 1) begin
            w_1_addr[j_1] <= 1'b0;
        end
        for (j_2 = 0; j_2 < 16; j_2 = j_2 + 1) begin
            w_2_addr[j_2] <= 1'b0;
        end
        for (j_3 = 0; j_3 < 32; j_3 = j_3 + 1) begin
            w_3_addr[j_3] <= 1'b0;
        end
        {j_1, j_2, j_3, k_1, k_2, k_3, done1, done2, done3} <= 1'b0;
    end else begin
        if (conv_weight1) begin
            if (j_1 < 6) begin
                if ((k_1 < 9) & w_we) begin
                    w_1_din[j_1] <= w_data;
                    w_1_addr[j_1] <= w_addr;
                    w_1_we[j_1] <= w_we;
                    k_1 <= k_1 + 1'b1;
                    if (k_1 == 8) begin
                        j_1 <= j_1 + 1'b1;
                        k_1 <= 1'b0;
                    end else if((k_1 == 0) & (j_1 > 0))begin
                        w_1_we[j_1-1] <= 1'b0;
                    end
                end
            end else if ((k_1 == 0) & (j_1 == 6)) begin
                w_1_we[j_1-1] <= 1'b0;
            end
        end else if (conv_weight2) begin
            if (j_2 < 16) begin
                if ((k_2 < 9) & w_we) begin
                    w_2_din[j_2] <= w_data;
                    w_2_addr[j_2] <= w_addr;
                    w_2_we[j_2] <= w_we;
                    k_2 <= k_2 + 1'b1;
                    if (k_2 == 8) begin
                        j_2 <= j_2 + 1'b1;
                        k_2 <= 1'b0;
                    end else if ((k_2 == 0) & (j_2 > 0)) begin
                        w_2_we[j_2-1] <= 1'b0;
                    end
                end
            end else if ((k_2 == 0) & (j_2 == 16)) begin
                w_2_we[j_2-1] <= 1'b0;
            end
        end else if (conv_weight3) begin
            if (j_3 < 32) begin
                if ((k_3 < 9) & w_we) begin
                    w_3_din[j_3] <= w_data;
                    w_3_addr[j_3] <= w_addr;
                    w_3_we[j_3] <= w_we;
                    k_3 <= k_3 + 1'b1;
                    if (k_3 == 8) begin
                        j_3 <= j_3 + 1'b1;
                        k_3 <= 1'b0;
                    end else if ((k_3 == 0) & (j_3 > 0))begin
                        w_3_we[j_3-1] <= 1'b0;
                    end
                end
            end else if ((k_3 == 0) & (j_3 == 32)) begin
                w_3_we[j_3-1] <= 1'b0;
            end
        end else if (done_layer3) begin
            {j_1, j_2, j_3} <= 1'b0;
            k_2 <= -1'b1;
            k_3 <= -1'b1;
        end
    end
end

always @(posedge clk or negedge reset_n)
begin : WI_LOAD_GEN
    if (!reset_n) begin
        {count, w_load_reg1, w_load_reg2, w_load_reg3,
        i_load_reg1, i_load_reg2, i_load_reg3} <= 1'b0;
    end else begin
        if (srt_layer1) begin
            if (count >= 4'd14) begin
                w_load_reg1 <= 1'b0;
                i_load_reg1 <= 1'b1;
            end else begin
                w_load_reg1 <= 1'b1;
                count <= count + 1'b1;
            end
        end else if (srt_layer2) begin
            if (count <= 0) begin
                w_load_reg2 <= 1'b0;
                i_load_reg2 <= 1'b1;
            end else begin
                w_load_reg2 <= 1'b1;
                count <= count - 1'b1;
            end
        end else if (srt_layer3) begin
            if (count >= 4'd14) begin
                w_load_reg3 <= 1'b0;
                i_load_reg3 <= 1'b1;
            end else begin
                w_load_reg3 <= 1'b1;
                count <= count + 1'b1;
            end
        end else begin
            {count, i_load_reg1, i_load_reg2, i_load_reg3} <= 1'b0;
        end
    end
end

always @(posedge clk or negedge reset_n)
begin : MEM_ADDR_GEN
    if (!reset_n) begin
        {w_1_addr_layer1, w_2_addr_layer2, w_3_addr_layer3, i_addr_2, i_addr_3} <= 1'b0;
        for (n=0; n<5; n=n+1) begin
            {i_addr_delay1[n], i_addr_delay2[n], i_addr_delay3[n]} <= 1'b0;
        end
    end else begin
        if (srt_layer1) begin
            if ((w_1_addr[0] < 4'd9)) begin
                for (n = 0; n < 6; n = n + 1) begin
                    w_1_din[n] <= 1'b0;
                    w_1_addr[n] <= w_1_addr_layer1;
                    w_1_addr_layer1 <= w_1_addr_layer1 + 1'b1;
                    w_1_we[n] <= 1'b0;
                end
            end else if (i_addr_1 < IMG_SIZE**2) begin
                i_data <= 1'b0;
                i_addr_1 <= i_addr_delay1[4];
                i_addr_delay1[4] <= i_addr_delay1[3];
                i_addr_delay1[3] <= i_addr_delay1[2];
                i_addr_delay1[2] <= i_addr_delay1[1];
                i_addr_delay1[1] <= i_addr_delay1[0];
                i_addr_delay1[0] <= i_addr_delay1[0] + 1'b1;
                i_we <= 1'b0;
            end
        end else if (srt_layer2) begin
            if ((w_2_addr[0] < 4'd9)) begin
                for (n = 0; n < 16; n = n + 1) begin
                    w_2_din[n] <= 1'b0;
                    w_2_addr[n] <= w_2_addr_layer2;
                    w_2_addr_layer2 <= w_2_addr_layer2 + 1'b1;
                    w_2_we[n] <= 1'b0;
                end
            end else if (i_addr_2 < ((IMG_SIZE-2)/2)**2) begin
                i_data <= 1'b0;
                i_addr_2 <= i_addr_delay2[4];
                i_addr_delay2[4] <= i_addr_delay2[3];
                i_addr_delay2[3] <= i_addr_delay2[2];
                i_addr_delay2[2] <= i_addr_delay2[1];
                i_addr_delay2[1] <= i_addr_delay2[0];
                i_addr_delay2[0] <= i_addr_delay2[0] + 1'b1;
                i_we <= 1'b0;
            end
        end else if (srt_layer3) begin
            if ((w_3_addr[0] < 4'd9)) begin
                for (n = 0; n < 32; n = n + 1) begin
                    w_3_din[n] <= 1'b0;
                    w_3_addr[n] <= w_3_addr_layer3;
                    w_3_addr_layer3 <= w_3_addr_layer3 + 1'b1;
                    w_3_we[n] <= 1'b0;
                end
            end else if (i_addr_3 < (((IMG_SIZE-2)/2-2)/2)**2) begin
                i_data <= 1'b0;
                i_addr_3 <= i_addr_delay3[4];
                i_addr_delay3[4] <= i_addr_delay3[3];
                i_addr_delay3[3] <= i_addr_delay3[2];
                i_addr_delay3[2] <= i_addr_delay3[1];
                i_addr_delay3[1] <= i_addr_delay3[0];
                i_addr_delay3[0] <= i_addr_delay3[0] + 1'b1;
                i_we <= 1'b0;
            end
        end else if(!(conv_weight1 | conv_weight2 | conv_weight3)) begin
            {w_1_addr_layer1, w_2_addr_layer2, w_3_addr_layer3, i_addr_2, i_addr_3} <= 1'b0;
            for (n=0; n<5; n=n+1) begin
                {i_addr_delay1[n], i_addr_delay2[n], i_addr_delay3[n]} <= 1'b0;
            end
        end
    end
end
reg [7:0] cnt;
always @(posedge clk or negedge reset_n)
begin : OUT_GEN
    if (!reset_n) begin
        out_count <= 1'b0;
    end else begin
        if (!layer3_end[0]) begin
            flat_out <= flat_reg[out_count];
            addr_out <= out_count;
            we_out <= 1'b1;
            out_count <= out_count + 1'b1;
        end else begin
            out_count <= 1'b0;
            done_layer3_reg <= 1'b1;
            addr_out <= 1'b0;
            we_out <= 1'b0;
            for (cnt = 0; cnt < 8'd32; cnt = cnt + 1'b1)
                flat_reg[cnt] <= flat_wire[8'd31-cnt];
        end
    end
end

always @(*)
begin : FLAT_CONNECT
    for (m = 0; m < 32; m = m + 1) begin
        flat_reg[m] = flat_wire[m];
    end
end

always @(*)
begin : DATA_CONNECT
    case(img_input)
        1'b1 : begin
            w_data = 1'b0;
            w_addr = 1'b0;
            w_we = 1'b0;
            i_data = data;
            i_addr_1 = addr;
            i_we = we;
        end
        1'b0 : begin
            w_data = data;
            w_addr = addr;
            w_we = we;
            i_data = 1'b0;
            i_addr_1 = 1'b0;
            i_we = 1'b0;
        end
    endcase
end

endmodule