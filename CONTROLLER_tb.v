`timescale 1ns/1ns
/*----------------------------------------------------------------------
                            *NOTICE*
    1. There are two modes, one is 'default mode' another is
        'batch test mode'.
    2. 'Default mode' is single batch size(update weight at every 
        single learning) and FC 32-20-10 cells. That test the whether 
        result match exactly or not.
    3. 'Batch test mode' is a mode that test state activation at
        large scale.
    4. If you want to change the modes, follow below comments such 
        as 'change' or 'swap'
    5. ***If don't know exactly, do not change every thing. just use***
-----------------------------------------------------------------------*/
module CONTROLLER_tb ();

//changeable below parameter
parameter FRT_CELL = 32;
parameter MID_CELL = 20;
parameter BCK_CELL = 10;
parameter BATCH_SIZE = 1;       //<----------change size to 32

reg CLK, RESET_N, SRT, 
    DONE_CONV_WEIGHT1, DONE_CONV_WEIGHT2, DONE_CONV_WEIGHT3,
    DONE_FC_WEIGHT1, DONE_FC_WEIGHT2, DONE_IMG_INPUT, DONE_RIGHT_ANSWER, 
    DONE_LAYER1, DONE_LAYER2, DONE_LAYER3, 
    //DONE_FC_FWD, DONE_FC_BCK_PROP,//<-----------------//  <--------swap
    DONE_SINGLE_LEARN, DONE_WEIGHT_UPDATE;              //
reg [15:0] EX_VALUE, EX_ADDR;                           //
reg WE;                                                 //
                                                        //
wire CONV_WEIGHT1, CONV_WEIGHT2, CONV_WEIGHT3,          //
     FC_WEIGHT1, FC_WEIGHT2, IMG_INPUT, RIGHT_ANSWER,   //
     SRT_LAYER1, SRT_LAYER2, SRT_LAYER3,                //
     SRT_FC_FWD, FC_BP_SRT, LAYER_3, WEIGHT_UPDATE,     //
     DONE_FC_FWD, DONE_FC_BCK_PROP,//<------------------//
     DONE_FC_BATCH;
wire [15:0] FC_ERR_PROP, FC_ERR_ADDR;

integer i;
     
CONTROLLER #(
.BATCH_SIZE(BATCH_SIZE)) controller(
.clk(CLK),
.reset_n(RESET_N),
.start(SRT),
.done_conv_weight1(DONE_CONV_WEIGHT1),
.done_conv_weight2(DONE_CONV_WEIGHT2),
.done_conv_weight3(DONE_CONV_WEIGHT3),
.done_fc_weight1(DONE_FC_WEIGHT1),  
.done_fc_weight2(DONE_FC_WEIGHT2),
.done_img_input(DONE_IMG_INPUT), 
.done_right_answer(DONE_RIGHT_ANSWER),
.done_layer1(DONE_LAYER1),
.done_layer2(DONE_LAYER2),
.done_layer3(DONE_LAYER3),
.done_fc_fwd(DONE_FC_FWD),
.done_fc_bck_prop(DONE_FC_BCK_PROP),
.done_single_learn(DONE_SINGLE_LEARN),
.done_weight_update(/*DONE_WEIGHT_UPDATE*/DONE_FC_BATCH),   //<------swap DONE_WEIGHT_UPDATE, DONE_FC_BATCH

.conv_weight1(CONV_WEIGHT1),
.conv_weight2(CONV_WEIGHT2),
.conv_weight3(CONV_WEIGHT3),
.fc_weight1(FC_WEIGHT1),
.fc_weight2(FC_WEIGHT2),
.img_input(IMG_INPUT),
.right_answer(RIGHT_ANSWER),
.srt_layer1(SRT_LAYER1),
.srt_layer2(SRT_LAYER2),
.srt_layer3(SRT_LAYER3),
.srt_fc_fwd(SRT_FC_FWD),
.fc_bp_srt(FC_BP_SRT),
.layer_3(LAYER_3),
.weight_update(WEIGHT_UPDATE)
);

TOP_MODULE_FC #(                    //<------------------change comment module
.FRT_CELL(FRT_CELL),
.MID_CELL(MID_CELL),
.BCK_CELL(BCK_CELL),
.BATCH_SIZE(BATCH_SIZE)) FC_PART(
.clk(CLK),
.reset_n(RESET_N),
.weight1(FC_WEIGHT1),               //FC weight1 in when 1
.weight2(FC_WEIGHT2),               //FC weight2 in when 1
.right_answer(RIGHT_ANSWER),        //final 10 right answer when 1
.enable(SRT_FC_FWD),                //FC start when 1
.ex_we(WE),                         //flatten input write enable
.ex_value(EX_VALUE),                //flatten input data
.ex_addr(EX_ADDR),                  //flatten input address
.bck_prop_start(FC_BP_SRT),         //back propagation start when 1
.batch_end(WEIGHT_UPDATE),          //32 mini batch finished

.all_end(DONE_FC_FWD),              //signal to controller, FC finished when 1
.fc_bck_prop_end(DONE_FC_BCK_PROP), //propagation in FC finished when 1
.fc_batch_end(DONE_FC_BATCH),
.fc_err_prop(FC_ERR_PROP),          //propagation error from final result
.fc_err_addr(FC_ERR_ADDR)          //propagation address
);

initial
begin
    CLK = 1'b0;
    RESET_N = 1'b0;
    SRT = 1'b0;
    forever #5 CLK = !CLK;
end

initial begin
    #10 RESET_N = 1'b1;             
    #10 SRT = 1'b1;
    #10 DONE_CONV_WEIGHT1 = 1'b1;   #10 DONE_CONV_WEIGHT1 = 1'b0;
    #10 DONE_CONV_WEIGHT2 = 1'b1;   #10 DONE_CONV_WEIGHT2 = 1'b0;
    #10 DONE_CONV_WEIGHT3 = 1'b1;   #10 DONE_CONV_WEIGHT3 = 1'b0;
    
    //fc weight1
    begin           //<-----------change comment
    #10 EX_VALUE = 14; EX_ADDR = 32;WE = 1'b1;
    #10 EX_VALUE = 25; EX_ADDR = 33;
    #10 EX_VALUE = -14; EX_ADDR = 34;
    #10 EX_VALUE = 11; EX_ADDR = 35;
    #10 EX_VALUE = -10; EX_ADDR = 36;
    #10 EX_VALUE = -22; EX_ADDR = 37;
    #10 EX_VALUE = 12; EX_ADDR = 38;
    #10 EX_VALUE = -9; EX_ADDR = 39;
    #10 EX_VALUE = -16; EX_ADDR = 40;
    #10 EX_VALUE = 13; EX_ADDR = 41;
    #10 EX_VALUE = 22; EX_ADDR = 42;
    #10 EX_VALUE = 10; EX_ADDR = 43;
    #10 EX_VALUE = 9; EX_ADDR = 44;
    #10 EX_VALUE = 2; EX_ADDR = 45;
    #10 EX_VALUE = 8; EX_ADDR = 46;
    #10 EX_VALUE = -1; EX_ADDR = 47;
    #10 EX_VALUE = 10; EX_ADDR = 48;
    #10 EX_VALUE = 9; EX_ADDR = 49;
    #10 EX_VALUE = -3; EX_ADDR = 50;
    #10 EX_VALUE = -19; EX_ADDR = 51;
    #10 EX_VALUE = 23; EX_ADDR = 52;
    #10 EX_VALUE = -18; EX_ADDR = 53;
    #10 EX_VALUE = -12; EX_ADDR = 54;
    #10 EX_VALUE = -7; EX_ADDR = 55;
    #10 EX_VALUE = 7; EX_ADDR = 56;
    #10 EX_VALUE = -25; EX_ADDR = 57;
    #10 EX_VALUE = 19; EX_ADDR = 58;
    #10 EX_VALUE = -5; EX_ADDR = 59;
    #10 EX_VALUE = -3; EX_ADDR = 60;
    #10 EX_VALUE = 22; EX_ADDR = 61;
    #10 EX_VALUE = 19; EX_ADDR = 62;
    #10 EX_VALUE = -16; EX_ADDR = 63;
    #10 EX_VALUE = 14; EX_ADDR = 64;
    #10 EX_VALUE = -22; EX_ADDR = 65;
    #10 EX_VALUE = 9; EX_ADDR = 66;
    #10 EX_VALUE = -14; EX_ADDR = 67;
    #10 EX_VALUE = 12; EX_ADDR = 68;
    #10 EX_VALUE = -1; EX_ADDR = 69;
    #10 EX_VALUE = 24; EX_ADDR = 70;
    #10 EX_VALUE = -22; EX_ADDR = 71;
    #10 EX_VALUE = -10; EX_ADDR = 72;
    #10 EX_VALUE = -14; EX_ADDR = 73;
    #10 EX_VALUE = 2; EX_ADDR = 74;
    #10 EX_VALUE = 6; EX_ADDR = 75;
    #10 EX_VALUE = -19; EX_ADDR = 76;
    #10 EX_VALUE = 6; EX_ADDR = 77;
    #10 EX_VALUE = 20; EX_ADDR = 78;
    #10 EX_VALUE = -25; EX_ADDR = 79;
    #10 EX_VALUE = 15; EX_ADDR = 80;
    #10 EX_VALUE = 18; EX_ADDR = 81;
    #10 EX_VALUE = -19; EX_ADDR = 82;
    #10 EX_VALUE = 9; EX_ADDR = 83;
    #10 EX_VALUE = 16; EX_ADDR = 84;
    #10 EX_VALUE = 14; EX_ADDR = 85;
    #10 EX_VALUE = 19; EX_ADDR = 86;
    #10 EX_VALUE = 1; EX_ADDR = 87;
    #10 EX_VALUE = 21; EX_ADDR = 88;
    #10 EX_VALUE = 0; EX_ADDR = 89;
    #10 EX_VALUE = -3; EX_ADDR = 90;
    #10 EX_VALUE = -22; EX_ADDR = 91;
    #10 EX_VALUE = -6; EX_ADDR = 92;
    #10 EX_VALUE = 12; EX_ADDR = 93;
    #10 EX_VALUE = 25; EX_ADDR = 94;
    #10 EX_VALUE = 21; EX_ADDR = 95;
    #10 EX_VALUE = 0; EX_ADDR = 96;
    #10 EX_VALUE = -16; EX_ADDR = 97;
    #10 EX_VALUE = 11; EX_ADDR = 98;
    #10 EX_VALUE = -3; EX_ADDR = 99;
    #10 EX_VALUE = 22; EX_ADDR = 100;
    #10 EX_VALUE = 11; EX_ADDR = 101;
    #10 EX_VALUE = -11; EX_ADDR = 102;
    #10 EX_VALUE = -24; EX_ADDR = 103;
    #10 EX_VALUE = -18; EX_ADDR = 104;
    #10 EX_VALUE = -5; EX_ADDR = 105;
    #10 EX_VALUE = -21; EX_ADDR = 106;
    #10 EX_VALUE = -22; EX_ADDR = 107;
    #10 EX_VALUE = -19; EX_ADDR = 108;
    #10 EX_VALUE = -12; EX_ADDR = 109;
    #10 EX_VALUE = -20; EX_ADDR = 110;
    #10 EX_VALUE = 10; EX_ADDR = 111;
    #10 EX_VALUE = -5; EX_ADDR = 112;
    #10 EX_VALUE = 5; EX_ADDR = 113;
    #10 EX_VALUE = 19; EX_ADDR = 114;
    #10 EX_VALUE = -16; EX_ADDR = 115;
    #10 EX_VALUE = -2; EX_ADDR = 116;
    #10 EX_VALUE = 0; EX_ADDR = 117;
    #10 EX_VALUE = 6; EX_ADDR = 118;
    #10 EX_VALUE = -1; EX_ADDR = 119;
    #10 EX_VALUE = 22; EX_ADDR = 120;
    #10 EX_VALUE = -14; EX_ADDR = 121;
    #10 EX_VALUE = -4; EX_ADDR = 122;
    #10 EX_VALUE = -22; EX_ADDR = 123;
    #10 EX_VALUE = 17; EX_ADDR = 124;
    #10 EX_VALUE = -23; EX_ADDR = 125;
    #10 EX_VALUE = 10; EX_ADDR = 126;
    #10 EX_VALUE = 0; EX_ADDR = 127;
    #10 EX_VALUE = -5; EX_ADDR = 128;
    #10 EX_VALUE = -21; EX_ADDR = 129;
    #10 EX_VALUE = -4; EX_ADDR = 130;
    #10 EX_VALUE = 7; EX_ADDR = 131;
    #10 EX_VALUE = -14; EX_ADDR = 132;
    #10 EX_VALUE = 10; EX_ADDR = 133;
    #10 EX_VALUE = 23; EX_ADDR = 134;
    #10 EX_VALUE = -6; EX_ADDR = 135;
    #10 EX_VALUE = 25; EX_ADDR = 136;
    #10 EX_VALUE = 4; EX_ADDR = 137;
    #10 EX_VALUE = -10; EX_ADDR = 138;
    #10 EX_VALUE = 4; EX_ADDR = 139;
    #10 EX_VALUE = -21; EX_ADDR = 140;
    #10 EX_VALUE = -14; EX_ADDR = 141;
    #10 EX_VALUE = 19; EX_ADDR = 142;
    #10 EX_VALUE = -2; EX_ADDR = 143;
    #10 EX_VALUE = -7; EX_ADDR = 144;
    #10 EX_VALUE = -22; EX_ADDR = 145;
    #10 EX_VALUE = -25; EX_ADDR = 146;
    #10 EX_VALUE = -8; EX_ADDR = 147;
    #10 EX_VALUE = -5; EX_ADDR = 148;
    #10 EX_VALUE = 23; EX_ADDR = 149;
    #10 EX_VALUE = 0; EX_ADDR = 150;
    #10 EX_VALUE = 14; EX_ADDR = 151;
    #10 EX_VALUE = 23; EX_ADDR = 152;
    #10 EX_VALUE = -21; EX_ADDR = 153;
    #10 EX_VALUE = 16; EX_ADDR = 154;
    #10 EX_VALUE = 5; EX_ADDR = 155;
    #10 EX_VALUE = 8; EX_ADDR = 156;
    #10 EX_VALUE = -21; EX_ADDR = 157;
    #10 EX_VALUE = 3; EX_ADDR = 158;
    #10 EX_VALUE = -25; EX_ADDR = 159;
    #10 EX_VALUE = -7; EX_ADDR = 160;
    #10 EX_VALUE = -13; EX_ADDR = 161;
    #10 EX_VALUE = -1; EX_ADDR = 162;
    #10 EX_VALUE = 14; EX_ADDR = 163;
    #10 EX_VALUE = -22; EX_ADDR = 164;
    #10 EX_VALUE = 11; EX_ADDR = 165;
    #10 EX_VALUE = -11; EX_ADDR = 166;
    #10 EX_VALUE = -24; EX_ADDR = 167;
    #10 EX_VALUE = -1; EX_ADDR = 168;
    #10 EX_VALUE = 0; EX_ADDR = 169;
    #10 EX_VALUE = -21; EX_ADDR = 170;
    #10 EX_VALUE = 10; EX_ADDR = 171;
    #10 EX_VALUE = -15; EX_ADDR = 172;
    #10 EX_VALUE = -7; EX_ADDR = 173;
    #10 EX_VALUE = 10; EX_ADDR = 174;
    #10 EX_VALUE = 19; EX_ADDR = 175;
    #10 EX_VALUE = 21; EX_ADDR = 176;
    #10 EX_VALUE = 17; EX_ADDR = 177;
    #10 EX_VALUE = 15; EX_ADDR = 178;
    #10 EX_VALUE = 25; EX_ADDR = 179;
    #10 EX_VALUE = 16; EX_ADDR = 180;
    #10 EX_VALUE = 4; EX_ADDR = 181;
    #10 EX_VALUE = -6; EX_ADDR = 182;
    #10 EX_VALUE = 16; EX_ADDR = 183;
    #10 EX_VALUE = 11; EX_ADDR = 184;
    #10 EX_VALUE = -25; EX_ADDR = 185;
    #10 EX_VALUE = 0; EX_ADDR = 186;
    #10 EX_VALUE = -7; EX_ADDR = 187;
    #10 EX_VALUE = -5; EX_ADDR = 188;
    #10 EX_VALUE = -10; EX_ADDR = 189;
    #10 EX_VALUE = 8; EX_ADDR = 190;
    #10 EX_VALUE = -15; EX_ADDR = 191;
    #10 EX_VALUE = 0; EX_ADDR = 192;
    #10 EX_VALUE = 6; EX_ADDR = 193;
    #10 EX_VALUE = -18; EX_ADDR = 194;
    #10 EX_VALUE = 8; EX_ADDR = 195;
    #10 EX_VALUE = 12; EX_ADDR = 196;
    #10 EX_VALUE = 1; EX_ADDR = 197;
    #10 EX_VALUE = -18; EX_ADDR = 198;
    #10 EX_VALUE = 9; EX_ADDR = 199;
    #10 EX_VALUE = 9; EX_ADDR = 200;
    #10 EX_VALUE = 16; EX_ADDR = 201;
    #10 EX_VALUE = 10; EX_ADDR = 202;
    #10 EX_VALUE = -25; EX_ADDR = 203;
    #10 EX_VALUE = 24; EX_ADDR = 204;
    #10 EX_VALUE = -23; EX_ADDR = 205;
    #10 EX_VALUE = -14; EX_ADDR = 206;
    #10 EX_VALUE = -7; EX_ADDR = 207;
    #10 EX_VALUE = 20; EX_ADDR = 208;
    #10 EX_VALUE = 18; EX_ADDR = 209;
    #10 EX_VALUE = 12; EX_ADDR = 210;
    #10 EX_VALUE = 2; EX_ADDR = 211;
    #10 EX_VALUE = 3; EX_ADDR = 212;
    #10 EX_VALUE = 2; EX_ADDR = 213;
    #10 EX_VALUE = 20; EX_ADDR = 214;
    #10 EX_VALUE = 25; EX_ADDR = 215;
    #10 EX_VALUE = -17; EX_ADDR = 216;
    #10 EX_VALUE = 4; EX_ADDR = 217;
    #10 EX_VALUE = 8; EX_ADDR = 218;
    #10 EX_VALUE = -14; EX_ADDR = 219;
    #10 EX_VALUE = 7; EX_ADDR = 220;
    #10 EX_VALUE = 5; EX_ADDR = 221;
    #10 EX_VALUE = -10; EX_ADDR = 222;
    #10 EX_VALUE = -4; EX_ADDR = 223;
    #10 EX_VALUE = -7; EX_ADDR = 224;
    #10 EX_VALUE = 22; EX_ADDR = 225;
    #10 EX_VALUE = -1; EX_ADDR = 226;
    #10 EX_VALUE = 9; EX_ADDR = 227;
    #10 EX_VALUE = -11; EX_ADDR = 228;
    #10 EX_VALUE = 22; EX_ADDR = 229;
    #10 EX_VALUE = -8; EX_ADDR = 230;
    #10 EX_VALUE = 3; EX_ADDR = 231;
    #10 EX_VALUE = -10; EX_ADDR = 232;
    #10 EX_VALUE = -2; EX_ADDR = 233;
    #10 EX_VALUE = 2; EX_ADDR = 234;
    #10 EX_VALUE = 0; EX_ADDR = 235;
    #10 EX_VALUE = -8; EX_ADDR = 236;
    #10 EX_VALUE = -25; EX_ADDR = 237;
    #10 EX_VALUE = -20; EX_ADDR = 238;
    #10 EX_VALUE = 3; EX_ADDR = 239;
    #10 EX_VALUE = 14; EX_ADDR = 240;
    #10 EX_VALUE = 4; EX_ADDR = 241;
    #10 EX_VALUE = 9; EX_ADDR = 242;
    #10 EX_VALUE = -10; EX_ADDR = 243;
    #10 EX_VALUE = 21; EX_ADDR = 244;
    #10 EX_VALUE = -15; EX_ADDR = 245;
    #10 EX_VALUE = -25; EX_ADDR = 246;
    #10 EX_VALUE = -20; EX_ADDR = 247;
    #10 EX_VALUE = -20; EX_ADDR = 248;
    #10 EX_VALUE = 21; EX_ADDR = 249;
    #10 EX_VALUE = 14; EX_ADDR = 250;
    #10 EX_VALUE = 24; EX_ADDR = 251;
    #10 EX_VALUE = -5; EX_ADDR = 252;
    #10 EX_VALUE = 0; EX_ADDR = 253;
    #10 EX_VALUE = 13; EX_ADDR = 254;
    #10 EX_VALUE = 0; EX_ADDR = 255;
    #10 EX_VALUE = -3; EX_ADDR = 256;
    #10 EX_VALUE = 25; EX_ADDR = 257;
    #10 EX_VALUE = -21; EX_ADDR = 258;
    #10 EX_VALUE = 24; EX_ADDR = 259;
    #10 EX_VALUE = 14; EX_ADDR = 260;
    #10 EX_VALUE = -13; EX_ADDR = 261;
    #10 EX_VALUE = 1; EX_ADDR = 262;
    #10 EX_VALUE = 13; EX_ADDR = 263;
    #10 EX_VALUE = -16; EX_ADDR = 264;
    #10 EX_VALUE = -13; EX_ADDR = 265;
    #10 EX_VALUE = 0; EX_ADDR = 266;
    #10 EX_VALUE = 11; EX_ADDR = 267;
    #10 EX_VALUE = 10; EX_ADDR = 268;
    #10 EX_VALUE = -16; EX_ADDR = 269;
    #10 EX_VALUE = -19; EX_ADDR = 270;
    #10 EX_VALUE = -13; EX_ADDR = 271;
    #10 EX_VALUE = 22; EX_ADDR = 272;
    #10 EX_VALUE = 0; EX_ADDR = 273;
    #10 EX_VALUE = 0; EX_ADDR = 274;
    #10 EX_VALUE = -11; EX_ADDR = 275;
    #10 EX_VALUE = 10; EX_ADDR = 276;
    #10 EX_VALUE = 1; EX_ADDR = 277;
    #10 EX_VALUE = -16; EX_ADDR = 278;
    #10 EX_VALUE = 22; EX_ADDR = 279;
    #10 EX_VALUE = 24; EX_ADDR = 280;
    #10 EX_VALUE = 21; EX_ADDR = 281;
    #10 EX_VALUE = -19; EX_ADDR = 282;
    #10 EX_VALUE = -22; EX_ADDR = 283;
    #10 EX_VALUE = 20; EX_ADDR = 284;
    #10 EX_VALUE = -11; EX_ADDR = 285;
    #10 EX_VALUE = -20; EX_ADDR = 286;
    #10 EX_VALUE = 11; EX_ADDR = 287;
    #10 EX_VALUE = -25; EX_ADDR = 288;
    #10 EX_VALUE = -14; EX_ADDR = 289;
    #10 EX_VALUE = 22; EX_ADDR = 290;
    #10 EX_VALUE = -23; EX_ADDR = 291;
    #10 EX_VALUE = 0; EX_ADDR = 292;
    #10 EX_VALUE = 21; EX_ADDR = 293;
    #10 EX_VALUE = -24; EX_ADDR = 294;
    #10 EX_VALUE = 0; EX_ADDR = 295;
    #10 EX_VALUE = 3; EX_ADDR = 296;
    #10 EX_VALUE = 8; EX_ADDR = 297;
    #10 EX_VALUE = -15; EX_ADDR = 298;
    #10 EX_VALUE = 25; EX_ADDR = 299;
    #10 EX_VALUE = 24; EX_ADDR = 300;
    #10 EX_VALUE = 15; EX_ADDR = 301;
    #10 EX_VALUE = -7; EX_ADDR = 302;
    #10 EX_VALUE = 12; EX_ADDR = 303;
    #10 EX_VALUE = -25; EX_ADDR = 304;
    #10 EX_VALUE = -20; EX_ADDR = 305;
    #10 EX_VALUE = -17; EX_ADDR = 306;
    #10 EX_VALUE = -17; EX_ADDR = 307;
    #10 EX_VALUE = 10; EX_ADDR = 308;
    #10 EX_VALUE = -19; EX_ADDR = 309;
    #10 EX_VALUE = 18; EX_ADDR = 310;
    #10 EX_VALUE = -17; EX_ADDR = 311;
    #10 EX_VALUE = -23; EX_ADDR = 312;
    #10 EX_VALUE = -6; EX_ADDR = 313;
    #10 EX_VALUE = -13; EX_ADDR = 314;
    #10 EX_VALUE = 8; EX_ADDR = 315;
    #10 EX_VALUE = -17; EX_ADDR = 316;
    #10 EX_VALUE = -21; EX_ADDR = 317;
    #10 EX_VALUE = -7; EX_ADDR = 318;
    #10 EX_VALUE = 22; EX_ADDR = 319;
    #10 EX_VALUE = 19; EX_ADDR = 320;
    #10 EX_VALUE = 12; EX_ADDR = 321;
    #10 EX_VALUE = 11; EX_ADDR = 322;
    #10 EX_VALUE = 24; EX_ADDR = 323;
    #10 EX_VALUE = 18; EX_ADDR = 324;
    #10 EX_VALUE = 25; EX_ADDR = 325;
    #10 EX_VALUE = 5; EX_ADDR = 326;
    #10 EX_VALUE = 9; EX_ADDR = 327;
    #10 EX_VALUE = -16; EX_ADDR = 328;
    #10 EX_VALUE = 21; EX_ADDR = 329;
    #10 EX_VALUE = 23; EX_ADDR = 330;
    #10 EX_VALUE = 6; EX_ADDR = 331;
    #10 EX_VALUE = -2; EX_ADDR = 332;
    #10 EX_VALUE = -25; EX_ADDR = 333;
    #10 EX_VALUE = 5; EX_ADDR = 334;
    #10 EX_VALUE = 1; EX_ADDR = 335;
    #10 EX_VALUE = 6; EX_ADDR = 336;
    #10 EX_VALUE = -13; EX_ADDR = 337;
    #10 EX_VALUE = -22; EX_ADDR = 338;
    #10 EX_VALUE = 9; EX_ADDR = 339;
    #10 EX_VALUE = -23; EX_ADDR = 340;
    #10 EX_VALUE = -19; EX_ADDR = 341;
    #10 EX_VALUE = 4; EX_ADDR = 342;
    #10 EX_VALUE = 8; EX_ADDR = 343;
    #10 EX_VALUE = 8; EX_ADDR = 344;
    #10 EX_VALUE = 23; EX_ADDR = 345;
    #10 EX_VALUE = 6; EX_ADDR = 346;
    #10 EX_VALUE = 6; EX_ADDR = 347;
    #10 EX_VALUE = -19; EX_ADDR = 348;
    #10 EX_VALUE = -19; EX_ADDR = 349;
    #10 EX_VALUE = 7; EX_ADDR = 350;
    #10 EX_VALUE = 23; EX_ADDR = 351;
    #10 EX_VALUE = 4; EX_ADDR = 352;
    #10 EX_VALUE = -9; EX_ADDR = 353;
    #10 EX_VALUE = -21; EX_ADDR = 354;
    #10 EX_VALUE = -11; EX_ADDR = 355;
    #10 EX_VALUE = 20; EX_ADDR = 356;
    #10 EX_VALUE = 20; EX_ADDR = 357;
    #10 EX_VALUE = -17; EX_ADDR = 358;
    #10 EX_VALUE = 6; EX_ADDR = 359;
    #10 EX_VALUE = -1; EX_ADDR = 360;
    #10 EX_VALUE = 23; EX_ADDR = 361;
    #10 EX_VALUE = -10; EX_ADDR = 362;
    #10 EX_VALUE = 18; EX_ADDR = 363;
    #10 EX_VALUE = 14; EX_ADDR = 364;
    #10 EX_VALUE = 6; EX_ADDR = 365;
    #10 EX_VALUE = 14; EX_ADDR = 366;
    #10 EX_VALUE = -25; EX_ADDR = 367;
    #10 EX_VALUE = -18; EX_ADDR = 368;
    #10 EX_VALUE = 21; EX_ADDR = 369;
    #10 EX_VALUE = 0; EX_ADDR = 370;
    #10 EX_VALUE = -19; EX_ADDR = 371;
    #10 EX_VALUE = -2; EX_ADDR = 372;
    #10 EX_VALUE = 21; EX_ADDR = 373;
    #10 EX_VALUE = -21; EX_ADDR = 374;
    #10 EX_VALUE = 7; EX_ADDR = 375;
    #10 EX_VALUE = -22; EX_ADDR = 376;
    #10 EX_VALUE = 25; EX_ADDR = 377;
    #10 EX_VALUE = 24; EX_ADDR = 378;
    #10 EX_VALUE = -12; EX_ADDR = 379;
    #10 EX_VALUE = 9; EX_ADDR = 380;
    #10 EX_VALUE = -20; EX_ADDR = 381;
    #10 EX_VALUE = 6; EX_ADDR = 382;
    #10 EX_VALUE = 16; EX_ADDR = 383;
    #10 EX_VALUE = -8; EX_ADDR = 384;
    #10 EX_VALUE = -12; EX_ADDR = 385;
    #10 EX_VALUE = 2; EX_ADDR = 386;
    #10 EX_VALUE = -24; EX_ADDR = 387;
    #10 EX_VALUE = -20; EX_ADDR = 388;
    #10 EX_VALUE = -9; EX_ADDR = 389;
    #10 EX_VALUE = 25; EX_ADDR = 390;
    #10 EX_VALUE = -6; EX_ADDR = 391;
    #10 EX_VALUE = -20; EX_ADDR = 392;
    #10 EX_VALUE = 23; EX_ADDR = 393;
    #10 EX_VALUE = 23; EX_ADDR = 394;
    #10 EX_VALUE = 1; EX_ADDR = 395;
    #10 EX_VALUE = 7; EX_ADDR = 396;
    #10 EX_VALUE = 12; EX_ADDR = 397;
    #10 EX_VALUE = -22; EX_ADDR = 398;
    #10 EX_VALUE = 1; EX_ADDR = 399;
    #10 EX_VALUE = -13; EX_ADDR = 400;
    #10 EX_VALUE = 25; EX_ADDR = 401;
    #10 EX_VALUE = 10; EX_ADDR = 402;
    #10 EX_VALUE = 13; EX_ADDR = 403;
    #10 EX_VALUE = 1; EX_ADDR = 404;
    #10 EX_VALUE = -19; EX_ADDR = 405;
    #10 EX_VALUE = -2; EX_ADDR = 406;
    #10 EX_VALUE = -12; EX_ADDR = 407;
    #10 EX_VALUE = -16; EX_ADDR = 408;
    #10 EX_VALUE = -5; EX_ADDR = 409;
    #10 EX_VALUE = 15; EX_ADDR = 410;
    #10 EX_VALUE = -22; EX_ADDR = 411;
    #10 EX_VALUE = 5; EX_ADDR = 412;
    #10 EX_VALUE = -15; EX_ADDR = 413;
    #10 EX_VALUE = -14; EX_ADDR = 414;
    #10 EX_VALUE = 10; EX_ADDR = 415;
    #10 EX_VALUE = -25; EX_ADDR = 416;
    #10 EX_VALUE = -8; EX_ADDR = 417;
    #10 EX_VALUE = -2; EX_ADDR = 418;
    #10 EX_VALUE = -21; EX_ADDR = 419;
    #10 EX_VALUE = -13; EX_ADDR = 420;
    #10 EX_VALUE = -15; EX_ADDR = 421;
    #10 EX_VALUE = -18; EX_ADDR = 422;
    #10 EX_VALUE = 23; EX_ADDR = 423;
    #10 EX_VALUE = 7; EX_ADDR = 424;
    #10 EX_VALUE = 9; EX_ADDR = 425;
    #10 EX_VALUE = -21; EX_ADDR = 426;
    #10 EX_VALUE = 22; EX_ADDR = 427;
    #10 EX_VALUE = -21; EX_ADDR = 428;
    #10 EX_VALUE = -13; EX_ADDR = 429;
    #10 EX_VALUE = -7; EX_ADDR = 430;
    #10 EX_VALUE = -9; EX_ADDR = 431;
    #10 EX_VALUE = 9; EX_ADDR = 432;
    #10 EX_VALUE = -16; EX_ADDR = 433;
    #10 EX_VALUE = -18; EX_ADDR = 434;
    #10 EX_VALUE = -10; EX_ADDR = 435;
    #10 EX_VALUE = -23; EX_ADDR = 436;
    #10 EX_VALUE = -14; EX_ADDR = 437;
    #10 EX_VALUE = -20; EX_ADDR = 438;
    #10 EX_VALUE = -15; EX_ADDR = 439;
    #10 EX_VALUE = 3; EX_ADDR = 440;
    #10 EX_VALUE = 7; EX_ADDR = 441;
    #10 EX_VALUE = -9; EX_ADDR = 442;
    #10 EX_VALUE = -1; EX_ADDR = 443;
    #10 EX_VALUE = 25; EX_ADDR = 444;
    #10 EX_VALUE = 5; EX_ADDR = 445;
    #10 EX_VALUE = -2; EX_ADDR = 446;
    #10 EX_VALUE = 17; EX_ADDR = 447;
    #10 EX_VALUE = 6; EX_ADDR = 448;
    #10 EX_VALUE = 23; EX_ADDR = 449;
    #10 EX_VALUE = 25; EX_ADDR = 450;
    #10 EX_VALUE = -9; EX_ADDR = 451;
    #10 EX_VALUE = 9; EX_ADDR = 452;
    #10 EX_VALUE = -1; EX_ADDR = 453;
    #10 EX_VALUE = 1; EX_ADDR = 454;
    #10 EX_VALUE = -21; EX_ADDR = 455;
    #10 EX_VALUE = -18; EX_ADDR = 456;
    #10 EX_VALUE = -4; EX_ADDR = 457;
    #10 EX_VALUE = -11; EX_ADDR = 458;
    #10 EX_VALUE = 12; EX_ADDR = 459;
    #10 EX_VALUE = -4; EX_ADDR = 460;
    #10 EX_VALUE = -6; EX_ADDR = 461;
    #10 EX_VALUE = -11; EX_ADDR = 462;
    #10 EX_VALUE = 19; EX_ADDR = 463;
    #10 EX_VALUE = 2; EX_ADDR = 464;
    #10 EX_VALUE = -6; EX_ADDR = 465;
    #10 EX_VALUE = 2; EX_ADDR = 466;
    #10 EX_VALUE = -18; EX_ADDR = 467;
    #10 EX_VALUE = 15; EX_ADDR = 468;
    #10 EX_VALUE = 5; EX_ADDR = 469;
    #10 EX_VALUE = -9; EX_ADDR = 470;
    #10 EX_VALUE = 2; EX_ADDR = 471;
    #10 EX_VALUE = 8; EX_ADDR = 472;
    #10 EX_VALUE = -6; EX_ADDR = 473;
    #10 EX_VALUE = -8; EX_ADDR = 474;
    #10 EX_VALUE = -19; EX_ADDR = 475;
    #10 EX_VALUE = 23; EX_ADDR = 476;
    #10 EX_VALUE = 10; EX_ADDR = 477;
    #10 EX_VALUE = -4; EX_ADDR = 478;
    #10 EX_VALUE = -7; EX_ADDR = 479;
    #10 EX_VALUE = -2; EX_ADDR = 480;
    #10 EX_VALUE = 21; EX_ADDR = 481;
    #10 EX_VALUE = -6; EX_ADDR = 482;
    #10 EX_VALUE = -4; EX_ADDR = 483;
    #10 EX_VALUE = 10; EX_ADDR = 484;
    #10 EX_VALUE = -14; EX_ADDR = 485;
    #10 EX_VALUE = -1; EX_ADDR = 486;
    #10 EX_VALUE = 17; EX_ADDR = 487;
    #10 EX_VALUE = 23; EX_ADDR = 488;
    #10 EX_VALUE = 16; EX_ADDR = 489;
    #10 EX_VALUE = 20; EX_ADDR = 490;
    #10 EX_VALUE = 3; EX_ADDR = 491;
    #10 EX_VALUE = 0; EX_ADDR = 492;
    #10 EX_VALUE = 11; EX_ADDR = 493;
    #10 EX_VALUE = -24; EX_ADDR = 494;
    #10 EX_VALUE = 6; EX_ADDR = 495;
    #10 EX_VALUE = 9; EX_ADDR = 496;
    #10 EX_VALUE = 25; EX_ADDR = 497;
    #10 EX_VALUE = -13; EX_ADDR = 498;
    #10 EX_VALUE = 24; EX_ADDR = 499;
    #10 EX_VALUE = -13; EX_ADDR = 500;
    #10 EX_VALUE = -13; EX_ADDR = 501;
    #10 EX_VALUE = -21; EX_ADDR = 502;
    #10 EX_VALUE = 22; EX_ADDR = 503;
    #10 EX_VALUE = 13; EX_ADDR = 504;
    #10 EX_VALUE = 9; EX_ADDR = 505;
    #10 EX_VALUE = 16; EX_ADDR = 506;
    #10 EX_VALUE = 1; EX_ADDR = 507;
    #10 EX_VALUE = 18; EX_ADDR = 508;
    #10 EX_VALUE = 9; EX_ADDR = 509;
    #10 EX_VALUE = -21; EX_ADDR = 510;
    #10 EX_VALUE = -6; EX_ADDR = 511;
    #10 EX_VALUE = -15; EX_ADDR = 512;
    #10 EX_VALUE = -5; EX_ADDR = 513;
    #10 EX_VALUE = -11; EX_ADDR = 514;
    #10 EX_VALUE = 2; EX_ADDR = 515;
    #10 EX_VALUE = -1; EX_ADDR = 516;
    #10 EX_VALUE = 7; EX_ADDR = 517;
    #10 EX_VALUE = -3; EX_ADDR = 518;
    #10 EX_VALUE = -14; EX_ADDR = 519;
    #10 EX_VALUE = 8; EX_ADDR = 520;
    #10 EX_VALUE = 12; EX_ADDR = 521;
    #10 EX_VALUE = -2; EX_ADDR = 522;
    #10 EX_VALUE = 6; EX_ADDR = 523;
    #10 EX_VALUE = -18; EX_ADDR = 524;
    #10 EX_VALUE = -8; EX_ADDR = 525;
    #10 EX_VALUE = 5; EX_ADDR = 526;
    #10 EX_VALUE = 18; EX_ADDR = 527;
    #10 EX_VALUE = -23; EX_ADDR = 528;
    #10 EX_VALUE = 13; EX_ADDR = 529;
    #10 EX_VALUE = -21; EX_ADDR = 530;
    #10 EX_VALUE = 12; EX_ADDR = 531;
    #10 EX_VALUE = 13; EX_ADDR = 532;
    #10 EX_VALUE = 23; EX_ADDR = 533;
    #10 EX_VALUE = -2; EX_ADDR = 534;
    #10 EX_VALUE = 7; EX_ADDR = 535;
    #10 EX_VALUE = 22; EX_ADDR = 536;
    #10 EX_VALUE = 4; EX_ADDR = 537;
    #10 EX_VALUE = -14; EX_ADDR = 538;
    #10 EX_VALUE = -17; EX_ADDR = 539;
    #10 EX_VALUE = -6; EX_ADDR = 540;
    #10 EX_VALUE = 25; EX_ADDR = 541;
    #10 EX_VALUE = 11; EX_ADDR = 542;
    #10 EX_VALUE = -8; EX_ADDR = 543;
    #10 EX_VALUE = -10; EX_ADDR = 544;
    #10 EX_VALUE = 5; EX_ADDR = 545;
    #10 EX_VALUE = -2; EX_ADDR = 546;
    #10 EX_VALUE = 23; EX_ADDR = 547;
    #10 EX_VALUE = 5; EX_ADDR = 548;
    #10 EX_VALUE = 10; EX_ADDR = 549;
    #10 EX_VALUE = 22; EX_ADDR = 550;
    #10 EX_VALUE = -25; EX_ADDR = 551;
    #10 EX_VALUE = -20; EX_ADDR = 552;
    #10 EX_VALUE = -9; EX_ADDR = 553;
    #10 EX_VALUE = -5; EX_ADDR = 554;
    #10 EX_VALUE = -18; EX_ADDR = 555;
    #10 EX_VALUE = -5; EX_ADDR = 556;
    #10 EX_VALUE = -22; EX_ADDR = 557;
    #10 EX_VALUE = -17; EX_ADDR = 558;
    #10 EX_VALUE = 16; EX_ADDR = 559;
    #10 EX_VALUE = 21; EX_ADDR = 560;
    #10 EX_VALUE = -23; EX_ADDR = 561;
    #10 EX_VALUE = -9; EX_ADDR = 562;
    #10 EX_VALUE = -1; EX_ADDR = 563;
    #10 EX_VALUE = 4; EX_ADDR = 564;
    #10 EX_VALUE = 6; EX_ADDR = 565;
    #10 EX_VALUE = 16; EX_ADDR = 566;
    #10 EX_VALUE = 19; EX_ADDR = 567;
    #10 EX_VALUE = -11; EX_ADDR = 568;
    #10 EX_VALUE = 6; EX_ADDR = 569;
    #10 EX_VALUE = 17; EX_ADDR = 570;
    #10 EX_VALUE = 2; EX_ADDR = 571;
    #10 EX_VALUE = -12; EX_ADDR = 572;
    #10 EX_VALUE = -6; EX_ADDR = 573;
    #10 EX_VALUE = 20; EX_ADDR = 574;
    #10 EX_VALUE = 14; EX_ADDR = 575;
    #10 EX_VALUE = -1; EX_ADDR = 576;
    #10 EX_VALUE = -10; EX_ADDR = 577;
    #10 EX_VALUE = -5; EX_ADDR = 578;
    #10 EX_VALUE = 15; EX_ADDR = 579;
    #10 EX_VALUE = -24; EX_ADDR = 580;
    #10 EX_VALUE = -14; EX_ADDR = 581;
    #10 EX_VALUE = 1; EX_ADDR = 582;
    #10 EX_VALUE = 22; EX_ADDR = 583;
    #10 EX_VALUE = 17; EX_ADDR = 584;
    #10 EX_VALUE = -24; EX_ADDR = 585;
    #10 EX_VALUE = 0; EX_ADDR = 586;
    #10 EX_VALUE = 8; EX_ADDR = 587;
    #10 EX_VALUE = 9; EX_ADDR = 588;
    #10 EX_VALUE = 20; EX_ADDR = 589;
    #10 EX_VALUE = 0; EX_ADDR = 590;
    #10 EX_VALUE = -2; EX_ADDR = 591;
    #10 EX_VALUE = -17; EX_ADDR = 592;
    #10 EX_VALUE = 9; EX_ADDR = 593;
    #10 EX_VALUE = -1; EX_ADDR = 594;
    #10 EX_VALUE = 0; EX_ADDR = 595;
    #10 EX_VALUE = 1; EX_ADDR = 596;
    #10 EX_VALUE = -16; EX_ADDR = 597;
    #10 EX_VALUE = 18; EX_ADDR = 598;
    #10 EX_VALUE = -4; EX_ADDR = 599;
    #10 EX_VALUE = -15; EX_ADDR = 600;
    #10 EX_VALUE = 23; EX_ADDR = 601;
    #10 EX_VALUE = 23; EX_ADDR = 602;
    #10 EX_VALUE = -19; EX_ADDR = 603;
    #10 EX_VALUE = -18; EX_ADDR = 604;
    #10 EX_VALUE = 17; EX_ADDR = 605;
    #10 EX_VALUE = -25; EX_ADDR = 606;
    #10 EX_VALUE = 9; EX_ADDR = 607;
    #10 EX_VALUE = 22; EX_ADDR = 608;
    #10 EX_VALUE = -7; EX_ADDR = 609;
    #10 EX_VALUE = -6; EX_ADDR = 610;
    #10 EX_VALUE = 3; EX_ADDR = 611;
    #10 EX_VALUE = -7; EX_ADDR = 612;
    #10 EX_VALUE = -1; EX_ADDR = 613;
    #10 EX_VALUE = -23; EX_ADDR = 614;
    #10 EX_VALUE = -10; EX_ADDR = 615;
    #10 EX_VALUE = 9; EX_ADDR = 616;
    #10 EX_VALUE = -25; EX_ADDR = 617;
    #10 EX_VALUE = -22; EX_ADDR = 618;
    #10 EX_VALUE = 15; EX_ADDR = 619;
    #10 EX_VALUE = -22; EX_ADDR = 620;
    #10 EX_VALUE = 3; EX_ADDR = 621;
    #10 EX_VALUE = -21; EX_ADDR = 622;
    #10 EX_VALUE = 19; EX_ADDR = 623;
    #10 EX_VALUE = 0; EX_ADDR = 624;
    #10 EX_VALUE = 10; EX_ADDR = 625;
    #10 EX_VALUE = 14; EX_ADDR = 626;
    #10 EX_VALUE = -23; EX_ADDR = 627;
    #10 EX_VALUE = 18; EX_ADDR = 628;
    #10 EX_VALUE = -4; EX_ADDR = 629;
    #10 EX_VALUE = 12; EX_ADDR = 630;
    #10 EX_VALUE = 0; EX_ADDR = 631;
    #10 EX_VALUE = 17; EX_ADDR = 632;
    #10 EX_VALUE = 9; EX_ADDR = 633;
    #10 EX_VALUE = -4; EX_ADDR = 634;
    #10 EX_VALUE = -2; EX_ADDR = 635;
    #10 EX_VALUE = -12; EX_ADDR = 636;
    #10 EX_VALUE = -20; EX_ADDR = 637;
    #10 EX_VALUE = -2; EX_ADDR = 638;
    #10 EX_VALUE = 3; EX_ADDR = 639;
    #10 EX_VALUE = -17; EX_ADDR = 640;
    #10 EX_VALUE = -13; EX_ADDR = 641;
    #10 EX_VALUE = 24; EX_ADDR = 642;
    #10 EX_VALUE = 16; EX_ADDR = 643;
    #10 EX_VALUE = 18; EX_ADDR = 644;
    #10 EX_VALUE = -24; EX_ADDR = 645;
    #10 EX_VALUE = 19; EX_ADDR = 646;
    #10 EX_VALUE = -20; EX_ADDR = 647;
    #10 EX_VALUE = -3; EX_ADDR = 648;
    #10 EX_VALUE = -25; EX_ADDR = 649;
    #10 EX_VALUE = -15; EX_ADDR = 650;
    #10 EX_VALUE = 1; EX_ADDR = 651;
    #10 EX_VALUE = 25; EX_ADDR = 652;
    #10 EX_VALUE = 9; EX_ADDR = 653;
    #10 EX_VALUE = -3; EX_ADDR = 654;
    #10 EX_VALUE = -23; EX_ADDR = 655;
    #10 EX_VALUE = -25; EX_ADDR = 656;
    #10 EX_VALUE = 17; EX_ADDR = 657;
    #10 EX_VALUE = -25; EX_ADDR = 658;
    #10 EX_VALUE = 25; EX_ADDR = 659;
    #10 EX_VALUE = -24; EX_ADDR = 660;
    #10 EX_VALUE = -14; EX_ADDR = 661;
    #10 EX_VALUE = 5; EX_ADDR = 662;
    #10 EX_VALUE = -9; EX_ADDR = 663;
    #10 EX_VALUE = 2; EX_ADDR = 664;
    #10 EX_VALUE = -6; EX_ADDR = 665;
    #10 EX_VALUE = 15; EX_ADDR = 666;
    #10 EX_VALUE = -11; EX_ADDR = 667;
    #10 EX_VALUE = 9; EX_ADDR = 668;
    #10 EX_VALUE = -8; EX_ADDR = 669;
    #10 EX_VALUE = -10; EX_ADDR = 670;
    #10 EX_VALUE = 21; EX_ADDR = 671;
    #10 WE = 1'b0;
    end
    
    #10 DONE_FC_WEIGHT1 = 1'b1;     #10 DONE_FC_WEIGHT1 = 1'b0;
    
    //fc weight2
    begin           //<-----------change comment
    #10 EX_VALUE = -24; EX_ADDR = 20; WE=1'b1;
    #10 EX_VALUE = 23; EX_ADDR = 21;
    #10 EX_VALUE = -24; EX_ADDR = 22;
    #10 EX_VALUE = 13; EX_ADDR = 23;
    #10 EX_VALUE = 25; EX_ADDR = 24;
    #10 EX_VALUE = 8; EX_ADDR = 25;
    #10 EX_VALUE = 24; EX_ADDR = 26;
    #10 EX_VALUE = 24; EX_ADDR = 27;
    #10 EX_VALUE = 11; EX_ADDR = 28;
    #10 EX_VALUE = 14; EX_ADDR = 29;
    #10 EX_VALUE = 16; EX_ADDR = 30;
    #10 EX_VALUE = -21; EX_ADDR = 31;
    #10 EX_VALUE = 24; EX_ADDR = 32;
    #10 EX_VALUE = 6; EX_ADDR = 33;
    #10 EX_VALUE = 15; EX_ADDR = 34;
    #10 EX_VALUE = 7; EX_ADDR = 35;
    #10 EX_VALUE = 10; EX_ADDR = 36;
    #10 EX_VALUE = 9; EX_ADDR = 37;
    #10 EX_VALUE = 21; EX_ADDR = 38;
    #10 EX_VALUE = 12; EX_ADDR = 39;
    #10 EX_VALUE = -11; EX_ADDR = 40;
    #10 EX_VALUE = 12; EX_ADDR = 41;
    #10 EX_VALUE = 21; EX_ADDR = 42;
    #10 EX_VALUE = 0; EX_ADDR = 43;
    #10 EX_VALUE = -20; EX_ADDR = 44;
    #10 EX_VALUE = -23; EX_ADDR = 45;
    #10 EX_VALUE = 1; EX_ADDR = 46;
    #10 EX_VALUE = 11; EX_ADDR = 47;
    #10 EX_VALUE = 1; EX_ADDR = 48;
    #10 EX_VALUE = -1; EX_ADDR = 49;
    #10 EX_VALUE = 23; EX_ADDR = 50;
    #10 EX_VALUE = -22; EX_ADDR = 51;
    #10 EX_VALUE = 11; EX_ADDR = 52;
    #10 EX_VALUE = -3; EX_ADDR = 53;
    #10 EX_VALUE = 10; EX_ADDR = 54;
    #10 EX_VALUE = -5; EX_ADDR = 55;
    #10 EX_VALUE = 22; EX_ADDR = 56;
    #10 EX_VALUE = -24; EX_ADDR = 57;
    #10 EX_VALUE = 24; EX_ADDR = 58;
    #10 EX_VALUE = 13; EX_ADDR = 59;
    #10 EX_VALUE = 4; EX_ADDR = 60;
    #10 EX_VALUE = -23; EX_ADDR = 61;
    #10 EX_VALUE = 5; EX_ADDR = 62;
    #10 EX_VALUE = -7; EX_ADDR = 63;
    #10 EX_VALUE = -22; EX_ADDR = 64;
    #10 EX_VALUE = -13; EX_ADDR = 65;
    #10 EX_VALUE = 5; EX_ADDR = 66;
    #10 EX_VALUE = -15; EX_ADDR = 67;
    #10 EX_VALUE = -9; EX_ADDR = 68;
    #10 EX_VALUE = -22; EX_ADDR = 69;
    #10 EX_VALUE = 11; EX_ADDR = 70;
    #10 EX_VALUE = -17; EX_ADDR = 71;
    #10 EX_VALUE = 1; EX_ADDR = 72;
    #10 EX_VALUE = -20; EX_ADDR = 73;
    #10 EX_VALUE = -4; EX_ADDR = 74;
    #10 EX_VALUE = 12; EX_ADDR = 75;
    #10 EX_VALUE = 21; EX_ADDR = 76;
    #10 EX_VALUE = 14; EX_ADDR = 77;
    #10 EX_VALUE = -8; EX_ADDR = 78;
    #10 EX_VALUE = -17; EX_ADDR = 79;
    #10 EX_VALUE = -7; EX_ADDR = 80;
    #10 EX_VALUE = 13; EX_ADDR = 81;
    #10 EX_VALUE = 24; EX_ADDR = 82;
    #10 EX_VALUE = 3; EX_ADDR = 83;
    #10 EX_VALUE = -24; EX_ADDR = 84;
    #10 EX_VALUE = -19; EX_ADDR = 85;
    #10 EX_VALUE = -14; EX_ADDR = 86;
    #10 EX_VALUE = 19; EX_ADDR = 87;
    #10 EX_VALUE = -24; EX_ADDR = 88;
    #10 EX_VALUE = 17; EX_ADDR = 89;
    #10 EX_VALUE = -2; EX_ADDR = 90;
    #10 EX_VALUE = 22; EX_ADDR = 91;
    #10 EX_VALUE = -18; EX_ADDR = 92;
    #10 EX_VALUE = 1; EX_ADDR = 93;
    #10 EX_VALUE = 20; EX_ADDR = 94;
    #10 EX_VALUE = 9; EX_ADDR = 95;
    #10 EX_VALUE = 14; EX_ADDR = 96;
    #10 EX_VALUE = 12; EX_ADDR = 97;
    #10 EX_VALUE = -5; EX_ADDR = 98;
    #10 EX_VALUE = -23; EX_ADDR = 99;
    #10 EX_VALUE = -16; EX_ADDR = 100;
    #10 EX_VALUE = 16; EX_ADDR = 101;
    #10 EX_VALUE = -11; EX_ADDR = 102;
    #10 EX_VALUE = 11; EX_ADDR = 103;
    #10 EX_VALUE = -25; EX_ADDR = 104;
    #10 EX_VALUE = 24; EX_ADDR = 105;
    #10 EX_VALUE = 11; EX_ADDR = 106;
    #10 EX_VALUE = -24; EX_ADDR = 107;
    #10 EX_VALUE = 8; EX_ADDR = 108;
    #10 EX_VALUE = 25; EX_ADDR = 109;
    #10 EX_VALUE = -1; EX_ADDR = 110;
    #10 EX_VALUE = 6; EX_ADDR = 111;
    #10 EX_VALUE = 14; EX_ADDR = 112;
    #10 EX_VALUE = -14; EX_ADDR = 113;
    #10 EX_VALUE = -16; EX_ADDR = 114;
    #10 EX_VALUE = 17; EX_ADDR = 115;
    #10 EX_VALUE = -8; EX_ADDR = 116;
    #10 EX_VALUE = -22; EX_ADDR = 117;
    #10 EX_VALUE = -6; EX_ADDR = 118;
    #10 EX_VALUE = 22; EX_ADDR = 119;
    #10 EX_VALUE = -14; EX_ADDR = 120;
    #10 EX_VALUE = -15; EX_ADDR = 121;
    #10 EX_VALUE = 22; EX_ADDR = 122;
    #10 EX_VALUE = -6; EX_ADDR = 123;
    #10 EX_VALUE = 20; EX_ADDR = 124;
    #10 EX_VALUE = 25; EX_ADDR = 125;
    #10 EX_VALUE = 17; EX_ADDR = 126;
    #10 EX_VALUE = -17; EX_ADDR = 127;
    #10 EX_VALUE = -4; EX_ADDR = 128;
    #10 EX_VALUE = 8; EX_ADDR = 129;
    #10 EX_VALUE = -10; EX_ADDR = 130;
    #10 EX_VALUE = 13; EX_ADDR = 131;
    #10 EX_VALUE = -1; EX_ADDR = 132;
    #10 EX_VALUE = -23; EX_ADDR = 133;
    #10 EX_VALUE = 23; EX_ADDR = 134;
    #10 EX_VALUE = 1; EX_ADDR = 135;
    #10 EX_VALUE = 5; EX_ADDR = 136;
    #10 EX_VALUE = -17; EX_ADDR = 137;
    #10 EX_VALUE = -25; EX_ADDR = 138;
    #10 EX_VALUE = 21; EX_ADDR = 139;
    #10 EX_VALUE = -17; EX_ADDR = 140;
    #10 EX_VALUE = 24; EX_ADDR = 141;
    #10 EX_VALUE = 3; EX_ADDR = 142;
    #10 EX_VALUE = 11; EX_ADDR = 143;
    #10 EX_VALUE = -1; EX_ADDR = 144;
    #10 EX_VALUE = 1; EX_ADDR = 145;
    #10 EX_VALUE = 20; EX_ADDR = 146;
    #10 EX_VALUE = -8; EX_ADDR = 147;
    #10 EX_VALUE = 3; EX_ADDR = 148;
    #10 EX_VALUE = 5; EX_ADDR = 149;
    #10 EX_VALUE = -8; EX_ADDR = 150;
    #10 EX_VALUE = -17; EX_ADDR = 151;
    #10 EX_VALUE = 11; EX_ADDR = 152;
    #10 EX_VALUE = 24; EX_ADDR = 153;
    #10 EX_VALUE = 24; EX_ADDR = 154;
    #10 EX_VALUE = -22; EX_ADDR = 155;
    #10 EX_VALUE = -15; EX_ADDR = 156;
    #10 EX_VALUE = 24; EX_ADDR = 157;
    #10 EX_VALUE = -11; EX_ADDR = 158;
    #10 EX_VALUE = 13; EX_ADDR = 159;
    #10 EX_VALUE = 19; EX_ADDR = 160;
    #10 EX_VALUE = 14; EX_ADDR = 161;
    #10 EX_VALUE = -23; EX_ADDR = 162;
    #10 EX_VALUE = -18; EX_ADDR = 163;
    #10 EX_VALUE = 12; EX_ADDR = 164;
    #10 EX_VALUE = 9; EX_ADDR = 165;
    #10 EX_VALUE = 3; EX_ADDR = 166;
    #10 EX_VALUE = 5; EX_ADDR = 167;
    #10 EX_VALUE = -6; EX_ADDR = 168;
    #10 EX_VALUE = 0; EX_ADDR = 169;
    #10 EX_VALUE = 10; EX_ADDR = 170;
    #10 EX_VALUE = 2; EX_ADDR = 171;
    #10 EX_VALUE = 14; EX_ADDR = 172;
    #10 EX_VALUE = 10; EX_ADDR = 173;
    #10 EX_VALUE = -22; EX_ADDR = 174;
    #10 EX_VALUE = -12; EX_ADDR = 175;
    #10 EX_VALUE = 18; EX_ADDR = 176;
    #10 EX_VALUE = 9; EX_ADDR = 177;
    #10 EX_VALUE = -14; EX_ADDR = 178;
    #10 EX_VALUE = -19; EX_ADDR = 179;
    #10 EX_VALUE = -16; EX_ADDR = 180;
    #10 EX_VALUE = 4; EX_ADDR = 181;
    #10 EX_VALUE = 10; EX_ADDR = 182;
    #10 EX_VALUE = 12; EX_ADDR = 183;
    #10 EX_VALUE = 2; EX_ADDR = 184;
    #10 EX_VALUE = 18; EX_ADDR = 185;
    #10 EX_VALUE = 17; EX_ADDR = 186;
    #10 EX_VALUE = -22; EX_ADDR = 187;
    #10 EX_VALUE = -7; EX_ADDR = 188;
    #10 EX_VALUE = 24; EX_ADDR = 189;
    #10 EX_VALUE = -12; EX_ADDR = 190;
    #10 EX_VALUE = -17; EX_ADDR = 191;
    #10 EX_VALUE = 24; EX_ADDR = 192;
    #10 EX_VALUE = -8; EX_ADDR = 193;
    #10 EX_VALUE = 4; EX_ADDR = 194;
    #10 EX_VALUE = 14; EX_ADDR = 195;
    #10 EX_VALUE = 25; EX_ADDR = 196;
    #10 EX_VALUE = -12; EX_ADDR = 197;
    #10 EX_VALUE = 5; EX_ADDR = 198;
    #10 EX_VALUE = 12; EX_ADDR = 199;
    #10 EX_VALUE = -10; EX_ADDR = 200;
    #10 EX_VALUE = 10; EX_ADDR = 201;
    #10 EX_VALUE = -20; EX_ADDR = 202;
    #10 EX_VALUE = -22; EX_ADDR = 203;
    #10 EX_VALUE = -19; EX_ADDR = 204;
    #10 EX_VALUE = 10; EX_ADDR = 205;
    #10 EX_VALUE = 0; EX_ADDR = 206;
    #10 EX_VALUE = -4; EX_ADDR = 207;
    #10 EX_VALUE = -18; EX_ADDR = 208;
    #10 EX_VALUE = -3; EX_ADDR = 209;
    #10 EX_VALUE = -23; EX_ADDR = 210;
    #10 EX_VALUE = -15; EX_ADDR = 211;
    #10 EX_VALUE = 22; EX_ADDR = 212;
    #10 EX_VALUE = -4; EX_ADDR = 213;
    #10 EX_VALUE = -4; EX_ADDR = 214;
    #10 EX_VALUE = -23; EX_ADDR = 215;
    #10 EX_VALUE = 13; EX_ADDR = 216;
    #10 EX_VALUE = -2; EX_ADDR = 217;
    #10 EX_VALUE = 24; EX_ADDR = 218;
    #10 EX_VALUE = -22; EX_ADDR = 219;
    #10 WE = 1'b0;
    end
    
    #10 DONE_FC_WEIGHT2 = 1'b1;     #10 DONE_FC_WEIGHT2 = 1'b0;
    #10 DONE_IMG_INPUT = 1'b1;      #10 DONE_IMG_INPUT = 1'b0;
    
    //right answer
    begin           //<-----------change comment
    #10 EX_VALUE = 0; EX_ADDR = 10; WE = 1'b1;
    #10 EX_VALUE = 0; EX_ADDR = 11;
    #10 EX_VALUE = 0; EX_ADDR = 12;
    #10 EX_VALUE = 1536; EX_ADDR = 13;
    #10 EX_VALUE = 0; EX_ADDR = 14;
    #10 EX_VALUE = 0; EX_ADDR = 15;
    #10 EX_VALUE = 0; EX_ADDR = 16;
    #10 EX_VALUE = 0; EX_ADDR = 17;
    #10 EX_VALUE = 0; EX_ADDR = 18;
    #10 EX_VALUE = 0; EX_ADDR = 19;
    #10 WE = 1'b0;
    end
    
    #10 DONE_RIGHT_ANSWER = 1'b1;   #10 DONE_RIGHT_ANSWER = 1'b0;
    #10 DONE_LAYER1 = 1'b1;         #10 DONE_LAYER1 = 1'b0;
    #10 DONE_LAYER2 = 1'b1;         #10 DONE_LAYER2 = 1'b0;
    
    //flatten value(for test)
    begin           //<-----------change comment
    #10 EX_VALUE = 6; EX_ADDR = 0; WE=1'b1;
    #10 EX_VALUE = 15; EX_ADDR = 1;
    #10 EX_VALUE = 114; EX_ADDR = 2;
    #10 EX_VALUE = 38; EX_ADDR = 3;
    #10 EX_VALUE = 449; EX_ADDR = 4;
    #10 EX_VALUE = 6; EX_ADDR = 5;
    #10 EX_VALUE = 954; EX_ADDR = 6;
    #10 EX_VALUE = 2; EX_ADDR = 7;
    #10 EX_VALUE = 3; EX_ADDR = 8;
    #10 EX_VALUE = 51; EX_ADDR = 9;
    #10 EX_VALUE = 39; EX_ADDR = 10;
    #10 EX_VALUE = 70; EX_ADDR = 11;
    #10 EX_VALUE = 16; EX_ADDR = 12;
    #10 EX_VALUE = 257; EX_ADDR = 13;
    #10 EX_VALUE = 173; EX_ADDR = 14;
    #10 EX_VALUE = 5; EX_ADDR = 15;
    #10 EX_VALUE = 151; EX_ADDR = 16;
    #10 EX_VALUE = 0; EX_ADDR = 17;
    #10 EX_VALUE = 178; EX_ADDR = 18;
    #10 EX_VALUE = 63; EX_ADDR = 19;
    #10 EX_VALUE = 825; EX_ADDR = 20;
    #10 EX_VALUE = 108; EX_ADDR = 21;
    #10 EX_VALUE = 307; EX_ADDR = 22;
    #10 EX_VALUE = 19; EX_ADDR = 23;
    #10 EX_VALUE = 8; EX_ADDR = 24;
    #10 EX_VALUE = 4; EX_ADDR = 25;
    #10 EX_VALUE = 8; EX_ADDR = 26;
    #10 EX_VALUE = 65; EX_ADDR = 27;
    #10 EX_VALUE = 5; EX_ADDR = 28;
    #10 EX_VALUE = 578; EX_ADDR = 29;
    #10 EX_VALUE = 22; EX_ADDR = 30;
    #10 EX_VALUE = 2; EX_ADDR = 31;
    #10 WE = 1'b0;
    end
    
    #10 DONE_LAYER3 = 1'b1;         #10 DONE_LAYER3 = 1'b0;
    //#10 DONE_FC_FWD = 1'b1;         #10 DONE_FC_FWD = 1'b0;       //<--------change comment
    //#10 DONE_FC_BCK_PROP = 1'b1;    #10 DONE_FC_BCK_PROP = 1'b0;  //<--------change comment
    wait(DONE_FC_BCK_PROP);                                         //<--------change comment
    #10 DONE_SINGLE_LEARN = 1'b1;   #10 DONE_SINGLE_LEARN = 1'b0;
    
    /*for(i=0; i<31; i=i+1) begin                                   //<--------change comment
        #10 DONE_IMG_INPUT = 1'b1;      #10 DONE_IMG_INPUT = 1'b0;
        #10 DONE_RIGHT_ANSWER = 1'b1;   #10 DONE_RIGHT_ANSWER = 1'b0;
        #10 DONE_LAYER1 = 1'b1;         #10 DONE_LAYER1 = 1'b0;
        #10 DONE_LAYER2 = 1'b1;         #10 DONE_LAYER2 = 1'b0;
        #10 DONE_LAYER3 = 1'b1;         #10 DONE_LAYER3 = 1'b0;
        #10 DONE_FC_FWD = 1'b1;         #10 DONE_FC_FWD = 1'b0;
        #10 DONE_FC_BCK_PROP = 1'b1;    #10 DONE_FC_BCK_PROP = 1'b0;
        #10 DONE_SINGLE_LEARN = 1'B1;   #10 DONE_SINGLE_LEARN = 1'B0;
    end*/
    wait(DONE_FC_BATCH);
    //#10 DONE_WEIGHT_UPDATE = 1'B1;      #10 DONE_WEIGHT_UPDATE = 1'B0;
    /*
    #10 DONE_CONV_WEIGHT1 = 1'b1;   #10 DONE_CONV_WEIGHT1 = 1'b0;   //<--------change comment
    #10 DONE_CONV_WEIGHT2 = 1'b1;   #10 DONE_CONV_WEIGHT2 = 1'b0;
    #10 DONE_CONV_WEIGHT3 = 1'b1;   #10 DONE_CONV_WEIGHT3 = 1'b0;
    #10 DONE_FC_WEIGHT1 = 1'b1;     #10 DONE_FC_WEIGHT1 = 1'b0;
    #10 DONE_FC_WEIGHT2 = 1'b1;     #10 DONE_FC_WEIGHT2 = 1'b0;
    #10 DONE_IMG_INPUT = 1'b1;      #10 DONE_IMG_INPUT = 1'b0;
    #10 DONE_RIGHT_ANSWER = 1'b1;   #10 DONE_RIGHT_ANSWER = 1'b0;
    #10 DONE_LAYER1 = 1'b1;         #10 DONE_LAYER1 = 1'b0;
    #10 DONE_LAYER2 = 1'b1;         #10 DONE_LAYER2 = 1'b0;
    #10 DONE_LAYER3 = 1'b1;         #10 DONE_LAYER3 = 1'b0;
    #10 DONE_FC_FWD = 1'b1;         #10 DONE_FC_FWD = 1'b0;
    #10 DONE_FC_BCK_PROP = 1'b1;    #10 DONE_FC_BCK_PROP = 1'b0;
    #10 DONE_SINGLE_LEARN = 1'B1;   #10 DONE_SINGLE_LEARN = 1'B0;*/
    //---------------------------------------------------------------------//<-------change comment below at the end of this initial block
    #10 DONE_IMG_INPUT = 1'b1;      #10 DONE_IMG_INPUT = 1'b0;
    #10 DONE_RIGHT_ANSWER = 1'b1;   #10 DONE_RIGHT_ANSWER = 1'b0;
    #10 DONE_LAYER1 = 1'b1;         #10 DONE_LAYER1 = 1'b0;
    #10 DONE_LAYER2 = 1'b1;         #10 DONE_LAYER2 = 1'b0;
    begin
        #10 EX_VALUE = 282; EX_ADDR = 0;WE=1'b1;
        #10 EX_VALUE = 462; EX_ADDR = 1;
        #10 EX_VALUE = 583; EX_ADDR = 2;
        #10 EX_VALUE = 365; EX_ADDR = 3;
        #10 EX_VALUE = 867; EX_ADDR = 4;
        #10 EX_VALUE = 259; EX_ADDR = 5;
        #10 EX_VALUE = 348; EX_ADDR = 6;
        #10 EX_VALUE = 702; EX_ADDR = 7;
        #10 EX_VALUE = 4; EX_ADDR = 8;
        #10 EX_VALUE = 195; EX_ADDR = 9;
        #10 EX_VALUE = 572; EX_ADDR = 10;
        #10 EX_VALUE = 469; EX_ADDR = 11;
        #10 EX_VALUE = 687; EX_ADDR = 12;
        #10 EX_VALUE = 880; EX_ADDR = 13;
        #10 EX_VALUE = 715; EX_ADDR = 14;
        #10 EX_VALUE = 55; EX_ADDR = 15;
        #10 EX_VALUE = 49; EX_ADDR = 16;
        #10 EX_VALUE = 914; EX_ADDR = 17;
        #10 EX_VALUE = 194; EX_ADDR = 18;
        #10 EX_VALUE = 270; EX_ADDR = 19;
        #10 EX_VALUE = 846; EX_ADDR = 20;
        #10 EX_VALUE = 820; EX_ADDR = 21;
        #10 EX_VALUE = 117; EX_ADDR = 22;
        #10 EX_VALUE = 182; EX_ADDR = 23;
        #10 EX_VALUE = 903; EX_ADDR = 24;
        #10 EX_VALUE = 727; EX_ADDR = 25;
        #10 EX_VALUE = 739; EX_ADDR = 26;
        #10 EX_VALUE = 663; EX_ADDR = 27;
        #10 EX_VALUE = 887; EX_ADDR = 28;
        #10 EX_VALUE = 366; EX_ADDR = 29;
        #10 EX_VALUE = 755; EX_ADDR = 30;
        #10 EX_VALUE = 140; EX_ADDR = 31;
        #10 WE = 1'B0;
    end
    #10 DONE_LAYER3 = 1'b1;         #10 DONE_LAYER3 = 1'b0;
    wait(DONE_FC_BCK_PROP);  
    #10 DONE_SINGLE_LEARN = 1'b1;   #10 DONE_SINGLE_LEARN = 1'b0;
    //---------------------------------------------------------------------
    wait(DONE_FC_BATCH);
    #10 DONE_IMG_INPUT = 1'b1;      #10 DONE_IMG_INPUT = 1'b0;
    #10 DONE_RIGHT_ANSWER = 1'b1;   #10 DONE_RIGHT_ANSWER = 1'b0;
    #10 DONE_LAYER1 = 1'b1;         #10 DONE_LAYER1 = 1'b0;
    #10 DONE_LAYER2 = 1'b1;         #10 DONE_LAYER2 = 1'b0;
    #10 DONE_LAYER3 = 1'b1;         #10 DONE_LAYER3 = 1'b0;
    wait(DONE_FC_BCK_PROP);
    #10 DONE_SINGLE_LEARN = 1'b1;   #10 DONE_SINGLE_LEARN = 1'b0;
end

initial
begin
    wait(DONE_FC_BATCH);        //<------------change comment
    #1000 wait(DONE_FC_BATCH);  //<------------change comment
    #1000 wait(DONE_FC_BATCH);  //<------------change comment
    //wait(DONE_WEIGHT_UPDATE);       //<-----------change comment
    #10 $stop;
end

endmodule