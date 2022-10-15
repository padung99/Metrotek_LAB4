module gen_eth_pkt #(
  parameter DATA_W    = 32, // 1 WORD = 32 bits
  parameter CHANNEL_W = 10,
  parameter EMPTY_W   = $clog2(DATA_W/8) ?  $clog2(DATA_W/8) : 1,

  // // // Generator running mode
  // parameter SPEED_GEN  = 1000, // Speed generator in Mbps
  // parameter MODE       = "FULL DUPLEX",

  // // Packet --- Sended via Avalon-st
  // // Ethernet frame in bytes
  parameter PREAMBLE              = 7, 
  parameter START_FRAME_DELIMITER = 1,
  parameter MAC_DESTINATION       = 6,
  parameter MAC_SOURCE            = 6,
  parameter TAG                   = 4,    // optional
  parameter ETHERTYPE             = 2,
  parameter PAYLOAD               = 1500, // 46-1500 bytes
  parameter FRAME_CHECK_SEQ       = 4,    // 32-bit crc
  parameter INTERPACKET_GAP       = 12,
  
  // // Control --- Sended via Avalon-mm
  // // MAC Register
  parameter DWORD_W                     = 4,          // 1 DWORD = 4 bytes
  parameter BASE_CONFIGURATION          = 24*DWORD_W, // DWORD: 0x00 -- 0x17
  parameter STATISTICS_COUNTER          = 33*DWORD_W, // DWORD: 0x18 -- 0x38
  parameter TRANSMIT_COMMAND            = 1*DWORD_W,  // DWORD: 0x3A
  parameter RECEIVE_COMMAND             = 1*DWORD_W,  // DWORD: 0x3B
  parameter EXTENDED_STATISTICS_COUNTER = 3*DWORD_W,  // DWORD: 0x3C -- 0x3E
  // parameter REVERSED1 // UNUSED                    // DWORD: 0x3F
  parameter MULTICAST_HASH_TABLE        = 64*DWORD_W, // DWORD: 0x40 -- 0x7F
  parameter MDIO_SPACE_0                = 32*DWORD_W, // DWORD: 0x80 -- 0x9F
  parameter MDIO_SPACE_1                = 32*DWORD_W, // DWORD: 0xA0 -- 0xBF
  parameter SUPPLEMENTARY_ADDRESS       = 8*DWORD_W,  // DWORD: 0xC0 -- 0xC7
  // parameter REVERSED2 // UNUSED                    // DWORD: 0xC8 -- 0xCF
  parameter IEEE_1588V2_FEATURE         = 7*DWORD_W,  // DWORD: 0xD0 -- 0xD6
  // parameter REVERSED3 // UNUSED                    // DWORD: 0xD7 -- 0xE0
  parameter DETERMINISTIC_LATENCY       = 3*DWORD_W   // DWORD: 0xE1 -- 0xE3

) (
  input  logic              clk_i,
  input  logic              srst_i,
  
  // // Avalon-st interface -- Receving ethernet frame
  input  logic [DATA_W-1:0] ast_snk_data_i,
  input  logic              ast_snk_startofpacket_i,
  input  logic              ast_snk_endofpacket_i,
  input  logic              ast_snk_valid_i,
  input  logic              ast_snk_channel_i,
  input  logic              ast_snk_empty_i,
  output logic              ast_snk_ready_o,
  

  // // Sending out ethernet frame
  output logic [DATA_W-1:0] ast_src_data_o,
  output logic              ast_src_startofpacket_o,
  output logic              ast_src_endofpacket_o,
  output logic              ast_src_valid_o,
  output logic              ast_src_channel_o,
  output logic              ast_src_empty_o,
  input  logic              ast_src_ready_i,

  // // Sending out MAC control register 
  output logic [7:0]        amm_address_o,
  output logic              amm_read_o,
  input  logic [31:0]       amm_readdata_i,
  input  logic              amm_waitrequest_i
  output logic              amm_write_o,
  output logic [31:0]       amm_writedata_o,



);

always_ff @( posedge clk_i )
  begin
    
  end

endmodule