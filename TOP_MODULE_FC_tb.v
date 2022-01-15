`timescale 1ns/1ns
module TOP_MODULE_FC_tb();

parameter FRT_CELL = 14;
parameter MID_CELL = 10;
parameter BCK_CELL = 5;

reg CLK, RESET_N, ENABLE, BCK_PROP_START;
reg WE, WEIGHT1, WEIGHT2, RIGHT_ANSWER, BATCH_END;
reg [15:0] ex_value, ex_addr;

wire ALL_END, FC_BCK_PROP_END, FC_BATCH_END;
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
.FRT_CELL(FRT_CELL),
.MID_CELL(MID_CELL),
.BCK_CELL(BCK_CELL)) FC_PART(
.clk(CLK),
.reset_n(RESET_N),
.enable(ENABLE),                    //FC start when 1
.ex_we(WE),                         //flatten input write enable
.ex_value(ex_value),                //flatten input data
.ex_addr(ex_addr),                  //flatten input address
.bck_prop_start(BCK_PROP_START),    //back propagation start when 1
.batch_end(BATCH_END),              //32 mini batch finished
.weight1(WEIGHT1),                  //FC weight1 in when 1
.weight2(WEIGHT2),                  //FC weight2 in when 1
.right_answer(RIGHT_ANSWER),        //final 10 right answer when 1

.all_end(ALL_END),                  //signal to controller, FC finished when 1
.fc_bck_prop_end(FC_BCK_PROP_END),  //propagation in FC finished when 1
.fc_err_prop(FC_ERR_PROP),          //propagation error from final result
.fc_err_addr(FC_ERR_ADDR),           //propagation address
.fc_batch_end(FC_BATCH_END)
);

initial
begin
	RESET_N = 1'b0; ENABLE = 1'b0; BCK_PROP_START = 1'b0;
	#10 RESET_N = 1'b1;
    //input flatten value at ram0
    #10 WEIGHT1 = 1'b0; WEIGHT2 = 1'b0; RIGHT_ANSWER = 1'b0;
    for (i=0; i<FRT_CELL; i = i+1) begin
            ex_value = 10 + 10*i;
            WE = 1'b1;
            ex_addr = i;
            #10;
    end
    #10 WE = 1'b0;
    //input weight1 at ram0
    #10 WEIGHT1 = 1'b1; WEIGHT2 = 1'b0; RIGHT_ANSWER = 1'b1;
    for (i=0; i<FRT_CELL*MID_CELL; i = i+1) begin
            ex_value = -250 + 3*i;
            WE = 1'b1;
            ex_addr = FRT_CELL + i;
            #10;
    end
    #10 WE = 1'b0;
    //input weight2 at ram1
    #10 WEIGHT1 = 1'b0; WEIGHT2 = 1'b1; RIGHT_ANSWER = 1'b0;
    for (i=0; i<MID_CELL*BCK_CELL; i = i+1) begin
            ex_value = -250 + 10*i;
            WE = 1'b1;
            ex_addr = MID_CELL + i;
            #10;
    end
    WE = 1'b0;
    //first right answer
    //input right answer at ram2
    #10 WEIGHT1 = 1'b0; WEIGHT2 = 1'b0; RIGHT_ANSWER = 1'b1;
    for (i=0; i<BCK_CELL; i = i+1) begin
            ex_value = 0;
            WE = 1'b1;
            ex_addr = BCK_CELL + i;
            #10;
    end
    ex_addr = BCK_CELL + 3;
    ex_value = (1'b1 << 10) + (1'b1 << 9);
    #10 WE = 1'b0;
    #10 WEIGHT1 = 1'b0; WEIGHT2 = 1'b0; RIGHT_ANSWER = 1'b0;
    
	#10 ENABLE = 1'b1; WE = 1'b0;
	#5000;
    
    BCK_PROP_START = 1'b1; ENABLE = 1'b0;
    #3000;
    BCK_PROP_START = 1'b0;
    #10;
    
    //another right answer test bench - if need, make comment below section
    //---------------------------------------------------------------------
    //second right answer
    //input right answer at ram2
    #10 WEIGHT1 = 1'b0; WEIGHT2 = 1'b0; RIGHT_ANSWER = 1'b1;
    for (i=0; i<BCK_CELL; i = i+1) begin
            ex_value = 0;
            WE = 1'b1;
            ex_addr = BCK_CELL + i;
            #10;
    end
    ex_addr = BCK_CELL + 1;
    ex_value = (1'b1 << 10) + (1'b1 << 9);
    #10 WE = 1'b0;
    #10 WEIGHT1 = 1'b0; WEIGHT2 = 1'b0; RIGHT_ANSWER = 1'b0;
    #10 ENABLE = 1'b1; WE = 1'b0;
	#5000;
    BCK_PROP_START = 1'b1; ENABLE = 1'b0;
    #3000;
    BCK_PROP_START = 1'b0;
    #10;
    //--------------------------------------------------------------------
    
    BATCH_END = 1'b1;
    #5000;
    $stop;
end

endmodule