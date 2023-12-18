# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog part1.v

#load simulation using mux as the top level simulation module
vsim part1

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# first test case
#set input values using the force command, signal names need to be in {} brackets


force {Clock} 0 0ns, 1 {5ns} -r 10ns
run 50ns

force {Reset} 1

run 10ns

force {Reset} 0

run 30ns

force w 1

run 100ns

force w 0

run 10ns

force w 1


run 50ns

force Reset 1

run 100ns








