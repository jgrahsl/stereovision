#!/usr/bin/python
import time

from fpgalink2 import *

vp = "1443:0007"
handle = None

def send_byte(chan,val):
    global handle
    ba = bytearray(1)
    ba[0] = val
#    ba[1] = val
#    ba[2] = val
#    ba[3] = val
#    print "wrChan:" +str(chan) + " " + str(val)
    flWriteChannel(handle, 1000, chan,ba)

def set_pipe(n):
    send_byte(0x60,n)

def set_enable(adr,en):
    set_reg(adr,0x61,en)

def set_reg(adr,reg,en):
#    print "Set pipe " + str(adr) + " reg " + str(reg) + " to " + str(en)
    set_pipe(adr)
    send_byte(reg,en)

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


def readpic():
    set_reg(31,0x60,1)
    set_reg(31,0x61,1)
    set_reg(31,0x70,1)        

    set_reg(0,0x60,1)
    set_reg(0,0x61,1)
    set_reg(0,0x70,1)        

    set_reg(1,0x60,0)
    set_reg(1,0x61,1)
    set_reg(1,0x70,1)        

    set_reg(30,0x60,1)
    set_reg(30,0x61,1)
    set_reg(30,0x70,1)     
#time.sleep(1)

    count = 00
    f = open("a.out","w")
    a = flReadChannel(handle,2000, 0x20,640*480*2)
    f.write(a)
    f.close()
    flClose(handle)
    exit()

    while ba > 0:
        a = flReadChannel(handle,1000, 0x20,ba)
        f.write(a)
        count = count + ba
        print count
        ba = flReadChannel(handle, 1000, 0x22, 1)
        print ba

i = 0
while i < 32: 

    set_reg(i,0x61,3)
    v = flReadChannel(handle, 5000, 0x62,1)
    set_reg(i,0x61,0)
    print str(i) + ": rd_id = " + str(v)

    if i == 0 and v != 0:
        print "error"
        while 1==1:
            a  = 0
    if i == 1 and v != 1:
        print "error"
        while 1==1:
            a  = 0
    if i == 29 and v != 8:
        print "error"
        while 1==1:
            a  = 0
    if i == 30 and v != 11:
        print "error"
        while 1==1:
            a  = 0
    if i == 31 and v != 7:
        print "error"
        while 1==1:
            a  = 0


    i = i + 1


#f.close()
flClose(handle)
exit()


