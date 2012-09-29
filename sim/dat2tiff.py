#!/usr/bin/python

import sys

from PIL import Image

try:
    width = int(sys.stdin.readline().rstrip("\n\r"))
    height = int(sys.stdin.readline().rstrip("\n\r"))
except Exception,e:
    a = 0
    width=16
    height=16
im = Image.new('RGBA', (width, height), (0, 0, 0, 0))

for y in range(height):
    for x in range(width):
        line = sys.stdin.readline().rstrip("\n\r")

#        off = 24+16+8
#        im.putpixel((x,y),(int(line[off:off+1],2)*255,int(line[off:off+1],2)*255,int(line[off:off+1],2)*255,255))
#        im.putpixel((x,y),(int(line[off:off+8],2),int(line[off:off+8],2),int(line[off:off+8],2),255))
        im.putpixel((x,y),(int(line[0:8],2),int(line[8:16],2),int(line[16:24],2),255))

#        if line[-1:] == "1":
#             im.putpixel((x,y),(255,255,255,255))
#        else:
#             im.putpixel((x,y),(0,0,0,255))
    
im.save(sys.argv[1])
