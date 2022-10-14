package avl_st_pkg;

typedef logic [7:0] pkt_t [$];

class ast_control #(
  parameter DATA_W    = 32,
  parameter CHANNEL_W = 10,
  parameter EMPTY_W   = $clog2(DATA_W/8) ?  $clog2(DATA_W/8) : 1
);

localparam BYTE_WORD = DATA_W/8;

virtual avalon_st_if #(
  .DATA_W    ( DATA_W    ),
  .CHANNEL_W ( CHANNEL_W ),
  .EMPTY_W   ( EMPTY_W   )
) ast_if;


mailbox #( pkt_t ) tx_fifo;
mailbox #( pkt_t ) rx_fifo;
mailbox #( logic [CHANNEL_W-1:0] ) tx_fifo_channel;
mailbox #( logic [CHANNEL_W-1:0] ) rx_fifo_channel;


function new ( virtual avalon_st_if #( .DATA_W    ( DATA_W    ),
                                    .CHANNEL_W ( CHANNEL_W ),
                                    .EMPTY_W   ( EMPTY_W   )
                                  ) _ast_if       
             );
this.ast_if          = _ast_if;
this.tx_fifo         = new(); 
this.rx_fifo         = new();
this.tx_fifo_channel = new();
this.rx_fifo_channel = new();
endfunction

`define cb @( posedge ast_if.clk );

task send_pkt( input pkt_t                 _rx_pkt,
                     logic [CHANNEL_W-1:0] _channel_rx,
                     int                   _delay_between_pkt,
                     bit                   _always_valid
              );

logic [DATA_W-1:0] pkt_data;

int pkt_size;
int i, k;

int byte_last_word;
int number_of_word;
int int_part, mod_part;

int cnt_word;

logic deassert_valid;

logic assert_valid;
int new_channel;
logic packing_byte;

logic valid_first_word;
logic valid_middle_word;
logic valid_last_word;

logic first_word_not_ready;
logic other_word_not_ready;

this.rx_fifo.put( _rx_pkt );
this.rx_fifo_channel.put( _channel_rx );

while( ast_if.ready != 1'b1 )
  `cb;  

pkt_size = _rx_pkt.size();

int_part = pkt_size / BYTE_WORD;

mod_part = pkt_size % BYTE_WORD;
i = 0;
if( mod_part == 0 )
  number_of_word = int_part;
else
  number_of_word = int_part + 1;


if( number_of_word == 1 )
  begin
    assert_valid    = 1'b1;
    pkt_data       = (DATA_W)'(0);
    ast_if.valid   <= 1'b1;
    ast_if.sop     <= 1'b1;
    ast_if.eop     <= 1'b1;
    ast_if.empty   <= BYTE_WORD-pkt_size;
    ast_if.channel <= _channel_rx;
    for( int j = pkt_size-1; j >= 0; j-- )
      begin
        pkt_data[7:0] = _rx_pkt[j];
        if( j != 0 )
          pkt_data = pkt_data << 8;
      end
    ast_if.data <= pkt_data;
    `cb;
    if( ast_if.eop == 1'b1 )
      begin
        ast_if.valid <= 1'b0;
        ast_if.sop   <= 1'b0;
        ast_if.eop   <= 1'b0;
      end
  end 
else
  begin
        while( cnt_word < number_of_word )
          begin
            valid_first_word  = ( cnt_word == 0 );
            valid_middle_word = ( ( cnt_word != 0 ) &&  ( cnt_word != number_of_word-1 ) &&  ( ast_if.ready == 1'b1 ) );
            valid_last_word   = ( ( cnt_word == number_of_word-1 ) &&  ( ast_if.ready == 1'b1 ) );

            if( valid_first_word )
              begin
                pkt_data        = (DATA_W)'(0);
                assert_valid    = 1'b1;
                ast_if.sop     <= 1'b1;
                ast_if.eop     <= 1'b0;
                ast_if.empty   <= 0;
                ast_if.valid   <= 1'b1;
                ast_if.channel <= _channel_rx;
              end
            else if( valid_middle_word )
              begin
                pkt_data      = (DATA_W)'(0);
                assert_valid  = ( _always_valid ) ? 1 : $urandom_range(1,0);
                ast_if.sop   <= 1'b0;
                ast_if.eop   <= 1'b0;
                ast_if.valid <= assert_valid;
              end
            else if( valid_last_word )
              begin
                byte_last_word = ( mod_part != 0 ) ? mod_part : BYTE_WORD;
                pkt_data       = (DATA_W)'(0);
                assert_valid   = 1'b1;
                ast_if.eop    <= 1'b1;
                ast_if.sop    <= 1'b0;
                ast_if.valid  <= 1'b1;
                ast_if.empty  <= BYTE_WORD - byte_last_word;
              end

          packing_byte = valid_first_word || valid_middle_word || valid_last_word;
          
          if( packing_byte && assert_valid == 1'b1 )
            begin
              for( int j = (BYTE_WORD*cnt_word + BYTE_WORD) -1; j >= BYTE_WORD*cnt_word; j-- )
                begin
                  pkt_data[7:0] = _rx_pkt[j];
                  if( j != BYTE_WORD*cnt_word )
                    pkt_data = pkt_data << 8;
                end
            if( cnt_word == number_of_word-1 )
              begin
                for( int k = DATA_W-1; k >= byte_last_word*8; k--)
                  pkt_data[k] = 1'b0;
              end
              cnt_word++;
            end

          other_word_not_ready = ( ast_if.ready != 1'b1 && ( cnt_word != 1 ) );
          first_word_not_ready = ( ast_if.ready != 1'b1 && ( cnt_word == 1 ) && ( ast_if.valid == 1'b1 ) );
          
          deassert_valid = first_word_not_ready || other_word_not_ready;

          if( deassert_valid )
            ast_if.valid <= 1'b0;

          ast_if.data <= pkt_data;
          `cb;

          end
    if( ast_if.eop == 1'b1 )
      begin
        ast_if.eop   <= 1'b0;
        ast_if.valid <= 1'b0;
        cnt_word     = 0;
      end
  end

repeat( _delay_between_pkt )
  `cb;

endtask

task receive_pkt();

logic [DATA_W-1:0] data_out;
pkt_t              tx_pkt;

bit                flag_sop;

forever
  begin
    `cb;
    data_out = ast_if.data;
    if( ast_if.valid == 1'b1 )
      begin
        if( ast_if.sop == 1'b1 )
          begin
            tx_pkt  = {};
            this.tx_fifo_channel.put( ast_if.channel );
            flag_sop = 1'b1;
          end

        for( int i = 0; i < BYTE_WORD - ast_if.empty; i++ )
          begin
            tx_pkt.push_back(data_out[7:0]);
            data_out     = data_out >> 8;
          end

        if( ast_if.eop == 1'b1 )
          begin
            if( flag_sop == 1'b1 )
              this.tx_fifo.put( tx_pkt );
            tx_pkt   = {};
            flag_sop = 1'b0;
          end
      end
  end

endtask

endclass

endpackage