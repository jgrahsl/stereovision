
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
flcli --vp=1443:0007 --ivp=1443:0007 -s -x top.xsvf
flcli --vp=1443:0007 --ivp=1443:0007 -a 'w60 1f;w61 01;w70 01;w60 01;w61 01;w70 01;w60 1e;w61 01;w70 01;r20 96000 "a.out"'
cat a.out | ./usb2tiff.py $i.tiff
done