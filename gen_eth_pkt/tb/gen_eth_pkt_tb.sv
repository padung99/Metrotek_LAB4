import avl_st_pkg::*;

module gen_eth_pkt_tb;

parameter DATA_W_TB    = 32;
parameter CHANNEL_W_TB = 10;
parameter EMPTY_W_TB   = $clog2(DATA_W/8) ?  $clog2(DATA_W/8) : 1;

parameter SPEED_GEN_TB  = 1000; // Speed generator in Mbps
parameter MODE_TB       = "FULL_DUPLEX";

// Ethernet header
parameter PREAMBLE_TB              = 7; //bytes
parameter START_FRAME_DELIMITER_TB = 1;
parameter MAC_DESTINATION_TB       = 6;
parameter MAC_SOURCE_TB            = 6;
parameter TAG_TB                   = 4; // optional
parameter ETHERTYPE_TB             = 2;
parameter PAYLOAD_TB               = 1200; // 46-1500 bytes
parameter FRAME_CHECK_SEQ_TB       = 4; // 32-bit crc
parameter INTERPACKET_GAP_TB       = 12; 


bit clk_tb;

initial
  forever
    #5 clk_tb = !clk_tb;

default clocking cb
  @( posedge clk_tb );
endclocking


ast_control #(
  .DATA_W    ( DATA_W    ),
  .CHANNEL_W ( CHANNEL_W ),
  .EMPTY_W   ( EMPTY_W   )
) ast_send_pkt;

//Send ethernet packet via ast
avalon_st_if #(
  .DATA_W    ( DATA_W    ),
  .CHANNEL_W ( CHANNEL_W ),
  .EMPTY_W   ( EMPTY_W   )
) ast_snk_if (
    .clk ( clk_tb )
);

initial
  begin
    
  end

endmodule