#!/usr/bin/python

from controlui import *
import time
from fpgalink2 import *

def send_byte(chan,val):
    global handle
    ba = bytearray(b" ")
    ba[0] = val
    print "wrChan:" +str(chan) + " " + str(val)
    flWriteChannel(handle, 1000, chan,ba)

def set_pipe(n):
    send_byte(0x60,n)

def set_enable(adr,en):
    set_pipe(adr)
    send_byte(0x61,en)

def set_reg(adr,reg,en):
#    print "Set pipe " + str(adr) + " reg " + str(reg) + " to " + str(en)
    set_pipe(adr)
    send_byte(reg,en)


vp = "1443:0007"
handle = None


#handle = FLHandle()
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
    xsvfFile = "/home/julian/stereovision/top.xsvf"
    print "Playing \"%s\" into the JTAG chain on FPGALink device %s..." % (xsvfFile, vp)
    flPlayXSVF(handle, xsvfFile)  # Or other SVF, XSVF or CSVF

def do_exit():
    global handle

    flClose(handle)
    app.exit(0)

set_reg(18,0x70,1)
v = flReadChannel(handle, 5000, 0x20,1000)
print len(v)

while True:
    v1 = flReadChannel(handle, 5000, 0x22,1)
    v2 = flReadChannel(handle, 5000, 0x23,1)
    v = v2*256 + v1
    if v > 1:
        v = flReadChannel(handle, 5000, 0x20,v)
        print len(v)
    elif v == 1:
        v = flReadChannel(handle, 5000, 0x20,v)
        print 1

