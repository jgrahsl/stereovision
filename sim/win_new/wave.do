onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/dut/my_filter0_buffer/ID
add wave -noupdate /tb/dut/my_filter0_buffer/NUM_LINES
add wave -noupdate /tb/dut/my_filter0_buffer/WIDTH
add wave -noupdate /tb/dut/my_filter0_buffer/HEIGHT
add wave -noupdate /tb/dut/my_filter0_buffer/clk
add wave -noupdate -expand /tb/dut/my_filter0_buffer/mono_1d_out
add wave -noupdate /tb/dut/my_filter0_buffer/rst
add wave -noupdate /tb/dut/my_filter0_buffer/stage
add wave -noupdate /tb/dut/my_filter0_buffer/stage_next
add wave -noupdate /tb/dut/my_filter0_buffer/src_valid
add wave -noupdate /tb/dut/my_filter0_buffer/issue
add wave -noupdate /tb/dut/my_filter0_buffer/stall
add wave -noupdate /tb/dut/my_filter0_buffer/stalled
add wave -noupdate /tb/dut/my_filter0_buffer/r
add wave -noupdate /tb/dut/my_filter0_buffer/r_next
add wave -noupdate -expand /tb/dut/my_filter0_buffer/shiftin
add wave -noupdate -expand /tb/dut/my_filter0_buffer/shiftout
add wave -noupdate -radix hexadecimal /tb/dut/my_filter0_buffer/rams(0)/my_shiftreg/a
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {108641 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue right
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {512696 ps}
