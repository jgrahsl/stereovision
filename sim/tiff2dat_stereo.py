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
   print rgb888(datl[i]) + "{:08b}".format(datl[i]) +"{:08b}".format(datr[i]) + gray8(datl[i]) + mono(datl[i])
