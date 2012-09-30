#!/bin/bash

MODULE=$1
STIM=$2

#INPUT DATA
./tiff2dat.py $MODULE/$STIM/input.tiff > sim.dat
cat sim.dat sim.dat sim.dat sim.dat sim.dat sim.dat sim.dat sim.dat > sim8.dat
cp sim8.dat sim.dat
