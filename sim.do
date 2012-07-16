transcript off
transcript file ""
quit -sim
vsim -novopt -t ps tb

#add wave -noupdate -divider Testbench
#delete wave *
#add wave -noupdate -divider Testbench
#add wave -noupdate -radix hex /tb/*
#add wave -noupdate -divider DUT
#add wave -noupdate -radix hex /tb/dut/*
#add wave -noupdate -divider User

do wave.do
run 10 ns
transcript file "transcript"
transcript file ""
view wave
run 100 us
wave zoomrange 500ns 2000ns
