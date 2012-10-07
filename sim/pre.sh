#!/bin/bash

set -e 
set -o pipefail

MODULE=$1
STIM=$2

#INPUT DATA

if [ "$MODULE" == "disp" ]; then
    ./tiff2dat_stereo.py $MODULE/$STIM/l.tiff $MODULE/$STIM/r.tiff > stereo.dat
else
    ./tiff2dat.py $MODULE/$STIM/input.tiff > sim.dat
    cat sim.dat sim.dat sim.dat sim.dat sim.dat sim.dat sim.dat sim.dat > sim8.dat
    cp sim8.dat sim.dat

fi