`timescale 1ns/1ns

module COMPUTATION_tb ();


parameter SIZE = 8'd14;


//integer input

reg CLK, RESET_N, I_LOAD, W_LOAD;
reg [15:0] I_IN, W_IN;
wire COM_END;
wire [15:0] POOL_RESULT, ADDR;
wire [1:0] HISTORY;



COMPUTATION #(
.FRT(6'd14),
.PAD(6'd0)) computation(
.clk(CLK),
.reset_n(RESET_N),
.i_load(I_LOAD),
.w_load(W_LOAD),
.i_in(I_IN),
.w_in(W_IN),

.pool_result(POOL_RESULT),
.addr(ADDR),
.history(HISTORY),
.com_end(COM_END)
);
    

integer i,j,c;

initial begin
    //reset
    RESET_N = 1'b0;
    I_LOAD = 1'b0;
    W_LOAD = 1'b0;
    #55;
    RESET_N = 1'b1;
    #10 W_LOAD = 1'B1;
    #10 c=1;
    for (i = 0; i<3; i = i+1)begin
        for(j = 0; j<3; j = j+1)begin
            W_IN = c;
            #10;
            c = c+1;

        end
    end
    #30 W_LOAD = 1'B0; I_LOAD = 1'B1;

    //input save
    #10 c=0;
    for (i = 0; i<SIZE; i = i+1)begin
        for(j = 0; j<SIZE; j = j+1)begin
            I_IN = c;
            #10;
            c = c+1;

        end
    end
    
    #1000 I_LOAD = 1'B0;
    
    #1000;
    $stop;

end


initial begin
    CLK = 1'b0;
    forever #5 CLK = !CLK;
end

endmodule