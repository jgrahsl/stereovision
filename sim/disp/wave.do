onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TB
add wave -noupdate -format Logic /tb/clk
add wave -noupdate -format Logic /tb/rst
add wave -noupdate -format Literal /tb/pipe_in
add wave -noupdate -format Literal /tb/pipe_out
add wave -noupdate -format Literal /tb/pipe
add wave -noupdate -format Literal /tb/cfg
add wave -noupdate -format Logic /tb/finish
add wave -noupdate -divider HEAD
add wave -noupdate -format Literal /tb/my_pipe_head/id
add wave -noupdate -format Logic /tb/my_pipe_head/clk
add wave -noupdate -format Logic /tb/my_pipe_head/rst
add wave -noupdate -format Literal /tb/my_pipe_head/cfg
add wave -noupdate -format Literal /tb/my_pipe_head/pipe_out
add wave -noupdate -divider FEED
add wave -noupdate -format Literal /tb/my_sim_feed/id
add wave -noupdate -format Literal /tb/my_sim_feed/pipe_in
add wave -noupdate -format Literal -expand /tb/my_sim_feed/pipe_out
add wave -noupdate -format Logic /tb/my_sim_feed/stall_in
add wave -noupdate -format Logic /tb/my_sim_feed/stall_out
add wave -noupdate -format Literal /tb/my_sim_feed/p0_fifo
add wave -noupdate -format Logic /tb/my_sim_feed/clk
add wave -noupdate -format Logic /tb/my_sim_feed/rst
add wave -noupdate -format Literal /tb/my_sim_feed/stage
add wave -noupdate -format Literal /tb/my_sim_feed/stage_next
add wave -noupdate -format Logic /tb/my_sim_feed/src_valid
add wave -noupdate -format Logic /tb/my_sim_feed/issue
add wave -noupdate -format Logic /tb/my_sim_feed/stall
add wave -noupdate -format Literal /tb/my_sim_feed/r
add wave -noupdate -format Literal /tb/my_sim_feed/r_next
add wave -noupdate -format Logic /tb/my_sim_feed/avail
add wave -noupdate -format Literal /tb/my_sim_feed/p
add wave -noupdate -divider DUT
add wave -noupdate -divider ROM
add wave -noupdate -divider ROMDATA
add wave -noupdate -divider DUT2
add wave -noupdate -format Literal /tb/dut2/pipe_in
add wave -noupdate -format Literal /tb/dut2/pipe_out
add wave -noupdate -format Logic /tb/dut2/stall_in
add wave -noupdate -format Logic /tb/dut2/stall_out
add wave -noupdate -format Literal /tb/dut2/rgb565_2d_in
add wave -noupdate -format Literal /tb/dut2/mono_2d_l
add wave -noupdate -format Literal /tb/dut2/mono_2d_r
add wave -noupdate -format Logic /tb/dut2/clk
add wave -noupdate -format Logic /tb/dut2/rst
add wave -noupdate -format Literal /tb/dut2/stage
add wave -noupdate -format Literal /tb/dut2/stage_next
add wave -noupdate -format Logic /tb/dut2/src_valid
add wave -noupdate -format Logic /tb/dut2/issue
add wave -noupdate -format Logic /tb/dut2/stall
add wave -noupdate -format Literal /tb/dut2/mono_2d_l_next
add wave -noupdate -format Literal /tb/dut2/mono_2d_r_next
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tb/dut3/clk
add wave -noupdate -format Literal /tb/dut3/id
add wave -noupdate -format Logic /tb/dut3/issue
add wave -noupdate -format Literal /tb/dut3/kernel
add wave -noupdate -format Literal /tb/dut3/mono_2d_l
add wave -noupdate -format Literal /tb/dut3/mono_2d_r
add wave -noupdate -format Literal /tb/dut3/pipe_in
add wave -noupdate -format Literal /tb/dut3/pipe_out
add wave -noupdate -format Literal -expand /tb/dut3/r
add wave -noupdate -format Literal /tb/dut3/r_next
add wave -noupdate -format Logic /tb/dut3/rst
add wave -noupdate -format Logic /tb/dut3/src_valid
add wave -noupdate -format Literal /tb/dut3/stage
add wave -noupdate -format Literal /tb/dut3/stage_next
add wave -noupdate -format Logic /tb/dut3/stall
add wave -noupdate -format Logic /tb/dut3/stall_in
add wave -noupdate -format Logic /tb/dut3/stall_out
add wave -noupdate -format Logic /tb/my_sim_sink/stall_out
add wave -noupdate -format Logic /tb/my_sim_sink/stall_in
add wave -noupdate -format Logic /tb/my_sim_sink/stall
add wave -noupdate -divider SINK
add wave -noupdate -format Literal /tb/my_sim_sink/stage_next
add wave -noupdate -format Literal /tb/my_sim_sink/stage
add wave -noupdate -format Logic /tb/my_sim_sink/src_valid
add wave -noupdate -format Logic /tb/my_sim_sink/rst
add wave -noupdate -format Literal /tb/my_sim_sink/r_next
add wave -noupdate -format Literal /tb/my_sim_sink/r
add wave -noupdate -format Literal /tb/my_sim_sink/pipe_out
add wave -noupdate -format Literal /tb/my_sim_sink/pipe_in
add wave -noupdate -format Literal /tb/my_sim_sink/p0_fifo
add wave -noupdate -format Logic /tb/my_sim_sink/issue
add wave -noupdate -format Literal /tb/my_sim_sink/id
add wave -noupdate -format Literal /tb/my_sim_sink/cnt
add wave -noupdate -format Logic /tb/my_sim_sink/clk
add wave -noupdate -divider main
add wave -noupdate -divider Issue
add wave -noupdate -divider STall
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {22145000 ps} 0} {{Cursor 2} {57611805 ps} 0} {{Cursor 3} {0 ps} 0} {{Cursor 4} {0 ps} 0}
configure wave -namecolwidth 171
configure wave -valuecolwidth 721
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
WaveRestoreZoom {57004687 ps} {58065250 ps}
bookmark add wave initial {{0 ps} {6981536 ps}} 56
