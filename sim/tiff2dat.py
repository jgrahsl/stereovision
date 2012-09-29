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




def rgb888(i):
   return "{:08b}".format(i) + "{:08b}".format(i) + "{:08b}".format(i)

def rgb565(i):   
   return "{:05b}".format(i>>3) + "{:06b}".format(i>>2) + "{:05b}".format(i>>3)

def gray8(i):   
   return "{:08b}".format(i)

def mono(i):   
   return "{:01b}".format(i>>7)

for i in dat:

     
   print rgb888(i) + rgb565(i) + gray8(i) + mono(i)
