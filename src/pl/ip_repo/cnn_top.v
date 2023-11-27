// *********************************************************************************
// Project Name : OSXXXX
// Author       : dengkanwen
// Email        : dengkanwen@163.com
// Website      : http://www.opensoc.cn/
// Create Time  : 2021-08-10 19:45:20
// File Name    : .v
// Module Name  : 
// Called By    :
// Abstract     :
//
// CopyRight(c) 2018, OpenSoc Studio.. 
// All Rights Reserved
//
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2021-08-10    Kevin           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns

module  cnn_top(
        // system signals
        input                   sclk                    ,       
        input                   s_rst_n                 ,       
        // CMOS Data
        input                   bin_data                ,       
        input                   bin_data_vld            ,       
        //
        output  wire    [31:0]  pool_data               ,
        output  wire            pool_data_vld           ,       
        output  wire            active_video            ,       
        output  wire            vid_hsync               ,
        output  wire            vid_ce                         

);


//========================================================================\
// =========== Define Parameter and Internal signals =========== 
//========================================================================/
wire                            down_data                       ;       
wire                            down_data_vld                   ;       
wire    [ 6:0]                  down_col_cnt                    ;       
wire    [ 6:0]                  down_row_cnt                    ;       

wire    [ 4:0]                  data_rd_addr                    ;       
wire    [ 4:0]                  conv_row_cnt                    ;       
wire    [ 4:0]                  col_data                        ;       
wire                            cal_start                       ;       


wire    [ 7:0]                  param_rd_addr                   ;       
wire    [ 4:0]                  conv_cnt                        ;       
wire    [15:0]                  param_w_h0                      ;       
wire    [15:0]                  param_w_h1                      ;       
wire    [15:0]                  param_w_h2                      ;       
wire    [15:0]                  param_w_h3                      ;       
wire    [15:0]                  param_w_h4                      ;       
wire    [15:0]                  param_bias                      ;       


wire    [31:0]                  conv_rslt_act                   ;       
wire                            conv_rslt_act_vld               ;       

//=============================================================================
//**************    Main Code   **************
//=============================================================================
downsample      downsample_inst(
        // system signals
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        //
        .bin_data               (bin_data               ),
        .bin_data_vld           (bin_data_vld           ),
        //
        .col_cnt                (down_col_cnt           ),
        .row_cnt                (down_row_cnt           ),
        .down_data              (down_data              ),
        .down_data_vld          (down_data_vld          )
);

data_ram        data_ram_inst(
        // system singals
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        // downsample
        .down_data              (down_data              ),
        .down_data_vld          (down_data_vld          ),
        .down_col_cnt           (down_col_cnt           ),
        .down_row_cnt           (down_row_cnt           ),
        // Conv Cal
        .data_rd_addr           (data_rd_addr           ),
        .conv_row_cnt           (conv_row_cnt           ),
        .col_data               (col_data               ),
        .cal_start              (cal_start              )
);

param_rom       param_rom_inst(
        // system signals
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        //
        .param_rd_addr          (param_rd_addr          ),
        .conv_cnt               (conv_cnt               ),
        .param_w_h0             (param_w_h0             ),
        .param_w_h1             (param_w_h1             ),
        .param_w_h2             (param_w_h2             ),
        .param_w_h3             (param_w_h3             ),
        .param_w_h4             (param_w_h4             ),
        .param_bias             (param_bias             )
);

conv_cal        conv_cal_inst(
        // system signals
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        // DATA RAM
        .data_rd_addr           (data_rd_addr           ),
        .row_cnt                (conv_row_cnt           ),
        .col_data               (col_data               ),
        .cal_start              (cal_start              ),
        // PARAM ROM
        .param_rd_addr          (param_rd_addr          ),
        .conv_cnt               (conv_cnt               ),
        .param_w_h0             (param_w_h0             ),
        .param_w_h1             (param_w_h1             ),
        .param_w_h2             (param_w_h2             ),
        .param_w_h3             (param_w_h3             ),
        .param_w_h4             (param_w_h4             ),
        .param_bias             (param_bias             ),
        // 
        .conv_rslt_act          (conv_rslt_act          ),
        .conv_rslt_act_vld      (conv_rslt_act_vld      )
);


pool_layer      pool_layer_inst(
        // system signals
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        //
        .act_data               (conv_rslt_act          ),
        .act_data_vld           (conv_rslt_act_vld      ),
        .cal_start              (cal_start              ),
        //
        .pool_data              (pool_data              ),
        .pool_data_vld          (pool_data_vld          ),
        .active_video           (active_video           ),
        .vid_hsync              (vid_hsync              ),
        .vid_ce                 (vid_ce                 )
);

endmodule
