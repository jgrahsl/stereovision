#!/bin/bash

function go_home(){
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null
cd $SCRIPTPATH
}

go_home

MODULE=$1
STIM=$2

SRCDIR=".."
TB=tb.vhd
OPT="-quiet -93 -work $MODULE/work"

VHD=""

#CLEAN
rm -f sim.out output.tiff 

#COMPILE
rm -fR $MODULE/work
vlib $MODULE/work
#vmap work $MODULE/work

for i in $(cat $MODULE/tb.prj); do
    vcom $OPT $SRCDIR/$i  
    if [ $? -ne 0 ]; then
        exit;
    fi
done

#COMILE TB AND PKG
vcom $OPT $MODULE/$STIM/sim_pkg.vhd && vcom $OPT $MODULE/$TB
if [ $? -ne 0 ]; then
    exit;
fi
