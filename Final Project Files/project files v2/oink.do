# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog part1.v

#load simulation using mux as the top level simulation module
vsim -L altera_mf_ver part1

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {clock} 0 0ns, 1 {5ns} -r 10ns

run 50ns

force {wren} 1

force address 00000

run 50ns

force data 0000

run 50ns

force {wren} 1

run 50ns

force address 00001

force data 1111

run 50ns

force address 00010

run 50ns

force {wren} 0

force address 00011

run 50ns

force {wren} 1  

force data 1111

run 50ns

force address 100111

run 50ns

force {Reset} 0

run 10000ns



