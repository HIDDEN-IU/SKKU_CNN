module ACCELERATOR (
input clk,
input rst_n,
input w_load,
input i_load,
input ctrl_bit;
input signed [15:0] w_in,
input signed [15:0] i_in,
output res_sig,
output signed [15:0] result
);



//for counter
reg         [15:0] count;
reg         [7:0]  size;
reg                cnt_en;

//i is for for input memories
wire        [15:0] i_1_addr;
wire signed [15:0] i_1_din;
wire signed [15:0] i_1_dout;
wire               i_1_we;

wire        [15:0] i_2_addr [0:5];
wire signed [15:0] i_2_din  [0:5];
wire signed [15:0] i_2_dout [0:5];
wire               i_2_we   [0:5];

wire        [15:0] i_3_addr [0:15];
wire signed [15:0] i_3_din  [0:15];
wire signed [15:0] i_3_dout [0:15];
wire               i_3_we   [0:15];

wire        [15:0] i_4_addr [0:31];
wire signed [15:0] i_4_din  [0:31];
wire signed [15:0] i_4_dout [0:31];
wire               i_4_we   [0:31];

//p is for pooling histories
wire        [15:0] p_2_addr [0:5];
wire signed [15:0] p_2_din  [0:5];
wire signed [15:0] p_2_dout [0:5];
wire               p_2_we   [0:5];

wire        [15:0] p_3_addr [0:5];
wire signed [15:0] p_3_din  [0:5];
wire signed [15:0] p_3_dout [0:5];
wire               p_3_we   [0:5];

//w is for weight
wire        [15:0] w_1_addr [0:5];
wire signed [15:0] w_1_din  [0:5];
wire signed [15:0] w_1_dout [0:5];
wire               w_1_we   [0:5];

wire        [15:0] w_2_addr [0:15];
wire signed [15:0] w_2_din  [0:15];
wire signed [15:0] w_2_dout [0:15];
wire               w_2_we   [0:15];

wire        [15:0] w_3_addr [0:31];
wire signed [15:0] w_3_din  [0:31];
wire signed [15:0] w_3_dout [0:31];
wire               w_3_we   [0:31];

//counter to count through address of every memories
COUNTER COUNTER1 (
    .clk(clk), 
    .rst_n(rst_n), 
    .size(size), 
    .enable(cnt_en), 
    .count(count)
    );
    
//first memory to save input, with padding
MEM #(
    .SIZE(18)) I_MEM_1
    (
    .clk(clk), 
    .addr(i_1_addr), 
    .data_in(i_1_din), 
    .data_out(i_1_dout),               
    .we(i_1_we)
    );


genvar i;
generate
    // CONV1 & POOL1
    for (i = 0; i < 6; i = i + 1) begin
        MEM #(
            .SIZE(3)) W_MEM_1
            (
            .clk(clk), 
            .addr(w_1_addr[i]), 
            .data_in(w_1_din[i]), 
            .data_out(w_1_dout[i]),               
            .we(w_1_we[i])
            );
            
        
            
        MEM #(
            .SIZE(8)) I_MEM_2
            (
            .clk(clk), 
            .addr(i_2_addr[i]), 
            .data_in(i_2_din[i]), 
            .data_out(i_2_dout[i]),               
            .we(i_2_we[i])
            );
            
        MEM #(
            .SIZE(8)) P_MEM_2
            (
            .clk(clk), 
            .addr(p_2_addr[i]), 
            .data_in(p_2_din[i]), 
            .data_out(p_2_dout[i]),               
            .we(p_2_we[i])
            );
    end
    // CONV2 & POOL2
    for (i = 0; i < 16; i = i + 1) begin
        MEM #(
            .SIZE(3)) W_MEM_2
            (
            .clk(clk), 
            .addr(w_2_addr[i]), 
            .data_in(w_2_din[i]), 
            .data_out(w_2_dout[i]),               
            .we(w_2_we[i])
            );
            
        MEM #(
            .SIZE(3)) I_MEM_3
            (
            .clk(clk), 
            .addr(i_3_addr[i]), 
            .data_in(i_3_din[i]), 
            .data_out(i_3_dout[i]),               
            .we(i_3_we[i])
            );
            
        MEM #(
            .SIZE(3)) P_MEM_3
            (
            .clk(clk), 
            .addr(p_3_addr[i]), 
            .data_in(p_3_din[i]), 
            .data_out(p_3_dout[i]),               
            .we(p_3_we[i])
            );
    end

    for (i = 0; i < 32; i = i + 1) begin
        MEM #(
            .SIZE(3)) W_MEM_3
            (
            .clk(clk), 
            .addr(w_3_addr[i]), 
            .data_in(w_3_din[i]), 
            .data_out(w_3_dout[i]),               
            .we(w_3_we[i])
            );
    end

endgenerate