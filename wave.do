onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb/width
add wave -noupdate -format Logic /tb/rst
add wave -noupdate -format Literal /tb/row
add wave -noupdate -format Literal /tb/pipe_out
add wave -noupdate -format Literal /tb/pipe_in
add wave -noupdate -format Literal /tb/pipe
add wave -noupdate -format Literal /tb/p0_wr_fifo
add wave -noupdate -format Literal /tb/p0_rd_fifo
add wave -noupdate -format Literal /tb/num
add wave -noupdate -format Literal /tb/mem
add wave -noupdate -format Literal /tb/kernel
add wave -noupdate -format Literal /tb/height
add wave -noupdate -format Logic /tb/go
add wave -noupdate -format Literal /tb/col
add wave -noupdate -format Logic /tb/clk
add wave -noupdate -format Literal /tb/cfg
add wave -noupdate -format Literal /tb/ce_count
add wave -noupdate -format Logic /tb/ce
add wave -noupdate -divider feed
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
add wave -noupdate -format Literal /tb/my_sim_feed/p0_fifo
add wave -noupdate -format Logic /tb/my_sim_feed/issue
add wave -noupdate -format Literal /tb/my_sim_feed/id
add wave -noupdate -format Logic /tb/my_sim_feed/avail
add wave -noupdate -format Logic /tb/my_sim_feed/clk
add wave -noupdate -divider Translate
add wave -noupdate -format Literal /tb/my_translate/width
add wave -noupdate -format Logic /tb/my_translate/stall
add wave -noupdate -format Literal -expand /tb/my_translate/stage_next
add wave -noupdate -format Literal -expand /tb/my_translate/stage
add wave -noupdate -format Logic /tb/my_translate/src_valid
add wave -noupdate -format Logic /tb/my_translate/rst
add wave -noupdate -format Literal /tb/my_translate/r_next
add wave -noupdate -format Literal -expand /tb/my_translate/r
add wave -noupdate -format Literal -expand /tb/my_translate/pipe_out
add wave -noupdate -format Literal /tb/my_translate/pipe_in
add wave -noupdate -format Logic /tb/my_translate/issue
add wave -noupdate -format Literal /tb/my_translate/id
add wave -noupdate -format Literal /tb/my_translate/height
add wave -noupdate -format Logic /tb/my_translate/clk
add wave -noupdate -divider line
add wave -noupdate -format Logic /tb/my_filter0_buffer/stall
add wave -noupdate -format Literal /tb/my_filter0_buffer/wren
add wave -noupdate -format Literal /tb/my_filter0_buffer/width
add wave -noupdate -format Literal /tb/my_filter0_buffer/stage_next
add wave -noupdate -format Literal /tb/my_filter0_buffer/stage
add wave -noupdate -format Logic /tb/my_filter0_buffer/src_valid
add wave -noupdate -format Logic /tb/my_filter0_buffer/rst
add wave -noupdate -format Literal /tb/my_filter0_buffer/r_r
add wave -noupdate -format Literal /tb/my_filter0_buffer/r_next
add wave -noupdate -format Literal /tb/my_filter0_buffer/r
add wave -noupdate -format Literal /tb/my_filter0_buffer/q
add wave -noupdate -format Literal /tb/my_filter0_buffer/pipe_out
add wave -noupdate -format Literal -expand /tb/my_filter0_buffer/pipe_in
add wave -noupdate -format Literal /tb/my_filter0_buffer/num_lines
add wave -noupdate -format Literal -expand /tb/my_filter0_buffer/mono_1d_out
add wave -noupdate -format Logic /tb/my_filter0_buffer/issue
add wave -noupdate -format Literal /tb/my_filter0_buffer/id
add wave -noupdate -format Literal /tb/my_filter0_buffer/height
add wave -noupdate -format Logic /tb/my_filter0_buffer/clk
add wave -noupdate -format Literal /tb/my_filter0_buffer/adr
add wave -noupdate -divider win
add wave -noupdate -format Literal /tb/my_filter0_window/width
add wave -noupdate -format Logic /tb/my_filter0_window/stall
add wave -noupdate -format Literal /tb/my_filter0_window/stage_next
add wave -noupdate -format Literal /tb/my_filter0_window/stage
add wave -noupdate -format Logic /tb/my_filter0_window/src_valid
add wave -noupdate -format Logic /tb/my_filter0_window/rst
add wave -noupdate -format Literal /tb/my_filter0_window/rin
add wave -noupdate -format Literal /tb/my_filter0_window/r
add wave -noupdate -format Literal /tb/my_filter0_window/q
add wave -noupdate -format Literal /tb/my_filter0_window/pipe_out
add wave -noupdate -format Literal /tb/my_filter0_window/pipe_in
add wave -noupdate -format Literal /tb/my_filter0_window/num_cols
add wave -noupdate -format Literal /tb/my_filter0_window/next_q
add wave -noupdate -format Literal /tb/my_filter0_window/mono_2d_out
add wave -noupdate -format Literal /tb/my_filter0_window/mono_1d_in
add wave -noupdate -format Logic /tb/my_filter0_window/issue
add wave -noupdate -format Literal /tb/my_filter0_window/id
add wave -noupdate -format Literal /tb/my_filter0_window/height
add wave -noupdate -format Logic /tb/my_filter0_window/clk
add wave -noupdate -divider test
add wave -noupdate -format Logic /tb/my_filter0_kernel/stall
add wave -noupdate -format Literal /tb/my_filter0_kernel/stage_next
add wave -noupdate -format Literal /tb/my_filter0_kernel/stage
add wave -noupdate -format Logic /tb/my_filter0_kernel/src_valid
add wave -noupdate -format Logic /tb/my_filter0_kernel/rst
add wave -noupdate -format Literal /tb/my_filter0_kernel/pipe_out
add wave -noupdate -format Literal /tb/my_filter0_kernel/pipe_in
add wave -noupdate -format Literal /tb/my_filter0_kernel/mono_2d_in
add wave -noupdate -format Literal /tb/my_filter0_kernel/kernel
add wave -noupdate -format Logic /tb/my_filter0_kernel/issue
add wave -noupdate -format Literal /tb/my_filter0_kernel/id
add wave -noupdate -format Logic /tb/my_filter0_kernel/clk
add wave -noupdate -divider sink
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
add wave -noupdate -format Logic /tb/my_sim_sink/clk
add wave -noupdate -format Logic /tb/my_sim_sink/avail
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5255000 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {5012500 ps} {10262500 ps}
bookmark add wave initial {{5012500 ps} {10262500 ps}} 12
