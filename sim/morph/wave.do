onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -r /pipe
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {22145000 ps} 0} {{Cursor 2} {2825000 ps} 0} {{Cursor 3} {940000 ps} 0} {{Cursor 4} {0 ps} 0}
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
WaveRestoreZoom {0 ps} {27926121 ps}
bookmark add wave initial {{0 ps} {27926121 ps}} 45
