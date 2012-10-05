#!/bin/bash

#set -e 
#set -o pipefail

MODULE=$1
STIM=$2

cat $MODULE/$STIM/sim.out | ./dat2tiff.py $MODULE/$STIM/expect.tiff
cat sim.out | ./dat2tiff.py $MODULE/$STIM/output.tiff

echo "Difference:"

diff $MODULE/$STIM/sim.out sim.out
RETVAL=$?

#CLEANUP
mv transcript $MODULE/$STIM
mv sim.out $MODULE/$STIM/last.out
rm -f wlf* *.wlf

exit $RETVAL