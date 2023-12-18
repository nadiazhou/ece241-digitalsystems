# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog part3.v

#load simulation using mux as the top level simulation module
vsim part3

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}



force {clock} 0 0ns, 1 {5ns} -r 10ns
run 50ns

force {reset} 1
run 10ns

force {reset} 0
run 10ns

force ParallelLoadn 0
run 10ns

force Data_IN 1000

run 10ns

force ParallelLoadn 1
force RotateRight 1
force ASRight 1

run 10ns

force ParallelLoadn 1
force RotateRight 1
force ASRight 0

run 10ns

force ParallelLoadn 1
force RotateRight 0
force ASRight 0

run 10ns