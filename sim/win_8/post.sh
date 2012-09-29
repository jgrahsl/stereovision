#!/bin/bash

STIM=$1
SRCDIR="../.."
SIMBASEDIR=".."

cat sim.out | $SIMBASEDIR/dat2tiff.py $STIM/output.tiff
cat $STIM/sim.out | $SIMBASEDIR/dat2tiff.py $STIM/expect.tiff

echo "Difference:"
diff sim.out $STIM/sim.out

#CLEANUP
mv transcript $STIM
mv sim.out $STIM/last.out
#rm sim8.dat sim.dat vsim.wlf
