onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/my_pipe_head/ID
add wave -noupdate /tb/my_pipe_head/clk
add wave -noupdate /tb/my_pipe_head/rst
add wave -noupdate /tb/my_pipe_head/cfg
add wave -noupdate -expand -subitemconfig {/tb/my_pipe_head/pipe_tail.stage -expand /tb/my_pipe_head/pipe_tail.ctrl -expand} /tb/my_pipe_head/pipe_tail
add wave -noupdate /tb/my_pipe_head/pipe_out
add wave -noupdate -divider FEED
add wave -noupdate /tb/my_mcb_feed/ID
add wave -noupdate -expand -subitemconfig {/tb/my_mcb_feed/pipe_in.stage -expand} /tb/my_mcb_feed/pipe_in
add wave -noupdate -expand -subitemconfig {/tb/my_mcb_feed/pipe_out.stage -expand} /tb/my_mcb_feed/pipe_out
add wave -noupdate -expand /tb/my_mcb_feed/p0_fifo
add wave -noupdate -expand /tb/my_mcb_feed/p1_fifo
add wave -noupdate /tb/my_mcb_feed/clk
add wave -noupdate /tb/my_mcb_feed/rst
add wave -noupdate -expand /tb/my_mcb_feed/stage
add wave -noupdate -expand /tb/my_mcb_feed/stage_next
add wave -noupdate /tb/my_mcb_feed/src_valid
add wave -noupdate /tb/my_mcb_feed/issue
add wave -noupdate /tb/my_mcb_feed/stall
add wave -noupdate /tb/my_mcb_feed/r
add wave -noupdate /tb/my_mcb_feed/r_next
add wave -noupdate /tb/my_mcb_feed/avail
add wave -noupdate -divider T1
add wave -noupdate /tb/my_translate/ID
add wave -noupdate /tb/my_translate/WIDTH
add wave -noupdate /tb/my_translate/HEIGHT
add wave -noupdate /tb/my_translate/CUT
add wave -noupdate /tb/my_translate/APPEND
add wave -noupdate /tb/my_translate/pipe_in
add wave -noupdate -expand -subitemconfig {/tb/my_translate/pipe_out.stage -expand} /tb/my_translate/pipe_out
add wave -noupdate /tb/my_translate/clk
add wave -noupdate /tb/my_translate/rst
add wave -noupdate /tb/my_translate/stage
add wave -noupdate /tb/my_translate/stage_next
add wave -noupdate /tb/my_translate/src_valid
add wave -noupdate /tb/my_translate/issue
add wave -noupdate /tb/my_translate/stall
add wave -noupdate /tb/my_translate/r
add wave -noupdate /tb/my_translate/r_next
add wave -noupdate -divider T2
add wave -noupdate /tb/amy_translate/ID
add wave -noupdate /tb/amy_translate/WIDTH
add wave -noupdate /tb/amy_translate/HEIGHT
add wave -noupdate /tb/amy_translate/CUT
add wave -noupdate /tb/amy_translate/APPEND
add wave -noupdate /tb/amy_translate/pipe_in
add wave -noupdate -expand -subitemconfig {/tb/amy_translate/pipe_out.stage -expand} /tb/amy_translate/pipe_out
add wave -noupdate /tb/amy_translate/clk
add wave -noupdate /tb/amy_translate/rst
add wave -noupdate /tb/amy_translate/stage
add wave -noupdate /tb/amy_translate/stage_next
add wave -noupdate /tb/amy_translate/src_valid
add wave -noupdate /tb/amy_translate/issue
add wave -noupdate /tb/amy_translate/stall
add wave -noupdate /tb/amy_translate/r
add wave -noupdate /tb/amy_translate/r_next
add wave -noupdate -divider SINK
add wave -noupdate /tb/my_mcb_sink/ID
add wave -noupdate -expand -subitemconfig {/tb/my_mcb_sink/pipe_in.stage -expand} /tb/my_mcb_sink/pipe_in
add wave -noupdate -expand -subitemconfig {/tb/my_mcb_sink/pipe_out.stage -expand} /tb/my_mcb_sink/pipe_out
add wave -noupdate -expand /tb/my_mcb_sink/p0_fifo
add wave -noupdate /tb/my_mcb_sink/p1_fifo
add wave -noupdate /tb/my_mcb_sink/clk
add wave -noupdate /tb/my_mcb_sink/rst
add wave -noupdate /tb/my_mcb_sink/issue
add wave -noupdate /tb/my_mcb_sink/stall
add wave -noupdate /tb/my_mcb_sink/stage
add wave -noupdate /tb/my_mcb_sink/stage_next
add wave -noupdate /tb/my_mcb_sink/src_valid
add wave -noupdate -expand /tb/my_mcb_sink/r
add wave -noupdate /tb/my_mcb_sink/r_next
add wave -noupdate /tb/my_mcb_sink/avail
add wave -noupdate -divider TB
add wave -noupdate /tb/KERNEL
add wave -noupdate /tb/WIDTH
add wave -noupdate /tb/HEIGHT
add wave -noupdate /tb/NUM
add wave -noupdate /tb/clk
add wave -noupdate /tb/rst
add wave -noupdate /tb/col
add wave -noupdate /tb/row
add wave -noupdate /tb/ce_count
add wave -noupdate /tb/ce
add wave -noupdate /tb/go
add wave -noupdate /tb/mem
add wave -noupdate /tb/pipe_in
add wave -noupdate /tb/pipe_out
add wave -noupdate /tb/pipe
add wave -noupdate /tb/cfg
add wave -noupdate /tb/mono_1d
add wave -noupdate /tb/mono_2d
add wave -noupdate /tb/pr_fifo
add wave -noupdate /tb/pw_fifo
add wave -noupdate /tb/auxr_fifo
add wave -noupdate /tb/auxw_fifo
add wave -noupdate /tb/pr_clk
add wave -noupdate /tb/pr_rst
add wave -noupdate -divider main
add wave -noupdate /tb/pr_wr
add wave -noupdate /tb/auxr_wr
add wave -noupdate /tb/pw_wr
add wave -noupdate /tb/auxw_wr
add wave -noupdate /tb/pr_rd
add wave -noupdate /tb/auxr_rd
add wave -noupdate /tb/pw_rd
add wave -noupdate /tb/auxw_rd
add wave -noupdate /tb/pr_full
add wave -noupdate /tb/auxr_full
add wave -noupdate /tb/pw_full
add wave -noupdate /tb/auxw_full
add wave -noupdate /tb/pr_in
add wave -noupdate /tb/auxr_in
add wave -noupdate /tb/pw_in
add wave -noupdate /tb/auxw_in
add wave -noupdate /tb/pr_empty
add wave -noupdate /tb/auxr_empty
add wave -noupdate /tb/pw_empty
add wave -noupdate /tb/auxw_empty
add wave -noupdate /tb/auxr_rst
add wave -noupdate /tb/pw_rst
add wave -noupdate /tb/auxw_rst
add wave -noupdate /tb/auxr_clk
add wave -noupdate /tb/pw_clk
add wave -noupdate /tb/auxw_clk
add wave -noupdate /tb/auxr_out
add wave -noupdate /tb/auxw_out
add wave -noupdate /tb/pr_out
add wave -noupdate /tb/pw_out
add wave -noupdate -radix hexadecimal /tb/pr_count
add wave -noupdate -radix hexadecimal /tb/pw_count
add wave -noupdate -radix hexadecimal /tb/auxr_count
add wave -noupdate -radix hexadecimal /tb/auxw_count
add wave -noupdate /tb/indata
add wave -noupdate /tb/outdata
add wave -noupdate /tb/my_pipe_head/pipe_tail.ctrl.issue
add wave -noupdate -divider Issue
add wave -noupdate /tb/my_mcb_feed/issue
add wave -noupdate /tb/my_translate/issue
add wave -noupdate /tb/amy_translate/issue
add wave -noupdate /tb/my_mcb_sink/issue
add wave -noupdate -divider STall
add wave -noupdate /tb/my_pipe_head/pipe_tail.stall
add wave -noupdate /tb/my_mcb_feed/stall
add wave -noupdate /tb/my_translate/stall
add wave -noupdate /tb/amy_translate/stall
add wave -noupdate /tb/my_mcb_sink/stall
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1278610 ps} 0} {{Cursor 2} {23136029 ps} 0} {{Cursor 3} {2922170 ps} 0} {{Cursor 4} {181604 ps} 0}
configure wave -namecolwidth 256
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {10500 ns}
bookmark add wave initial {{0 ps} {10500 ns}} 220
