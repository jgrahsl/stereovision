#!/usr/bin/python

import sys
x = 0
y = 0
c = sys.stdin.readline().strip()
csv = False

if len(sys.argv) > 2:
    if sys.argv[2] == "csv":
        csv = True


while c != "":

    l  = c.split()
    try:
        for i in l:
            if sys.argv[1] == "x":
                off = x - float(i)
                if x < 319:
                    if csv:
                        print str(off) + ",",
                    else:
                        print str(off) + ","
                else:
                    if csv:
                        print str(off)
                    else:
                        print str(off) + ","

            if sys.argv[1] == "y":
                off = y - float(i)
                if x < 319:
                    if csv:
                        print str(off) + ",",
                    else:
                        print str(off) + ","
                else:
                    if csv:
                        print str(off)
                    else:
                        print str(off) + ","

            if x < (320-1):
                x = x + 1
            else:
                x = 0

                if y < (240-1):
                    y = y + 1
                else:
                    y = 0

    except Exception,e:
        z=0

    c = sys.stdin.readline().strip()

