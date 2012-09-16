#!/usr/bin/python

import sys

from PIL import Image



im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))

for y in range(16):
    for x in range(16):
        line = sys.stdin.readline().rstrip("\n\r")
        if line[-1:] == "1":
             im.putpixel((x,y),(255,255,255,255))
        else:
             im.putpixel((x,y),(0,0,0,255))
    
im.save("output.tiff")
