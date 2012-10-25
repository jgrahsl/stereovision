#!/usr/bin/python
import time
import sys
from fpgalink2 import *
from PIL import Image
vp = "1443:0007"
handle = None

def send_byte(chan,val):
    global handle
    ba = bytearray(1)
    ba[0] = val
#    ba[1] = val
    flWriteChannel(handle, 1000, chan,ba)

def recv_byte(chan):
    global handle
    return flReadChannel(handle, 1000, chan,1)

def set_pipe(n):
    send_byte(0x60,n)

def set_enable(adr,en):
    set_reg(adr,0x61,en)

def set_reg(adr,reg,en):
    set_pipe(adr)
    send_byte(reg,en)

def get_reg(adr,reg):
    set_pipe(adr)
    return recv_byte(reg)

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

        set_reg(0,0,0)

except FLException, ex:
#    print str(ex)
    xsvfFile = "../top.xsvf"
    print "Playing \"%s\" into the JTAG chain on FPGALink device %s..." % (xsvfFile, vp)
    flPlayXSVF(handle, xsvfFile)  # Or other SVF, XSVF or CSVF

print "-"
#print sys.argv[1]

#if sys.argv[1] == "pic":
#    readpic()

def tx():
    flWriteChannel(handle, 1000, 0x21,ba)

def tx2():
    ba = bytearray(2)
#    ba[0] = 0x02
    ba[1] = 0xCC
    flWriteChannel(handle, 1000, 0x21,ba)

def rx():
    a = flReadChannel(handle,2000, 0x21,5)
    for i in range(5):
        print hex(a[i]),
        if a[i] != ba[i]:
            print "err"
        else:
            print "ok"

ba = bytearray(5)
ba[0] = 0x78
ba[1] = 0x30
ba[2] = 0x1A   
ba[3] = 0x02
ba[4] = 0xCC


tx()
#tx2()
rx()
#f.close()
flClose(handle)
exit()


