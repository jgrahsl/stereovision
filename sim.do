quit -sim
vsim -novopt -t ps tb
view wave
do wave.do
run 10 us
