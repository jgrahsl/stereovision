#!/usr/bin/python
import time
import sys
from fpgalink2 import *
from PIL import Image
vp = "1443:0007"
handle = None
adr= 0x21

#                IRD & x"30001580", -- Chip version. Default 0x1580



         #       IRD & x"7833900000", -- Read until sequencer in mode 0 (run)
                






try:
    try:
        handle = flOpen(vp)
    except FLException, ex:
        jtagPort = "D0234"
        print "Loading firmware into %s..." %  vp
        flLoadStandardFirmware( vp, vp, jtagPort);

        print "Awaiting renumeration..."
        if ( not flAwaitDevice(vp, 600) ):
            raise FLException("FPGALink device did not renumerate properly as %s" % vp)

        print "Attempting to open connection to FPGALink device %s ..." % vp
        handle = flOpen(vp)

        flWriteChannel(handle, 1000, 0,0)

except FLException, ex:
#    print str(ex)
    xsvfFile = "../top.xsvf"
    print "Playing \"%s\" into the JTAG chain on FPGALink device %s..." % (xsvfFile, vp)
    flPlayXSVF(handle, xsvfFile)  # Or other SVF, XSVF or CSVF

print "-"
#print sys.argv[1]

#if sys.argv[1] == "pic":
#    readpic()

def tx(ba):
    flWriteChannel(handle, 1000, adr,ba)

def rx(ba):
    l = len(ba)
    a = flReadChannel(handle,2000, adr,l)
    for i in range(l):
        print hex(a[i]),
        if a[i] != ba[i]:
            print "ERROR !!!"
            flClose(handle)
            exit(1)
        else:
            print "ok"


def fill(s):
    c = len(s)/2
    ba = bytearray(c)
    for i in range(c):
        ba[i] = int(s[2*i:2*i+2],16)
    return ba

def issue(s):
    ba = fill(s)
    tx(ba)
#    rx(ba)

#issue("78338600007833860000")
#issue("7833860000")
#issue("7833860000")
#flClose(handle)
#exit()

for i in range(len(init)/2):
    print i
    issue(init[2*i])
sys.stdin.readline()
issue(init2[0])
   

#tx()
#tx2()
#rx()
#f.close()
flClose(handle)
exit()


