`timescale      1ns/1ns 

module  tb_cnn_top;

reg             sclk;
reg             s_rst_n;

initial begin
        sclk    =       1;
        s_rst_n <=      0;
        #100
        s_rst_n <=      1;
end

always  #5      sclk    =       ~sclk;



wire    [31:0]  pool_data              ;
wire            pool_data_vld          ;      
wire            active_video           ;      
wire            vid_hsync              ;
wire            vid_ce                 ;     


gen_sim_data    gen_sim_data_inst(
        // system signals
        .sclk                   (sclk           ),       
        .s_rst_n                (s_rst_n        ),       
        //                      
        .vsync                  (vsync          ),
        .bin_data_vld           (bin_data_vld   ),
        .bin_data               (bin_data       )
);

cnn_top         cnn_top_inst(
        // system signals
        .sclk                   (sclk           ),       
        .s_rst_n                (s_rst_n        ),   
        // CMOS Data    
        .bin_data_vld           (bin_data_vld   ),
        .bin_data               (bin_data       ),  
        //
        .pool_data              (pool_data      ),
        .pool_data_vld          (pool_data_vld  ),       
        .active_video           (active_video   ),       
        .vid_hsync              (vid_hsync      ),
        .vid_ce                 (vid_ce         )       

);









endmodule