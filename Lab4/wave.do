# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog part2.v

#load simulation using mux as the top level simulation module
vsim part2

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {Clock} 0 0ns, 1 {5ns} -r 10ns
run 50ns

force {Reset_b} 1
run 10ns


force {Reset_b} 0
force {Function} 00
force {Data} 0011

run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets


force {Function} 10
force {Data} 0100
run 10ns


force {Function} 11
force {Data} 0100
run 10ns


force {Reset_b} 1
run 10ns

force {Reset_b} 0
run 10ns

force {Function} 00
force {Data} 1111
run 10ns

force {Function} 10
force {Data} 1111

run 20ns

