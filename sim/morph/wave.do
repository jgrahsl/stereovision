onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -expand /tb/dut/my_morph_1/my_filter0_window/my_translate/pipe_in
add wave -noupdate -format Logic /tb/dut/my_morph_1/my_filter0_window/my_translate/src_valid
add wave -noupdate -format Literal /tb/my_sim_sink/pipe_in
add wave -noupdate -format Logic /tb/my_sim_sink/src_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {37948607 ps} 0} {{Cursor 2} {6985000 ps} 0} {{Cursor 3} {215000 ps} 0} {{Cursor 4} {0 ps} 0}
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
WaveRestoreZoom {4716635 ps} {18336475 ps}
bookmark add wave initial {{0 ps} {27926121 ps}} 45
