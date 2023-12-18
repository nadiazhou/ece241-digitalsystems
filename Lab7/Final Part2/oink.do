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

force {iClock} 0 0ns, 1 {5ns} -r 10ns



force iResetn 0
force iPlotBox 0
force iBlack 0
force iLoadX 0
force iColour 0
force iXY_Coord 0
run 50ns

force iResetn 1
run 50ns

force iXY_Coord 100
run 50ns

force iLoadX 1
run 50ns

force iLoadX 0
run 50ns

force iXY_Coord 1
force iColour 100
run 50ns

force iPlotBox 1
run 50ns

force iPlotBox 0
run 200ns

force iBlack 0
force iColour 111
force iXY_Coord 0000000
force iLoadX 1
run 20ns

force iLoadX 0
run 10ns

force iPlotBox 1
run 20ns

force iPlotBox 0
run 300ns

force iBlack 0
force iColour 001
force iXY_Coord 0000111
force iLoadX 1
run 20ns

force iLoadX 0
run 10ns

force iPlotBox 1
run 20ns

force iPlotBox 0
run 300ns

force iBlack 1
run 20ns

force iBlack 0
run 500ns






