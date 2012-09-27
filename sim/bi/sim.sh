#!/bin/bash

VHD="txt_util.vhd cam_pkg.vhd null.vhd pipe_head.vhd sim_feed.vhd sim_sink.vhd romdata.vhd rom.vhd bi.vhd"

export PATH=$PATH:/opt/model6.4/linux
export LM_LICENSE_FILE=/opt/model6.4/lic.dat

STIM=$1
SRCDIR="../.."
SIMBASEDIR=".."

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

#INPUT DATA
$SIMBASEDIR/tiff2dat.py $STIM/input.tiff > sim.dat
cat sim.dat sim.dat sim.dat sim.dat sim.dat sim.dat sim.dat sim.dat > sim8.dat
cp sim8.dat sim.dat

vsim -do $SIMBASEDIR/sim.do

cat sim.out | $SIMBASEDIR/dat2tiff.py $STIM/output.tiff
cat $STIM/sim.out | $SIMBASEDIR/dat2tiff.py $STIM/expect.tiff

echo "Difference:"
diff sim.out $STIM/sim.out

#CLEANUP
mv transcript $STIM
mv sim.out $STIM/last.out
rm sim8.dat sim.dat vsim.wlf

#convert $STIM -scale 256x256 i.tiff
#convert output.tiff -scale 256x256 o.tiff
#rm output.tiff

#ghdl -m --workdir=simu --work=work tb 
#./tb --stop-time=100us 

