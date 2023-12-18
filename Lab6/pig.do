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

# first test case
#set input values using the force command, signal names need to be in {} brackets


force {Clock} 0 0ns, 1 {5ns} -r 10ns
run 20ns

force {Reset} 1
force Go 0

run 10ns

force {Reset} 0

run 30ns

force DataIn 00000010

run 20ns

force Go 1

run 20ns

force Go 0

run 20ns

force Go 1

run 20ns

force Go 0

run 20ns

force Go 1

run 20ns

force Go 0

run 20ns

force Go 1

run 20ns

force Go 0

run 200ns

force DataIn 00000011

run 20ns

force Go 1

run 20ns

force Go 0

run 20ns

force Go 1

run 20ns

force Go 0

run 20ns

force Go 1

run 20ns

force Go 0

run 20ns

force Go 1

run 20ns

force Go 0

run 200ns

force Reset 1

run 100ns








