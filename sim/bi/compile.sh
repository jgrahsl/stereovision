#!/bin/bash

STIM=$1
SRCDIR="../.."
SIMBASEDIR=".."

VHD="txt_util.vhd cam_pkg.vhd null.vhd pipe_head.vhd sim_feed.vhd sim_sink.vhd romdata.vhd rom.vhd bi.vhd"
TB=tb.vhd

#CLEAN
rm -f sim.dat sim.out output.tiff 

#COMPILE
rm -fR work
vlib work
for i in $VHD; do
    vcom -93 -work work $SRCDIR/$i  
    if [ $? -ne 0 ]; then
        exit;
    fi
done

#COMILE TB AND PKG
vcom -93 -work work $STIM/sim_pkg.vhd && vcom -93 -work work $TB
if [ $? -ne 0 ]; then
    exit;
fi
