# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules to working dir
vlog part2.v

# load simulation using the top level simulation module
vsim part2

# log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#run the clock
force {iClock} 0 0ns, 1 {5ns} -r 10ns

force iResetn 0
force iPlotBox 0
force iBlack 0
force iLoadX 0
force iXY_Coord 7'b0


run 20ns

force iResetn 1
force iXY_Coord 7'd3
force iLoadX 1

run 100ns

force iLoadX 0

run 100ns

force iXY_Coord 7'd7
force iColour 3'b101
force iPlotBox 1

run 100ns

force iPlotBox 0
run 100ns

force iLoadX 0

run 100ns

force iXY_Coord 7'd6
force iColour 3'b111
force iPlotBox 1

force iPlotBox 0
run 100ns


#run simulation for a few ns
run 1000ns