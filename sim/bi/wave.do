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
add wave -noupdate -format Literal /tb/my_sim_feed/pipe_out
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
add wave -noupdate -format Literal /tb/dut/pipe_in
add wave -noupdate -format Literal /tb/dut/pipe_out
add wave -noupdate -format Logic /tb/dut/stall_in
add wave -noupdate -format Logic /tb/dut/stall_out
add wave -noupdate -format Literal /tb/dut/stall
add wave -noupdate -divider ROM
add wave -noupdate -divider ROMDATA
add wave -noupdate -divider DUT2
add wave -noupdate -divider SINK
add wave -noupdate -format Logic /tb/my_sim_sink/stall_out
add wave -noupdate -format Logic /tb/my_sim_sink/stall_in
add wave -noupdate -format Logic /tb/my_sim_sink/stall
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
add wave -noupdate -format Literal -expand /tb/bitest/abcd
add wave -noupdate -format Logic /tb/bitest/clk
add wave -noupdate -format Literal -expand /tb/bitest/gray8_2d_in
add wave -noupdate -format Literal -radix hexadecimal -expand /tb/bitest/gray8_2d_out
add wave -noupdate -format Literal /tb/bitest/height
add wave -noupdate -format Literal /tb/bitest/id
add wave -noupdate -format Logic /tb/bitest/issue
add wave -noupdate -format Literal /tb/bitest/pipe_in
add wave -noupdate -format Literal /tb/bitest/pipe_out
add wave -noupdate -format Literal /tb/bitest/r
add wave -noupdate -format Literal /tb/bitest/r_next
add wave -noupdate -format Logic /tb/bitest/rst
add wave -noupdate -format Logic /tb/bitest/src_valid
add wave -noupdate -format Literal /tb/bitest/stage
add wave -noupdate -format Literal /tb/bitest/stage_next
add wave -noupdate -format Logic /tb/bitest/stall
add wave -noupdate -format Logic /tb/bitest/stall_in
add wave -noupdate -format Logic /tb/bitest/stall_out
add wave -noupdate -format Literal /tb/bitest/width
add wave -noupdate -format Literal /tb/bitest/x
add wave -noupdate -format Literal /tb/bitest/y
add wave -noupdate -divider STall
add wave -noupdate -format Literal /tb/bitest2/abcd
add wave -noupdate -format Logic /tb/bitest2/clk
add wave -noupdate -format Literal /tb/bitest2/ctx
add wave -noupdate -format Literal /tb/bitest2/cty
add wave -noupdate -format Literal /tb/bitest2/disx
add wave -noupdate -format Literal /tb/bitest2/disy
add wave -noupdate -format Literal /tb/bitest2/gray8_2d_in
add wave -noupdate -format Literal /tb/bitest2/gray8_2d_out
add wave -noupdate -format Literal /tb/bitest2/height
add wave -noupdate -format Literal /tb/bitest2/id
add wave -noupdate -format Logic /tb/bitest2/issue
add wave -noupdate -format Literal /tb/bitest2/off
add wave -noupdate -format Literal /tb/bitest2/off2
add wave -noupdate -format Literal /tb/bitest2/ox
add wave -noupdate -format Literal /tb/bitest2/oy
add wave -noupdate -format Literal /tb/bitest2/pipe_in
add wave -noupdate -format Literal /tb/bitest2/pipe_out
add wave -noupdate -format Literal /tb/bitest2/r
add wave -noupdate -format Literal /tb/bitest2/r_next
add wave -noupdate -format Logic /tb/bitest2/rst
add wave -noupdate -format Literal /tb/bitest2/shifted_x
add wave -noupdate -format Literal /tb/bitest2/shifted_x2
add wave -noupdate -format Literal /tb/bitest2/shifted_y
add wave -noupdate -format Literal /tb/bitest2/shifted_y2
add wave -noupdate -format Logic /tb/bitest2/src_valid
add wave -noupdate -format Literal /tb/bitest2/stage
add wave -noupdate -format Literal /tb/bitest2/stage_next
add wave -noupdate -format Logic /tb/bitest2/stall
add wave -noupdate -format Logic /tb/bitest2/stall_in
add wave -noupdate -format Logic /tb/bitest2/stall_out
add wave -noupdate -format Literal /tb/bitest2/usx
add wave -noupdate -format Literal /tb/bitest2/usy
add wave -noupdate -format Literal /tb/bitest2/ux
add wave -noupdate -format Literal /tb/bitest2/uy
add wave -noupdate -format Literal /tb/bitest2/width
add wave -noupdate -format Literal /tb/bitest2/x
add wave -noupdate -format Literal /tb/bitest2/y
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tb/bitest3/clk
add wave -noupdate -format Literal /tb/bitest3/disx
add wave -noupdate -format Literal /tb/bitest3/disy
add wave -noupdate -format Literal /tb/bitest3/gray8_2d_in
add wave -noupdate -format Literal /tb/bitest3/height
add wave -noupdate -format Literal /tb/bitest3/id
add wave -noupdate -format Logic /tb/bitest3/issue
add wave -noupdate -format Literal /tb/bitest3/pipe_in
add wave -noupdate -format Literal /tb/bitest3/pipe_out
add wave -noupdate -format Literal /tb/bitest3/r
add wave -noupdate -format Literal /tb/bitest3/r_next
add wave -noupdate -format Logic /tb/bitest3/rst
add wave -noupdate -format Logic /tb/bitest3/src_valid
add wave -noupdate -format Literal /tb/bitest3/stage
add wave -noupdate -format Literal /tb/bitest3/stage_next
add wave -noupdate -format Logic /tb/bitest3/stall
add wave -noupdate -format Logic /tb/bitest3/stall_in
add wave -noupdate -format Logic /tb/bitest3/stall_out
add wave -noupdate -format Literal /tb/bitest3/width
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0} {{Cursor 2} {0 ps} 0} {{Cursor 3} {0 ps} 0} {{Cursor 4} {428721 ps} 0}
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
WaveRestoreZoom {415913 ps} {634087 ps}
bookmark add wave initial {{0 ps} {6981536 ps}} 56
