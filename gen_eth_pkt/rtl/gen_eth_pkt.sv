module gen_eth_pkt #(
  parameter DATA_W    = 32,
  parameter CHANNEL_W = 10,
  parameter EMPTY_W   = $clog2(DATA_W/8) ?  $clog2(DATA_W/8) : 1,

  parameter SPEED_GEN  = 1000, // Speed generator in Mbps
  parameter MODE       = "FULL DUPLEX",

  // Packet --- Sended via avalon-st
  // Ethernet header in bytes
  parameter PREAMBLE              = 7, 
  parameter START_FRAME_DELIMITER = 1,
  parameter MAC_DESTINATION       = 6,
  parameter MAC_SOURCE            = 6,
  parameter TAG                   = 4,    // optional
  parameter ETHERTYPE             = 2,
  parameter PAYLOAD               = 1500, // 46-1500 bytes
  parameter FRAME_CHECK_SEQ       = 4,    // 32-bit crc
  parameter INTERPACKET_GAP       = 12,
  
  //Control --- Sended via avalon-mm
  parameter AMM_DATA = 64
) (
  input logic clk_i,
  input logic srst_i 
);

always_ff @( posedge clk_i )
  begin
    
  end

endmodule