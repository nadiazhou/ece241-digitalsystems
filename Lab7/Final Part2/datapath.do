# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog part2.v

#load simulation using mux as the top level simulation module
vsim dataPath

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {clk} 0 0ns, 1 {5ns} -r 10ns

run 50ns

force reset 0
run 20ns

force reset 1
run 20ns

force color 111
force coord 0000000
force incx 00000000
force incy 0000000

force ld_x 1
run 20ns

force ld_x 0
run 20ns

force ld_y 1
run 20ns

force ld_y 0
run 20ns

force incx 00000011
force incy 0000011
force start_plot 1

run 100ns







