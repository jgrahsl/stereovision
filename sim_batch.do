transcript off
transcript file ""

vsim -novopt -t ps tb

set NumericStdNoWarnings 1
set StdArithNoWarnings 1
when -label end_of_simulation {/tb/finish == '1'} {echo "End of simulation" ; stop ; quit -f }
when -label enable_StdWarn {/tb/rst == '0'} { set StdArithNoWarnings 0 ; set NumericStdNoWarning 0 }
transcript file "transcript"

run 100 us
echo "Timeout of simulation" 
quit -f




