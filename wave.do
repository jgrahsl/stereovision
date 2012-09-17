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
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /tb/my_hist_y/width
add wave -noupdate -format Logic /tb/my_hist_y/stall
add wave -noupdate -format Literal /tb/my_hist_y/stage_next
add wave -noupdate -format Literal -expand /tb/my_hist_y/stage
add wave -noupdate -format Logic /tb/my_hist_y/src_valid
add wave -noupdate -format Logic /tb/my_hist_y/rst
add wave -noupdate -format Literal /tb/my_hist_y/ram2_wen
add wave -noupdate -format Literal /tb/my_hist_y/ram2_dout
add wave -noupdate -format Literal /tb/my_hist_y/ram2_din
add wave -noupdate -format Literal /tb/my_hist_y/ram2_adr
add wave -noupdate -format Literal /tb/my_hist_y/ram1_wen
add wave -noupdate -format Literal /tb/my_hist_y/ram1_dout
add wave -noupdate -format Literal /tb/my_hist_y/ram1_din
add wave -noupdate -format Literal /tb/my_hist_y/ram1_adr
add wave -noupdate -format Literal /tb/my_hist_y/ram0_wen
add wave -noupdate -format Literal /tb/my_hist_y/ram0_dout
add wave -noupdate -format Literal /tb/my_hist_y/ram0_din
add wave -noupdate -format Literal /tb/my_hist_y/ram0_adr
add wave -noupdate -format Literal /tb/my_hist_y/r_next
add wave -noupdate -format Literal -expand /tb/my_hist_y/r
add wave -noupdate -format Literal /tb/my_hist_y/pipe_out
add wave -noupdate -format Literal -expand /tb/my_hist_y/pipe_in
add wave -noupdate -format Logic /tb/my_hist_y/issue
add wave -noupdate -format Literal /tb/my_hist_y/id
add wave -noupdate -format Literal /tb/my_hist_y/height
add wave -noupdate -format Logic /tb/my_hist_y/clk
add wave -noupdate -format Literal /tb/my_hist_y/ram0_ram/ram
add wave -noupdate -format Logic /tb/my_hist_y/ram1_ram/clka
add wave -noupdate -format Literal /tb/my_hist_y/ram1_ram/wea
add wave -noupdate -format Literal /tb/my_hist_y/ram1_ram/addra
add wave -noupdate -format Literal /tb/my_hist_y/ram1_ram/dina
add wave -noupdate -format Literal /tb/my_hist_y/ram1_ram/douta
add wave -noupdate -format Literal -radix decimal -expand /tb/my_hist_y/ram0_ram/ram
add wave -noupdate -format Literal -radix decimal -expand /tb/my_hist_y/ram1_ram/ram
add wave -noupdate -format Literal -radix decimal -expand /tb/my_hist_y/swap_ram/ram
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {741299 ps} 0}
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
WaveRestoreZoom {584577 ps} {912703 ps}
bookmark add wave initial {{584577 ps} {912703 ps}} 35
