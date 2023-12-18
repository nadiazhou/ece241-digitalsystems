# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog KD.v

#load simulation using mux as the top level simulation module
vsim -L altera_mf_ver KeyDecoder

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# Force initial values
force {clk} 0 0ns, 1 {5ns} -r 10ns
force {reset} 1
run 50ns

# Release reset
force {reset} 0
run 10ns

# Apply stimulus
force key_pressed 1
#force extended_code 1
run 50ns
force key_data 8'hE0
run 50ns
force key_data 8'h1C
run 50ns

run 50ns

force key_pressed 1

run 50ns
force key_data 8'h72

run 50ns
force key_data 8'h74
run 50ns
force key_pressed 0
run 50ns

# Continue with your other test scenarios

# Run for an extended period to observe the behavior
run 10000ns

# Finish simulation
quit







