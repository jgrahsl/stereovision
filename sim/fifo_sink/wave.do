onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TB
add wave -noupdate /tb/*
add wave -noupdate -divider HEAD
add wave -noupdate /tb/my_pipe_head/*
add wave -noupdate -divider FEED
add wave -noupdate /tb/my_sim_feed/*
add wave -noupdate -divider DUT
add wave -noupdate /tb/dut/*
add wave -noupdate -divider SINK
add wave -noupdate /tb/my_sim_sink/*
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {22145000 ps} 0} {{Cursor 2} {5093448 ps} 0} {{Cursor 3} {0 ps} 0} {{Cursor 4} {0 ps} 0}
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
WaveRestoreZoom {0 ps} {6981536 ps}
bookmark add wave initial {{0 ps} {6981536 ps}} 56
