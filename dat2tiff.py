#!/usr/bin/python

import sys

from PIL import Image


width = 18
height = 18
im = Image.new('RGBA', (width, height), (0, 0, 0, 0))

for y in range(height):
    for x in range(width):
        line = sys.stdin.readline().rstrip("\n\r")
        if line[-1:] == "1":
             im.putpixel((x,y),(255,255,255,255))
        else:
             im.putpixel((x,y),(0,0,0,255))
    
im.save("output.tiff")
