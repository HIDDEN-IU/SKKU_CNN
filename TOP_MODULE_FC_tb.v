`timescale 1ns/1ns
module TOP_MODULE_FC_tb();


reg CLK, RESET_N, ENABLE, BCK_PROP_START;
reg WE;
reg [15:0] FLAT_VALUE, FLAT_ADDR;

wire ALL_END,FC_BCK_PROP_END;
wire [15:0] FC_ERR_PROP, FC_ERR_ADDR;

integer signed i, j;

initial
begin
CLK = 0;
end

initial
begin
	forever
	begin
		#5 CLK = !CLK;
	end
end

TOP_MODULE_FC #(
.FRT_CELL(14),
.MID_CELL(10),
.BCK_CELL(5)) FC_PART(
.clk(CLK),
.reset_n(RESET_N),
.enable(ENABLE),               //FC start
.flat_we(WE),              //flatten input write enable
.flat_value(FLAT_VALUE),    //flatten input data
.flat_addr(FLAT_ADDR),     //flatten input address
.bck_prop_start(BCK_PROP_START),

.all_end(ALL_END),             //signal to controller, FC finished
.fc_bck_prop_end(FC_BCK_PROP_END),     //propagation in FC finished
.fc_err_prop(FC_ERR_PROP),  //propagation error from final result
.fc_err_addr(FC_ERR_ADDR)   //propagation address
);

initial
begin
	RESET_N = 1'b0; ENABLE = 1'b0; BCK_PROP_START = 1'b0;
	#10 RESET_N = 1'b1;
    for (i=0; i<14; i = i+1) begin
            #10 FLAT_VALUE = 10 + 10*i;
            WE = 1'b1;
            FLAT_ADDR = i;
    end
	#10 ENABLE = 1'b1; WE = 1'b0;
	#5000;
    
    BCK_PROP_START = 1'b1; ENABLE = 1'b0;
    #3000;
    
    //ENABLE = 1'b1; BCK_PROP_START = 1'b0;
    //#5000;
    
    /*BCK_PROP_START = 1'b1; ENABLE = 1'b0;
    #2000;*/
    $stop;
end

endmodule