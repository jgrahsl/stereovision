#!/usr/bin/python
import sys

import re
old = 0
ec = 0
oldp = 0
ph = 0

bin = ['0000','0001','0010','0011',
       '0100','0101','0110','0111',
       '1000','1001','1010','1011',
       '1100','1101','1110','1111']

def hex2bin(hexno):
   base2 = ''
   for d in hexno:
      base2 += bin[int(d,base=16)]
   return base2


for i in range(0,16*16,2):
   print hex2bin("%04x" % i) + hex2bin("%04x" % (i+1))
