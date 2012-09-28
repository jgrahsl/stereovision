#!/bin/bash

export PATH=$PATH:/opt/model6.4/linux
export LM_LICENSE_FILE=/opt/model6.4/lic.dat

STIM=$1
SRCDIR="../.."
SIMBASEDIR=".."


./pre.sh $STIM
./compile.sh $STIM

vsim -c -do $SIMBASEDIR/sim_batch.do

./post.sh $STIM