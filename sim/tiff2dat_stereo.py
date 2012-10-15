#!/usr/bin/python

import sys

from PIL import Image

iml = Image.open(sys.argv[1])
imr = Image.open(sys.argv[2])

datl = list(iml.getdata())
datr = list(imr.getdata())

def rgb888(i):
   return "{:08b}".format(i) + "{:08b}".format(i) + "{:08b}".format(i)

def rgb565(i):   
   return "{:05b}".format(i>>3) + "{:06b}".format(i>>2) + "{:05b}".format(i>>3)

def gray8(i):   
   return "{:08b}".format(i)

def mono(i):   
   return "{:01b}".format(i>>7)

for i in range(len(datl)):    
#   print datr[i]
   l = datl[i][0]
   r = datr[i][0]
   print rgb888(l) + "{:08b}".format(l) +"{:08b}".format(r) + gray8(l) + mono(l)
