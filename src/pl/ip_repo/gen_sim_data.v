// *********************************************************************************
// Project Name : OSXXXX
// Author       : dengkanwen
// Email        : dengkanwen@163.com
// Website      : http://www.opensoc.cn/
// Create Time  : 2021-08-10 20:13:03
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

module  gen_sim_data(
        // system signals
        input                   sclk                    ,       
        input                   s_rst_n                 ,       
        //
        output  wire            vsync                   ,
        output  reg             bin_data_vld            ,
        output  wire    [ 7:0]  bin_data                
);

//========================================================================\
// =========== Define Parameter and Internal signals =========== 
//========================================================================/

reg     [ 6:0]                  col_cnt                         ;
reg     [ 8:0]                  row_cnt                         ;

reg     [ 9:0]                  rd_addr                         ;

//=============================================================================
//**************    Main Code   **************
//=============================================================================
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                col_cnt <=      'd0;
        else if(col_cnt == 'd127)
                col_cnt <=      'd0;
        else
                col_cnt <=      col_cnt + 1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                row_cnt <=      'd0;
/*         else if(row_cnt == 'd300 && col_cnt == 'd127)
                row_cnt <=      'd0; */
        else if(col_cnt == 'd127 && row_cnt <= 'd120)
                row_cnt <=      row_cnt + 1'b1;
end

assign  vsync   =       (row_cnt == 'd0 && col_cnt == 'd1) ? 1'b1 : 1'b0;

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                bin_data_vld    <=      1'b0;
        else if(row_cnt <= 'd111 && col_cnt >= 'd9 && col_cnt <= 'd120)
                bin_data_vld    <=      1'b1;
        else
                bin_data_vld    <=      1'b0;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                rd_addr <=      'd0;
        else if(vsync == 1'b1)
                rd_addr <=      'd0;
        else if(row_cnt <= 'd111 && col_cnt >= 'd9 && col_cnt <= 'd120 && row_cnt[1:0] == 'd0 && col_cnt[1:0] == 'd1)
                rd_addr <=      rd_addr + 1'b1;
end


rom_img_ip rom_img_ip (
        .clka                   (sclk                   ),    // input wire clka
        .addra                  (rd_addr                ),  // input wire [9 : 0] addra
        .douta                  (bin_data               )// output wire [7 : 0] douta
);

endmodule
