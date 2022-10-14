vlib work

set source_file {
  "../rtl/gen_eth_pkt.sv"
  "avalon_st_if.sv"
  "avl_st_pkg.sv"
  "gen_eth_pkt_tb.sv"
}


foreach files $source_file {
  vlog -sv $files
}

#Return the name of last file (without extension .sv)
set fbasename [file rootname [file tail [lindex $source_file end]]]

vsim $fbasename

add log -r /*
add wave -r *
view -undock wave
run -all