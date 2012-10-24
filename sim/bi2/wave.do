onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TB
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /tb/my_filter0_window/pipe_in
add wave -noupdate -format Literal /tb/my_filter0_window/pipe_out_1
add wave -noupdate -format Literal /tb/my_filter0_window/pipe_out_2
add wave -noupdate -format Literal /tb/my_filter0_window/q
add wave -noupdate -format Logic /tb/my_filter0_window/stall_in_2
add wave -noupdate -format Logic /tb/my_filter0_window/stall_in_1
add wave -noupdate -format Logic /tb/my_filter0_window/stall_out
add wave -noupdate -format Logic /tb/my_filter0_window/src_valid
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /tb/my_translatea/pipe_in
add wave -noupdate -format Literal /tb/my_translatea/pipe_out
add wave -noupdate -format Logic /tb/my_translatea/src_valid
add wave -noupdate -format Literal /tb/my_translatea/gray8_2d_in
add wave -noupdate -format Literal /tb/my_translatea/gray8_2d_out
add wave -noupdate -format Literal /tb/my_translatea/r
add wave -noupdate -format Literal /tb/my_translatea/r_next
add wave -noupdate -format Logic /tb/my_translatea/stall_in
add wave -noupdate -format Literal /tb/my_translatea/stage
add wave -noupdate -format Literal /tb/my_translatea/stage_next
add wave -noupdate -format Logic /tb/my_translatea/stall_out
add wave -noupdate -format Logic /tb/my_translatea/stall
add wave -noupdate -format Logic /tb/my_translatea/issue
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /tb/bitest/pipe_in
add wave -noupdate -format Literal /tb/bitest/pipe_out
add wave -noupdate -format Logic /tb/bitest/src_valid
add wave -noupdate -format Literal /tb/bitest/r
add wave -noupdate -format Literal /tb/bitest/r_next
add wave -noupdate -format Literal /tb/bitest/stage
add wave -noupdate -format Literal /tb/bitest/stage_next
add wave -noupdate -format Logic /tb/bitest/stall_in
add wave -noupdate -format Logic /tb/bitest/stall_out
add wave -noupdate -format Literal /tb/bitest/x
add wave -noupdate -format Logic /tb/bitest/issue
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /tb/dut2/gray8_2d_in
add wave -noupdate -format Literal /tb/dut2/pipe_in_1
add wave -noupdate -format Literal /tb/dut2/pipe_in_2
add wave -noupdate -format Literal /tb/dut2/pipe_out
add wave -noupdate -format Literal /tb/dut2/stage
add wave -noupdate -format Literal /tb/dut2/stage_next
add wave -noupdate -format Logic /tb/dut2/stall_in
add wave -noupdate -format Logic /tb/dut2/stall_out_1
add wave -noupdate -format Logic /tb/dut2/stall_out_2
add wave -noupdate -format Logic /tb/dut2/stall
add wave -noupdate -format Literal /tb/dut2/id
add wave -noupdate -format Literal /tb/dut2/offset
add wave -noupdate -format Literal /tb/dut2/kernel
add wave -noupdate -format Logic /tb/dut2/clk
add wave -noupdate -format Logic /tb/dut2/rst
add wave -noupdate -format Logic /tb/dut2/src_valid
add wave -noupdate -format Logic /tb/dut2/issue
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
WaveRestoreZoom {99792735 ps} {100010909 ps}
bookmark add wave initial {{0 ps} {6981536 ps}} 56
