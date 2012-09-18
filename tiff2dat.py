#!/usr/bin/python

import sys

from PIL import Image

im = Image.open(sys.argv[1])

dat = list(im.getdata())


bin = ['0000','0001','0010','0011',
       '0100','0101','0110','0111',
       '1000','1001','1010','1011',
       '1100','1101','1110','1111']

def hex2bin(hexno):
   base2 = ''
   for d in hexno:
      base2 += bin[int(d,base=16)]
   return base2

for i in dat:

    if i == 255:
        print "0000000000000000000000000000000000000000000000001"
    else:
        print "0000000000000000000000000000000000000000000000000"
