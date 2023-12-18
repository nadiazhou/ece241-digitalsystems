# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules to working dir
vlog part2.v

# load simulation using the top level simulation module
vsim -L altera_mf_ver hexlength

# log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#run the clock


force lengthA 00010000
force lengthB 00001000

run 100ns


force lengthA 00011100
force lengthB 00001111

run 100ns