#!/bin/bash

STIM=$1
SRCDIR="../.."
SIMBASEDIR=".."

#INPUT DATA
$SIMBASEDIR/tiff2dat.py $STIM/input.tiff > sim.dat

cat sim.dat sim.dat sim.dat sim.dat sim.dat sim.dat sim.dat sim.dat > sim8.dat

#cp sim8.dat sim.dat
