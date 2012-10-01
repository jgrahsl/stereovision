
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
flcli --vp=1443:0007 --ivp=1443:0007 -s -x top.xsvf
flcli --vp=1443:0007 --ivp=1443:0007 -a 'w60 1f;w61 01;w70 01;w60 01;w61 01;w70 01;w60 1e;w61 01;w70 01;r20 96000 "a.out"'
flcli --vp=1443:0007 --ivp=1443:0007 -a 'w70 00;r20 96000 "a.out";w70 01;r20 96000 "b.out";w70 00;r20 96000 "c.out";w70 01;r20 96000 "d.out";w70 00;r20 96000 "e.out"'

cat a.out | ./usb2tiff.py a$i.tiff
cat b.out | ./usb2tiff.py b$i.tiff
cat c.out | ./usb2tiff.py c$i.tiff
cat d.out | ./usb2tiff.py d$i.tiff
cat e.out | ./usb2tiff.py e$i.tiff

done