#!/usr/bin/python

import sys

from PIL import Image

width=640
height=480

im = Image.new('RGBA', (width, height), (0, 0, 0, 0))

for y in range(height):
    for x in range(width):


        if y == height-1 and x == width-1:
            c = "  "
        else:
            c = sys.stdin.read(2)

        c = ord(c[0])<<8 | ord(c[1])
        im.putpixel((x,y),(((c & 0xf800)>>11) << 3, ((c & 0x07e0)>>5) << 2 , (c & 0x001f)<<3, 255))

#        off = 24+16+8
#        im.putpixel((x,y),(int(line[off:off+1],2)*255,int(line[off:off+1],2)*255,int(line[off:off+1],2)*255,255))
#        im.putpixel((x,y),(int(line[off:off+8],2),int(line[off:off+8],2),int(line[off:off+8],2),255))
#        im.putpixel((x,y),(int(line[0:8],2),int(line[8:16],2),int(line[16:24],2),255))

#        if line[-1:] == "1":
#             im.putpixel((x,y),(255,255,255,255))
#        else:
#             im.putpixel((x,y),(0,0,0,255))
    
im.save(sys.argv[1])
