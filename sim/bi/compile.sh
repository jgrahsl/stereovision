#!/bin/bash

STIM=$1
SRCDIR="../.."
SIMBASEDIR=".."

VHD="txt_util.vhd cam_pkg.vhd null.vhd pipe_head.vhd sim_feed.vhd sim_sink.vhd romdata.vhd rom.vhd bilinear.vhd bi.vhd bi2.vhd"
TB=tb.vhd

#CLEAN
rm -f sim.out output.tiff 

#COMPILE
rm -fR work
vlib work
for i in $VHD; do
echo $i
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
