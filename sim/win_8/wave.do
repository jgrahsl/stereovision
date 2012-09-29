onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TB
add wave -noupdate /tb/clk
add wave -noupdate /tb/rst
add wave -noupdate /tb/pipe_in
add wave -noupdate /tb/pipe_out
add wave -noupdate /tb/pipe
add wave -noupdate /tb/cfg
add wave -noupdate /tb/finish
add wave -noupdate -divider HEAD
add wave -noupdate /tb/my_pipe_head/ID
add wave -noupdate /tb/my_pipe_head/clk
add wave -noupdate /tb/my_pipe_head/rst
add wave -noupdate /tb/my_pipe_head/cfg
add wave -noupdate /tb/my_pipe_head/pipe_out
add wave -noupdate -divider FEED
add wave -noupdate /tb/my_sim_feed/ID
add wave -noupdate /tb/my_sim_feed/pipe_in
add wave -noupdate /tb/my_sim_feed/pipe_out
add wave -noupdate /tb/my_sim_feed/stall_in
add wave -noupdate /tb/my_sim_feed/stall_out
add wave -noupdate /tb/my_sim_feed/p0_fifo
add wave -noupdate /tb/my_sim_feed/clk
add wave -noupdate /tb/my_sim_feed/rst
add wave -noupdate /tb/my_sim_feed/stage
add wave -noupdate /tb/my_sim_feed/stage_next
add wave -noupdate /tb/my_sim_feed/src_valid
add wave -noupdate /tb/my_sim_feed/issue
add wave -noupdate /tb/my_sim_feed/stall
add wave -noupdate /tb/my_sim_feed/r
add wave -noupdate /tb/my_sim_feed/r_next
add wave -noupdate /tb/my_sim_feed/avail
add wave -noupdate /tb/my_sim_feed/p
add wave -noupdate -divider DUT
add wave -noupdate /tb/dut/pipe_in
add wave -noupdate /tb/dut/pipe_out
add wave -noupdate /tb/dut/stall_in
add wave -noupdate /tb/dut/stall_out
add wave -noupdate -expand /tb/dut/abcd
add wave -noupdate /tb/dut/clk
add wave -noupdate /tb/dut/rst
add wave -noupdate /tb/dut/stage
add wave -noupdate /tb/dut/stage_next
add wave -noupdate /tb/dut/src_valid
add wave -noupdate /tb/dut/issue
add wave -noupdate /tb/dut/stall
add wave -noupdate /tb/dut/r
add wave -noupdate /tb/dut/r_next
add wave -noupdate /tb/dut/x
add wave -noupdate /tb/dut/y
add wave -noupdate -divider ROM
add wave -noupdate /tb/dut/my_rom/GRIDX_BITS
add wave -noupdate /tb/dut/my_rom/GRIDY_BITS
add wave -noupdate /tb/dut/my_rom/clk
add wave -noupdate /tb/dut/my_rom/x
add wave -noupdate /tb/dut/my_rom/y
add wave -noupdate /tb/dut/my_rom/abcd
add wave -noupdate /tb/dut/my_rom/q
add wave -noupdate /tb/dut/my_rom/a
add wave -noupdate -divider ROMDATA
add wave -noupdate /tb/dut/my_rom/GRIDX_BITS
add wave -noupdate /tb/dut/my_rom/GRIDY_BITS
add wave -noupdate /tb/dut/my_rom/clk
add wave -noupdate /tb/dut/my_rom/x
add wave -noupdate /tb/dut/my_rom/y
add wave -noupdate /tb/dut/my_rom/abcd
add wave -noupdate /tb/dut/my_rom/q
add wave -noupdate /tb/dut/my_rom/a
add wave -noupdate -divider DUT2
add wave -noupdate /tb/dut2/*
add wave -noupdate -divider SINK
add wave -noupdate /tb/my_sim_sink/stall_out
add wave -noupdate /tb/my_sim_sink/stall_in
add wave -noupdate /tb/my_sim_sink/stall
add wave -noupdate /tb/my_sim_sink/stage_next
add wave -noupdate /tb/my_sim_sink/stage
add wave -noupdate /tb/my_sim_sink/src_valid
add wave -noupdate /tb/my_sim_sink/rst
add wave -noupdate /tb/my_sim_sink/r_next
add wave -noupdate /tb/my_sim_sink/r
add wave -noupdate /tb/my_sim_sink/pipe_out
add wave -noupdate /tb/my_sim_sink/pipe_in
add wave -noupdate /tb/my_sim_sink/p0_fifo
add wave -noupdate /tb/my_sim_sink/issue
add wave -noupdate /tb/my_sim_sink/ID
add wave -noupdate /tb/my_sim_sink/cnt
add wave -noupdate /tb/my_sim_sink/clk
add wave -noupdate -divider main
add wave -noupdate -divider Issue
add wave -noupdate -divider STall
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {22145000 ps} 0} {{Cursor 2} {5093448 ps} 0} {{Cursor 3} {0 ps} 0} {{Cursor 4} {0 ps} 0}
configure wave -namecolwidth 171
configure wave -valuecolwidth 185
configure wave -justifyvalue left
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
WaveRestoreZoom {0 ps} {6981536 ps}
bookmark add wave initial {{0 ps} {6981536 ps}} 56
