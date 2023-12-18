# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules to working dir
vlog part1.v

# load simulation using the top level simulation module
vsim -L altera_mf_ver part1

# log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#run the clock
force {clock} 1 0ps, 0 {5ps} -r 10ps

force {address[0]} 0;
force {address[1]} 0;
force {address[2]} 0;
force {address[3]} 0;
force {address[4]} 0;
force {data[0]} 1;
force {data[1]} 1;
force {data[2]} 1;
force {data[3]} 1;
force {wren} 0;
#run simulation for a few ns
run 5ps

#set input values using the force command, signal names need to be in {} brackets
force {address[0]} 1;
force {address[1]} 0;
force {address[2]} 1;
force {address[3]} 0;
force {address[4]} 1;
force {data[0]} 1;
force {data[1]} 0;
force {data[2]} 0;
force {data[3]} 1;
force {wren} 1;
#run simulation for a few ns
run 10ps

#hold data 
force {address[0]} 1;
force {address[1]} 0;
force {address[2]} 1;
force {address[3]} 0;
force {address[4]} 1;
force {data[0]} 1;
force {data[1]} 0;
force {data[2]} 0;
force {data[3]} 1;
force {wren} 0;
#run simulation for a few ns
run 10ps

#check if data writes if we hold
force {address[0]} 1;
force {address[1]} 1;
force {address[2]} 1;
force {address[3]} 1;
force {address[4]} 1;
force {data[0]} 1;
force {data[1]} 1;
force {data[2]} 0;
force {data[3]} 1;
force {wren} 0;
#run simulation for a few ns
run 10ps

#hold data
force {address[0]} 1;
force {address[1]} 1;
force {address[2]} 1;
force {address[3]} 1;
force {address[4]} 1;
force {data[0]} 1;
force {data[1]} 1;
force {data[2]} 0;
force {data[3]} 1;
force {wren} 0;
#run simulation for a few ns
run 10ps




#read from first write
force {address[0]} 1;
force {address[1]} 0;
force {address[2]} 1;
force {address[3]} 0;
force {address[4]} 1;
force {wren} 0;
#run simulation for a few ns
run 20ps