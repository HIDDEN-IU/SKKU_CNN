module FC_MEMORY #(
parameter FRT_CELL = 32,
parameter MID_CELL = 20,
parameter BCK_CELL = 10)(
input clk,
input reset_n,

input we,
input [15:0] data,
input [15:0] addr,

input fc1_com_end,
input fc2_com_end,
input bck_prop_start,

output [15:0] re_data,
output reg fc_bck_prop_end,
output reg [15:0] fc_err_prop,
output reg [15:0] fc_err_addr
);

`include "fixed_mult.v"

parameter LN_RATIO = (16'b1 << 5);    //0000_0000_0010_0000==32

// Declare the RAM variable
reg [15:0] ram[2:0][65535:0];
reg [1:0] mem_num_d, mem_num_m;

// Variable to hold the registered read address
reg [15:0] addr_reg;

reg signed[15:0] i,back_i, mid_i, mid_j, front_i, front_j, out_i;



always @ (posedge clk or negedge reset_n)
begin
    //initialize
    if (!reset_n) begin
        /*-----------------------------ram0---------------------------------
        0~31(0~FRT_CELL-1) : convolution result
        32~671(~FRT_CELL + FRT_CELL*MID_CELL) : first weight, updated after
        672~691(~2*FRT_CELL + FRT_CELL*MID_CELL) : error to propagate
        ------------------------------------------------------------------*/
        for (i=FRT_CELL; i<(FRT_CELL * MID_CELL + FRT_CELL); i = i+1) begin
            ram[0][i] <= -250 + 3*(i-FRT_CELL);
        end
        //------------------------------------------------------------------
        
        /*-----------------------------ram1--------------------------------
        0~19(0~MID_CELL-1) : forward propagation cell result
        20~219(~MID_CELL + MID_CELL*BCK_CELL) : second weight, updated after
        220~239(~2*MID_CELL + MID_CELL*BCK_CELL) : error to propagate
        ------------------------------------------------------------------*/
        for (i=MID_CELL; i<(MID_CELL * BCK_CELL + MID_CELL); i = i+1) begin
            ram[1][i] <= -250 + 10*(i-MID_CELL);
        end
        //-----------------------------------------------------------------
        
        /*-----------------------------ram2--------------------------------
        0~9(0~BCK_CELL-1): forward propagation cell result
        10~19(BCK_CELL~2*BCK_CELL-1) : accumulated error
        20~29(2*BCK_CELL~3*BCK_CELL-1) : first right answer
        30~39(3*BCK_CELL~4*BCK_CELL-1) : second right answer
        40~49(4*BCK_CELL~5*BCK_CELL-1) : third right answer...
        -----------------------------------------------------------------*/
        for (i=BCK_CELL; i<(12 * BCK_CELL); i = i+1) begin
            ram[2][i] <= 1'b0;
        end
        
        //write # at ram[BCK_CELL + #] to correct order,
        //if 5 is correct number, # = 5
        ram[2][2*BCK_CELL + 3] <= (1'b1 << 10) + (1'b1 << 9);
    end else begin
        if (we) begin
            ram[mem_num_d][addr] <= data;
        end
        addr_reg <= addr;
        
        
        
        //-------------------------backward start------------------------------------------------------------------------------//
        if (bck_prop_start) begin
            if (back_i >= 0) begin
                if (back_i < BCK_CELL) begin
                    ram[2][back_i + BCK_CELL] <= ram[2][BCK_CELL + back_i] + (ram[2][back_i] - ram[2][2*BCK_CELL + back_i]);
                    back_i <= back_i + 1'b1;
                    
                    
                end else begin  //first error, weight update
                    if (mid_i < BCK_CELL) begin
                        if (mid_j < MID_CELL) begin
                            if (mid_i == 1'b0) begin    //initialize
                                ram[1][MID_CELL*BCK_CELL + MID_CELL + mid_j] 
                                    <= fixed_mult(ram[1][MID_CELL + mid_i*MID_CELL + mid_j], ram[2][BCK_CELL + mid_i]);
                            end else begin
                            //error' = error + error# * weight
                            ram[1][MID_CELL*BCK_CELL + MID_CELL + mid_j]
                                <= ram[1][MID_CELL*BCK_CELL + MID_CELL + mid_j]
                                + fixed_mult(ram[1][MID_CELL + mid_i*MID_CELL + mid_j], ram[2][BCK_CELL + mid_i]);     //error
                            end
                            
                            //weight' = weight - r * cell * error
                            ram[1][MID_CELL + mid_i*MID_CELL + mid_j]
                                <= ram[1][MID_CELL + mid_i*MID_CELL + mid_j]
                                - fixed_mult(LN_RATIO, fixed_mult(ram[1][mid_j], ram[2][BCK_CELL + mid_i]));       //weight update
                            mid_j <= mid_j + 1'b1;
                            if (mid_j == (MID_CELL - 1'b1)) begin
                                mid_i <= mid_i + 1'b1;
                                mid_j <= 1'b0;
                            end
                        end
                    end else begin  //second error, weight update
                        if (front_i < MID_CELL) begin
                            if (front_j < FRT_CELL) begin
                                if (front_i == 1'b0) begin    //initialize
                                    ram[0][FRT_CELL*MID_CELL + FRT_CELL + front_j] 
                                        <= fixed_mult(ram[0][FRT_CELL + front_i*FRT_CELL + front_j], ram[1][MID_CELL*BCK_CELL + MID_CELL + front_i]);
                                end else begin
                                //error' = error + error# * weight
                                ram[0][FRT_CELL*MID_CELL + FRT_CELL + front_j]
                                    <= ram[0][FRT_CELL*MID_CELL + FRT_CELL + front_j]
                                    + fixed_mult(ram[0][FRT_CELL + front_i*FRT_CELL + front_j], ram[1][MID_CELL*BCK_CELL + MID_CELL + front_i]);     //error
                                end
                                
                                //weight' = weight - r * cell * error
                                ram[0][FRT_CELL + front_i*FRT_CELL + front_j]
                                    <= ram[0][FRT_CELL + front_i*FRT_CELL + front_j]
                                    - fixed_mult(LN_RATIO, fixed_mult(ram[0][front_j], ram[1][MID_CELL*BCK_CELL + MID_CELL + front_i]));       //weight update
                                front_j <= front_j + 1'b1;
                                if (front_j == (FRT_CELL - 1'b1)) begin
                                    front_i <= front_i + 1'b1;
                                    front_j <= 1'b0;
                                end
                            end
                            
                        //propagate output error
                        end else if (out_i < FRT_CELL) begin
                            fc_err_prop <= ram[0][FRT_CELL*MID_CELL + FRT_CELL + out_i];
                            fc_err_addr <= out_i;
                            out_i <= out_i + 1'b1;
                        end else begin
                            fc_bck_prop_end <= 1'b1;
                        end
                    end
                end
            end else begin
                {back_i, mid_i, mid_j, front_i, front_j, out_i} <= 1'b0;
            end
        end else begin
            {back_i, mid_i, mid_j, front_i, front_j, out_i} <= 1'sb1;
            fc_bck_prop_end <= 1'b0;
        end
    end
end

//demux, connect input 'we', 'data', 'addr' to ram
always @(*)
begin : DEMUX
    case ({fc1_com_end,fc2_com_end})
        2'b00 : mem_num_d = 2'd0;
        2'b01 : mem_num_d = 2'd0;
        2'b10 : mem_num_d = 2'd1;
        2'b11 : mem_num_d = 2'd2;
        default mem_num_d = 1'b0;
    endcase
end

//mux, connect output data 're_data'
always @(*)
begin : MUX
    case ({fc1_com_end,fc2_com_end})
        2'b00 : mem_num_m = 2'd0;
        2'b01 : mem_num_m = 2'd0;
        2'b10 : mem_num_m = 2'd1;
        2'b11 : mem_num_m = 2'd2;
        default mem_num_m = 1'b0;
    endcase
end

assign re_data = ram[mem_num_m][addr_reg];

endmodule
