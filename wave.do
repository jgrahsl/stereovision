onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb/kernel
add wave -noupdate -format Literal /tb/height
add wave -noupdate -format Literal /tb/width
add wave -noupdate -format Logic /tb/clk
add wave -noupdate -format Logic /tb/rst
add wave -noupdate -format Literal /tb/vin
add wave -noupdate -format Literal /tb/vout
add wave -noupdate -format Literal /tb/vin_data
add wave -noupdate -format Literal /tb/vout_data
add wave -noupdate -format Literal /tb/col
add wave -noupdate -format Literal /tb/row
add wave -noupdate -format Literal /tb/ce_count
add wave -noupdate -format Logic /tb/ce
add wave -noupdate -format Logic /tb/go
add wave -noupdate -format Literal /tb/dut/vin
add wave -noupdate -format Literal -expand /tb/dut/vin_data
add wave -noupdate -format Literal /tb/dut/morph_vout
add wave -noupdate -format Literal -expand /tb/dut/morph_data
add wave -noupdate -format Literal /tb/dut/morph2_vout
add wave -noupdate -format Literal -expand /tb/dut/morph2_vout_data_1
add wave -noupdate -format Literal /tb/dut/morph3_vout
add wave -noupdate -format Literal -expand /tb/dut/morph3_vout_data_1
add wave -noupdate -format Literal /tb/dut/vout
add wave -noupdate -format Literal -expand /tb/dut/vout_data
add wave -noupdate -format Literal /tb/dut/my_morph/filter0_win_window
add wave -noupdate -format Literal /tb/dut/my_morph2/filter0_win_window
add wave -noupdate -format Literal /tb/dut/my_morph3/filter0_win_window
add wave -noupdate -format Literal /tb/dut/my_morph4/filter0_win_window
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6562157 ps} 0}
configure wave -namecolwidth 242
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
WaveRestoreZoom {4768878 ps} {11031122 ps}
