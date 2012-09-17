onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb/my_sim_feed/clk
add wave -noupdate -format Literal /tb/my_morph/width
add wave -noupdate -format Literal /tb/my_morph/pipe_out
add wave -noupdate -format Literal /tb/my_morph/pipe_in
add wave -noupdate -format Literal -expand /tb/my_morph/pipe
add wave -noupdate -format Literal /tb/my_morph/kernel
add wave -noupdate -format Literal /tb/my_morph/id
add wave -noupdate -format Literal /tb/my_morph/height
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1065000 ps} 0} {{Cursor 2} {23136029 ps} 0}
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
WaveRestoreZoom {0 ps} {9818112 ps}
bookmark add wave initial {{0 ps} {9818112 ps}} 0
