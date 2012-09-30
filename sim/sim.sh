#!/bin/bash

export PATH=$PATH:/opt/model6.4/linux
export LM_LICENSE_FILE=/opt/model6.4/lic.dat

MODULE=`echo $1|cut -d'/' -f1`
STIM=`echo $1|cut -d'/' -f2`

./pre.sh $MODULE $STIM
./compile.sh $MODULE $STIM

vmap work $MODULE/work

if [ "$2" == "gui" ]; then
    cp $MODULE/wave.do .
    vsim -do sim.do
else
    vsim -c -do sim_batch.do
fi

./post.sh $MODULE $STIM

RETVAL=$?
exit $RETVAL