# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules to working dir
vlog part2.v

# load simulation using the top level simulation module
vsim -L altera_mf_ver project

# log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#run the clock
force {iClock} 1 0ps, 0 {5ps} -r 10ps



run 10ps

force iReset 1;
force iADirection 00;
force iBDirection 00;

run 10ps

force iReset 0;

run 1000000ps
