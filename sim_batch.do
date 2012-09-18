transcript off
transcript file ""
vsim -novopt -t ps tb
run 10 ns
transcript file "transcript"
transcript file ""
run 30 us
quit -f