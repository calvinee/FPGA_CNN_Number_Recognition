// *********************************************************************************
// Project Name : OSXXXX
// Author       : dengkanwen
// Email        : dengkanwen@163.com
// Website      : http://www.opensoc.cn/
// Create Time  : 2021-08-10 18:12:47
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

module  pool_layer(
        // system signals
        input                   sclk                    ,       
        input                   s_rst_n                 ,       
        //
        input           [31:0]  act_data                ,
        input                   act_data_vld            ,       
        input                   cal_start               ,       
        //
        output  reg     [31:0]  pool_data               ,
        output  reg             pool_data_vld           ,       
        output  reg             active_video            ,       
        output  wire            vid_hsync               ,
        output  wire            vid_ce                         
);

//========================================================================\
// =========== Define Parameter and Internal signals =========== 
//========================================================================/
reg     [ 4:0]                  row_cnt                         ;       
reg     [ 4:0]                  col_cnt                         ;       
reg     [31:0]                  act_data_r1                     ;
reg     [31:0]                  fifo_wr_data                    ;
reg                             fifo_wr_en                      ;       

wire    [31:0]                  fifo_rd_data                    ;       
wire                            fifo_rd_en                      ;       
reg     [31:0]                  max_data                        ;

//=============================================================================
//**************    Main Code   **************
//=============================================================================

assign  fifo_rd_en      =       (col_cnt[0] == 1'b0 && row_cnt[0] == 1'b1) ? act_data_vld : 1'b0;
assign  vid_hsync       =       ~active_video;
assign  vid_ce          =       pool_data_vld | vid_hsync; 

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                col_cnt <=      'd0;
        else if(col_cnt == 'd23 && act_data_vld == 1'b1)
                col_cnt <=      'd0;
        else if(act_data_vld == 1'b1)
                col_cnt <=      col_cnt + 1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                row_cnt <=      'd0;
        else if(row_cnt == 'd23 && act_data_vld == 1'b1 && col_cnt == 'd23)
                row_cnt <=      'd0;
        else if(act_data_vld == 1'b1 && col_cnt == 'd23)
                row_cnt <=      row_cnt + 1'b1;
end

always  @(posedge sclk) begin
        act_data_r1     <=      act_data;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                fifo_wr_data    <=      'd0;
        else if(row_cnt[0] == 1'b0 && col_cnt[0] == 1'b1 && act_data_vld == 1'b1) begin
                if(act_data_r1 > act_data)
                        fifo_wr_data    <=      act_data_r1;
                else
                        fifo_wr_data    <=      act_data;
        end
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                fifo_wr_en      <=      1'b0;
        else if(row_cnt[0] == 1'b0 && col_cnt[0] == 1'b1 && act_data_vld == 1'b1)
                fifo_wr_en      <=      1'b1;
        else
                fifo_wr_en      <=      1'b0;
end


always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                max_data        <=      'd0;
        else if(fifo_rd_en == 1'b1 && fifo_rd_data > act_data)
                max_data        <=      fifo_rd_data;
        else if(fifo_rd_en == 1'b1)
                max_data        <=      act_data; 
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                pool_data       <=      'd0;
        else if(row_cnt[0] == 1'b1 && col_cnt[0] == 1'b1) begin
                if(max_data > act_data)
                        pool_data       <=      max_data;
                else
                        pool_data       <=      act_data;
        end
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                pool_data_vld   <=      1'b0;
        else if(row_cnt[0] == 1'b1 && col_cnt[0] == 1'b1)
                pool_data_vld   <=      1'b1;
        else
                pool_data_vld   <=      1'b0;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                active_video    <=      1'b0;
        else if(act_data_vld == 1'b0 && pool_data_vld == 1'b1)
                active_video    <=      1'b0;
        else if(row_cnt[0] == 1'b1 && col_cnt == 'd1)
                active_video    <=      1'b1;
end

fifo_generator_0 fifo_generator_0 (
        .clk                    (sclk                   ),      // input wire clk
        .srst                   (~s_rst_n | cal_start   ),    // input wire srst
        .din                    (fifo_wr_data           ),      // input wire [30 : 0] din
        .wr_en                  (fifo_wr_en             ),  // input wire wr_en
        .rd_en                  (fifo_rd_en             ),  // input wire rd_en
        .dout                   (fifo_rd_data           ),    // output wire [30 : 0] dout
        .full                   (                       ),    // output wire full
        .empty                  (                       )// output wire empty
);


endmodule
