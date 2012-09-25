onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb/my_pipe_head/id
add wave -noupdate -format Logic /tb/my_pipe_head/clk
add wave -noupdate -format Logic /tb/my_pipe_head/rst
add wave -noupdate -format Literal /tb/my_pipe_head/cfg
add wave -noupdate -format Literal /tb/my_pipe_head/pipe_out
add wave -noupdate -divider FEED
add wave -noupdate -format Logic /tb/my_sim_feed/stall_out
add wave -noupdate -format Logic /tb/my_sim_feed/stall_in
add wave -noupdate -format Logic /tb/my_sim_feed/stall
add wave -noupdate -format Literal /tb/my_sim_feed/stage_next
add wave -noupdate -format Literal /tb/my_sim_feed/stage
add wave -noupdate -format Logic /tb/my_sim_feed/src_valid
add wave -noupdate -format Literal /tb/my_sim_feed/selected_word
add wave -noupdate -format Logic /tb/my_sim_feed/rst
add wave -noupdate -format Literal /tb/my_sim_feed/r_next
add wave -noupdate -format Literal /tb/my_sim_feed/r
add wave -noupdate -format Literal -expand /tb/my_sim_feed/pipe_out
add wave -noupdate -format Literal /tb/my_sim_feed/pipe_in
add wave -noupdate -format Literal -expand /tb/my_sim_feed/p0_fifo
add wave -noupdate -format Logic /tb/my_sim_feed/issue
add wave -noupdate -format Literal /tb/my_sim_feed/id
add wave -noupdate -format Logic /tb/my_sim_feed/clk
add wave -noupdate -format Logic /tb/my_sim_feed/avail
add wave -noupdate -divider T1
add wave -noupdate -divider T2
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /tb/my_morph/pipe
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
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
add wave -noupdate -format Logic /tb/my_sim_sink/avail
add wave -noupdate -divider TB
add wave -noupdate -format Literal /tb/kernel
add wave -noupdate -format Literal /tb/width
add wave -noupdate -format Literal /tb/height
add wave -noupdate -format Literal /tb/num
add wave -noupdate -format Logic /tb/clk
add wave -noupdate -format Logic /tb/rst
add wave -noupdate -format Literal /tb/col
add wave -noupdate -format Literal /tb/row
add wave -noupdate -format Literal /tb/ce_count
add wave -noupdate -format Logic /tb/ce
add wave -noupdate -format Logic /tb/go
add wave -noupdate -format Literal /tb/mem
add wave -noupdate -format Literal /tb/pipe_in
add wave -noupdate -format Literal /tb/pipe_out
add wave -noupdate -format Literal /tb/pipe
add wave -noupdate -format Literal /tb/cfg
add wave -noupdate -format Literal /tb/mono_1d
add wave -noupdate -format Literal /tb/mono_2d
add wave -noupdate -divider main
add wave -noupdate -divider Issue
add wave -noupdate -divider STall
add wave -noupdate -format Literal /tb/width
add wave -noupdate -format Literal /tb/stall
add wave -noupdate -format Logic /tb/rst
add wave -noupdate -format Literal /tb/row
add wave -noupdate -format Literal /tb/pipe_out
add wave -noupdate -format Literal /tb/pipe_in
add wave -noupdate -format Literal /tb/pipe
add wave -noupdate -format Literal /tb/p0_wr_fifo
add wave -noupdate -format Literal /tb/p0_rd_fifo
add wave -noupdate -format Literal /tb/num
add wave -noupdate -format Literal /tb/mono_2d
add wave -noupdate -format Literal /tb/mono_1d
add wave -noupdate -format Literal /tb/mem
add wave -noupdate -format Literal /tb/kernel
add wave -noupdate -format Literal /tb/height
add wave -noupdate -format Logic /tb/go
add wave -noupdate -format Literal /tb/col
add wave -noupdate -format Logic /tb/clk
add wave -noupdate -format Literal /tb/cfg
add wave -noupdate -format Literal /tb/ce_count
add wave -noupdate -format Logic /tb/ce
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tb/my_morph/my_morph_1/my_translate/src_valid
add wave -noupdate -format Literal -expand /tb/my_morph/my_morph_1/my_translate/pipe_in
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tb/my_morph/my_morph_2/my_translate/src_valid
add wave -noupdate -format Literal -expand /tb/my_morph/my_morph_2/my_translate/pipe_in
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tb/my_morph/my_morph_3/my_translate/src_valid
add wave -noupdate -format Literal /tb/my_morph/my_morph_3/my_translate/pipe_in
add wave -noupdate -format Logic /tb/my_sim_sink/src_valid
add wave -noupdate -format Literal /tb/my_sim_sink/pipe_in
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tb/my_sim_sink/src_valid
add wave -noupdate -format Literal /tb/my_sim_sink/pipe_in
add wave -noupdate -format Logic /tb/my_morph/my_morph_1/my_translate/stall
add wave -noupdate -format Logic /tb/my_morph/my_morph_1/my_filter0_buffer/stall
add wave -noupdate -format Logic /tb/my_morph/my_morph_1/my_filter0_window/stall
add wave -noupdate -format Logic /tb/my_morph/my_morph_1/my_translatea/stall
add wave -noupdate -format Logic /tb/my_morph/my_morph_1/my_filter0_kernel/stall
add wave -noupdate -format Logic /tb/my_morph/my_morph_2/my_translate/stall
add wave -noupdate -format Logic /tb/my_morph/my_morph_2/my_filter0_buffer/stall
add wave -noupdate -format Logic /tb/my_morph/my_morph_2/my_filter0_window/stall
add wave -noupdate -format Logic /tb/my_morph/my_morph_2/my_translatea/stall
add wave -noupdate -format Logic /tb/my_morph/my_morph_2/my_filter0_kernel/stall
add wave -noupdate -format Logic /tb/my_morph/my_morph_3/my_translate/stall
add wave -noupdate -format Logic /tb/my_morph/my_morph_3/my_filter0_buffer/stall
add wave -noupdate -format Logic /tb/my_morph/my_morph_3/my_filter0_window/stall
add wave -noupdate -format Logic /tb/my_morph/my_morph_3/my_translatea/stall
add wave -noupdate -divider LineBuffer1
add wave -noupdate -format Logic /tb/my_morph/my_morph_3/my_filter0_kernel/stall
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/wren
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/width
add wave -noupdate -format Logic /tb/my_morph/my_morph_1/my_filter0_buffer/stalled
add wave -noupdate -format Logic /tb/my_morph/my_morph_1/my_filter0_buffer/stall_out
add wave -noupdate -format Logic /tb/my_morph/my_morph_1/my_filter0_buffer/stall_in
add wave -noupdate -format Logic /tb/my_morph/my_morph_1/my_filter0_buffer/stall
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/stage_next
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/stage
add wave -noupdate -format Logic /tb/my_morph/my_morph_1/my_filter0_buffer/src_valid
add wave -noupdate -format Logic /tb/my_morph/my_morph_1/my_filter0_buffer/rst
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/r_r
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/r_next
add wave -noupdate -format Literal -expand /tb/my_morph/my_morph_1/my_filter0_buffer/r
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/qi
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/qd
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/q
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/pipe_out
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/pipe_in
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/num_lines
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/mono_1d_out
add wave -noupdate -format Logic /tb/my_morph/my_morph_1/my_filter0_buffer/issue
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/id
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/height
add wave -noupdate -format Logic /tb/my_morph/my_morph_1/my_filter0_buffer/clk
add wave -noupdate -format Literal /tb/my_morph/my_morph_1/my_filter0_buffer/adr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14705000 ps} 0} {{Cursor 2} {23136029 ps} 0} {{Cursor 3} {18304562 ps} 0} {{Cursor 4} {125000 ps} 0}
configure wave -namecolwidth 478
configure wave -valuecolwidth 185
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {22202250 ps}
bookmark add wave initial {{0 ps} {22202250 ps}} 127
