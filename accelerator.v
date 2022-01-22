module ACCELERATOR (
input clk,
input rst_n,
input [4:0] state;
input signed [15:0] in,
output res_sig,
output signed [15:0] result
);

localparam [4:0] INIT = 5'd0;
localparam [4:0] CONV_WEIGHT_1 = 5'd1;
localparam [4:0] CONV_WEIGHT_2 = 5'd2;
localparam [4:0] CONV_WEIGHT_3 = 5'd3;
localparam [4:0] FC_WEIGHT_1 = 5'd4;
localparam [4:0] FC_WEIGHT_2 = 5'd5;
localparam [4:0] INPUT = 5'd6;
localparam [4:0] RIGHT_ANSWER = 5'd7;
localparam [4:0] CONV_LAYER1 = 5'd8;
localparam [4:0] CONV_LAYER2 = 5'd9;
localparam [4:0] CONV_LAYER3 = 5'd10;
localparam [4:0] FC_FWD = 5'd11;
localparam [4:0] FC_BP = 5'd12;
localparam [4:0] LAYER_3 = 5'd13;//<-----------must be change
localparam [4:0] UPDATE = 5'd14;



reg i_load, w_load;

//for counter
wire        [15:0] count;
reg         [7:0]  size;
reg                cnt_en;
wire               cnt_end;

//i is for for input memories
wire        [15:0] i_mem_1_addr;
wire signed [15:0] i_mem_1_din;
wire signed [15:0] i_mem_1_dout;
wire               i_mem_1_we;

wire        [15:0] i_mem_2_addr [0:5];
wire signed [15:0] i_mem_2_din  [0:5];
wire signed [15:0] i_mem_2_dout [0:5];
wire               i_mem_2_we   [0:5];

wire        [15:0] i_mem_3_addr [0:15];
wire signed [15:0] i_mem_3_din  [0:15];
wire signed [15:0] i_mem_3_dout [0:15];
wire               i_mem_3_we   [0:15];

// wire        [15:0] i_mem_4_addr [0:31];
// wire signed [15:0] i_mem_4_din  [0:31];
// wire signed [15:0] i_mem_4_dout [0:31];
// wire               i_mem_4_we   [0:31];

//h is for pooling histories
wire        [15:0] h_mem_1_addr [0:5];
wire signed [15:0] h_mem_1_din  [0:5];
wire signed [15:0] h_mem_1_dout [0:5];
wire               h_mem_1_we   [0:5];

wire        [15:0] h_mem_2_addr [0:5];
wire signed [15:0] h_mem_2_din  [0:5];
wire signed [15:0] h_mem_2_dout [0:5];
wire               h_mem_2_we   [0:5];

//w is for weight
wire        [15:0] w_mem_1_addr [0:5];
wire signed [15:0] w_mem_1_din  [0:5];
wire signed [15:0] w_mem_1_dout [0:5];
wire               w_mem_1_we   [0:5];

wire        [15:0] w_mem_2_addr [0:15];
wire signed [15:0] w_mem_2_din  [0:15];
wire signed [15:0] w_mem_2_dout [0:15];
wire               w_mem_2_we   [0:15];

wire        [15:0] w_mem_3_addr [0:31];
wire signed [15:0] w_mem_3_din  [0:31];
wire signed [15:0] w_mem_3_dout [0:31];
wire               w_mem_3_we   [0:31];

// wire for CONV1
wire               i_1_load;
wire               w_1_load;
wire signed [15:0] i_1_in   [0:5];
wire signed [15:0] w_1_in   [0:5];
wire               c_1_res_sig[0:5];
wire signed [15:0] c_1_res  [0:5];

// wire for CONV2
wire               i_2_load;
wire               w_2_load;
wire signed [15:0] i_2_in   [0:15];
wire signed [15:0] w_2_in   [0:15];
wire               c_2_res_sig[0:15];
wire signed [15:0] c_2_res  [0:15];

// wire for CONV3
wire               i_3_load;
wire               w_3_load;
wire signed [15:0] i_3_in_add; 
wire signed [15:0] i_3_in   [0:31];
wire signed [15:0] w_3_in   [0:31];
wire               c_3_res_sig[0:31];
wire signed [15:0] c_3_res  [0:31];

//wire for POOLING 2,3
wire               p_1_load  [0:5];
wire signed [15:0] p_1_in    [0:5];
wire signed [15:0] p_1_res   [0:5];
wire signed [15:0] p_1_his   [0:5];
wire signed [15:0] p_1_addr  [0:5];
wire               p_1_res_sig[0:5];

wire               p_2_load  [0:15];
wire signed [15:0] p_2_in    [0:15];
wire signed [15:0] p_2_res   [0:15];
wire signed [15:0] p_2_his   [0:15];
wire signed [15:0] p_2_addr  [0:15];
wire               p_2_res_sig[0:15];

reg signed [15:0] conv_result [0:31];
            
//counter to count through address of every memories
COUNTER COUNTER1 (
    .clk(clk), 
    .rst_n(rst_n), 
    .size(size), 
    .enable(cnt_en), 
    .count(count),
    .end_sig(cnt_end)
    );
    
//first memory to save input, with padding
MEM #(
    .SIZE(18)) I_MEM_1
    (
    .clk(clk), 
    .addr(i_mem_1_addr), 
    .data_in(i_mem_1_din), 
    .data_out(i_mem_1_dout),               
    .we(i_mem_1_we)
    );
    
assign i_mem_1_addr = count;
assign i_mem_1_din = in;
assign i_mem_1_we = i_load;


genvar i;
generate
    // CONV1 & POOL1
    for (i = 0; i < 6; i = i + 1) begin
        MEM #(
            .SIZE(3)) W_MEM_1
            (
            .clk(clk), 
            .addr(w_mem_1_addr[i]), 
            .data_in(w_mem_1_din[i]), 
            .data_out(w_mem_1_dout[i]),
            .we(w_mem_1_we[i])
            );
            
        assign w_mem_1_addr[i] = count;
        assign w_mem_1_din[i] = in;
            
        SYS_ARRAY #(
            .SIZE(18)) CONV1 
            (
            .clk(clk),
            .rst_n(rst_n),
            .i_load(i_1_load),
            .w_load(w_1_load),
            .i_in(i_1_in[i]),
            .w_in(w_1_in[i]),
            .result(c_1_res[i]),
            .res_sig(c_1_res_sig[i])
            );

        assign w_1_in[i] = w_1_dout;
        assign i_1_in[i] = i_1_dout;
        
        POOLING #(
            .n(8)) POOL_1 
            (
            .clk(clk),
            .rst_n(rst_n),
            .load(p_1_load[i]),
            .in(p_1_in[i]),
            .result(p_1_res[i]),
            .history(p_1_his[i]),
            .addr(p_1_addr[i])
            .reg_sig(p_1_res_sig[i])
            );
            
        assign p_1_load[i] = c_1_res_sig[i];            
        assign p_1_in[i] = c_1_res[i];


        MEM #(
            .SIZE(8)) I_MEM_2
            (
            .clk(clk), 
            .addr(i_mem_2_addr[i]), 
            .data_in(i_mem_2_din[i]), 
            .data_out(i_mem_2_dout[i]),
            .we(i_mem_2_we[i])
            );
            
        assign i_mem_2_addr[i] = p_1_addr[i];
        assign i_mem_2_din[i] = p_1_res[i];
        assign i_mem_2_we[i] = p_1_res_sig[i];
            
        MEM #(
            .SIZE(8)) H_MEM_1
            (
            .clk(clk), 
            .addr(h_mem_1_addr[i]), 
            .data_in(h_mem_1_din[i]), 
            .data_out(h_mem_1_dout[i]),
            .we(h_mem_1_we[i])
            );
            
        assign h_mem_1_addr[i] = p_1_addr[i];
        assign h_mem_1_din [i] = p_1_his[i];
        assign h_mem_1_we [i] = p_1_reg_sig[i];
    end
    
    // CONV2 & POOL2
    for (i = 0; i < 16; i = i + 1) begin
        MEM #(
            .SIZE(3)) W_MEM_2
            (
            .clk(clk), 
            .addr(w_mem_2_addr[i]), 
            .data_in(w_mem_2_din[i]), 
            .data_out(w_mem_2_dout[i]),
            .we(w_mem_2_we[i])
            );
        assign w_mem_2_addr[i] = count;
        assign w_mem_2_din[i] = in;
        
        SYS_ARRAY #(
            .SIZE(8)) CONV2 
            (
            .clk(clk),
            .rst_n(rst_n),
            .i_load(i_2_load),
            .w_load(w_2_load),
            .i_in(i_2_in[i]),
            .w_in(w_2_in[i]),
            .result(c_2_res[i]),
            .res_sig(c_2_res_sig[i])
            );
            
        assign w_2_in[i] = w_2_dout;

            
        POOLING #(
            .n(3)) POOL_2 
            (
            .clk(clk),
            .rst_n(rst_n),
            .load(p_2_load),
            .in(p_2_in[i]),
            .result(p_2_res[i]),
            .history(p_2_his[i]),
            .addr(p_2_addr[i])
            );
            
        assign p_1_load[i] = c_1_res_sig[i];
        assign p_1_in[i] = c_1_res[i];
            
        MEM #(
            .SIZE(3)) I_MEM_3
            (
            .clk(clk), 
            .addr(i_mem_3_addr[i]), 
            .data_in(i_mem_3_din[i]), 
            .data_out(i_mem_3_dout[i]),               
            .we(i_mem_3_we[i])
            );
        assign i_mem_3_addr[i] = p_2_addr[i];
        assign i_mem_3_din[i] = p_2_res[i];
        assign i_mem_3_we[i] = p_2_res_sig[i];
        
        MEM #(
            .SIZE(3)) H_MEM_2
            (
            .clk(clk), 
            .addr(h_mem_2_addr[i]), 
            .data_in(h_mem_2_din[i]), 
            .data_out(h_mem_2_dout[i]),               
            .we(h_mem_2_we[i])
            );
            
        assign h_mem_2_addr[i] = p_2_addr[i];
        assign h_mem_2_din [i] = p_2_his[i];
        assign h_mem_2_we [i] = p_2_reg_sig[i];
    end
    
    for (i = 0; i < 6; i = i + 1)
        assign i_2_in[i] = i_2_dout[i%6] + i_2_dout[(i+1)%6] + i_2_dout[(i+2)%6];
        
    for (i = 0; i < 6; i = i + 1)
        assign i_2_in[6+i] = i_2_dout[i%6]     + i_2_dout[(i+1)%6] + 
                           i_2_dout[(i+2)%6] + i_2_dout[(i+3)%6];
        
    for (i = 0; i < 3; i = i + 1)
        assign i_2_in[12+i] = i_2_dout[i%6]     + i_2_dout[(i+1)%6] +
                           i_2_dout[(i+3)%6] + i_2_dout[(i+4)%6];
        
    assign i_2_in[15] = i_2_dout[0] + i_2_dout[1] + i_2_dout[2] +
                       i_2_dout[3] + i_2_dout[4] + i_2_dout[5];

    for (i = 0; i < 32; i = i + 1) begin
    
        MEM #(
            .SIZE(3)) W_MEM_3
            (
            .clk(clk), 
            .addr(w_mem_3_addr[i]), 
            .data_in(w_mem_3_din[i]), 
            .data_out(w_mem_3_dout[i]),               
            .we(w_mem_3_we[i])
            );
        assign w_mem_3_addr[i] = count;
        assign w_mem_3_din[i] = in;
            
        SYS_ARRAY #(
            .SIZE(3)) CONV3 
            (
            .clk(clk),
            .rst_n(rst_n),
            .i_load(i_3_load),
            .w_load(w_3_load),
            .i_in(i_3_in[i]),
            .w_in(w_3_in[i]),
            .result(c_3_res[i]),
            .res_sig(c_3_res_sig[i])
            );
            
        assign w_3_in[i] = w_3_dout[i];
        assign i_3_in[i] = i_3_in_add;

    end
    
    assign i_3_in_add =  i_3_dout[0] +  i_3_dout[1] +  i_3_dout[2] +  i_3_dout[3] +
                         i_3_dout[4] +  i_3_dout[5] +  i_3_dout[6] +  i_3_dout[7] +
                         i_3_dout[8] +  i_3_dout[9] +  i_3_dout[10] + i_3_dout[11] +
                         i_3_dout[12] + i_3_dout[13] + i_3_dout[14] + i_3_dout[15];

endgenerate

reg [7:0] w_counter;

localparam [4:0] INIT = 5'd0;
localparam [4:0] CONV_WEIGHT_1 = 5'd1;
localparam [4:0] CONV_WEIGHT_2 = 5'd2;
localparam [4:0] CONV_WEIGHT_3 = 5'd3;
localparam [4:0] FC_WEIGHT_1 = 5'd4;
localparam [4:0] FC_WEIGHT_2 = 5'd5;
localparam [4:0] INPUT = 5'd6;
localparam [4:0] RIGHT_ANSWER = 5'd7;
localparam [4:0] CONV_LAYER1 = 5'd8;
localparam [4:0] CONV_LAYER2 = 5'd9;
localparam [4:0] CONV_LAYER3 = 5'd10;
localparam [4:0] FC_FWD = 5'd11;
localparam [4:0] FC_BP = 5'd12;
localparam [4:0] LAYER_3 = 5'd13;//<-----------must be change
localparam [4:0] UPDATE = 5'd14; 


reg [7:0] w_counter;

// final result
reg [7:0] j;
always @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin
        w_counter <= 8'd0;
    end else begin
        cnt_en <= 1'b0;
        case(state)
            CONV_WEIGHT_1 : begin
                if (w_counter < 6) begin
                    cnt_en <= 1'b1;
                    size <= 8'd3;
                    w_mem_1_we [w_counter] <= 1'b1;
                    if(cnt_end) begin
                        w_mem_1_we [w_counter] <= 1'b0;

                        if (w_counter == 8'd5) begin
                            w_counter <= 8'd0;
                            cnt_en <= 1'b0;
                        end else begin
                            w_counter <= w_counter + 1'b1;
                        end
                    end
                end
            end
            
            CONV_WEIGHT_2 : begin
                if (w_counter < 16) begin
                    cnt_en <= 1'b1;
                    size <= 8'd3;
                    w_mem_2_we [w_counter] <= 1'b1;
                    if(cnt_end) begin
                        w_mem_2_we [w_counter] <= 1'b0;

                        if (w_counter == 8'd15) begin
                            w_counter <= 8'd0;
                            cnt_en <= 1'b0;
                        end else begin
                            w_counter <= w_counter + 1'b1;
                        end
                    end
                end
            end
            
            CONV_WEIGHT_3 : begin
                if (w_counter < 32) begin
                    cnt_en <= 1'b1;
                    size <= 8'd3;
                    w_mem_3_we [w_counter] <= 1'b1;
                    if(cnt_end) begin
                        w_mem_3_we [w_counter] <= 1'b0;

                        if (w_counter == 8'd31) begin
                            w_counter <= 8'd0;
                            cnt_en <= 1'b0;
                        end else begin
                            w_counter <= w_counter + 1'b1;
                        end
                    end
                end
            end
            
            INPUT : begin
                cnt_en <= 1'b1;
                size <= 8'd14;
                i_mem_1_we <= 1'b1;
                if(cnt_end) begin
                    i_mem_1_we [w_counter] <= 1'b0;
                        cnt_en <= 1'b0;
                        i_mem_1_we <= 1'b0;
                    end
                end
            end
    
        if (c_3_res_sig[0]) begin
            for (j = 0; j <32; j = j + 1) begin
                conv_result[j] <= c_3_res[j];
            end
        end
    end
end

endmodule