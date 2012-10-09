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
#    print "Set pipe " + str(adr) + " reg " + str(reg) + " to " + str(en)
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

 
def stream():
    set_reg(2,0x61,1)
    set_reg(2,0x70,1)        

    set_reg(0,0x61,1)
    set_reg(0,0x70,1)        

    set_reg(1,0x61,1)
    set_reg(1,0x70,1)        

    set_reg(2,0x71,1)

def snap():
#    set_reg(2,0x61,1)
#    set_reg(2,0x70,1)        

    set_reg(2,0x71,0)

#    set_reg(0,0x61,1)
#    set_reg(0,0x70,1)        

#    set_reg(1,0x61,1)
#    set_reg(1,0x70,1)        

def show0():
    set_reg(1,0x71,0)        

def show1():
    set_reg(1,0x71,1)        


def reqpic():
#    stream()
    set_reg(4,0x61,1)
    if (get_reg(4,0x70) & 1): 
        set_reg(4,0x70,0)
    else:
        set_reg(4,0x70,1)

def readpic():
    reqpic()
    a = flReadChannel(handle,2000, 0x20,320*240*2)
    width=320
    height=240
    i = 0
    im = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    for y in range(height):
        for x in range(width):

            c = (a[i])<<8 | (a[i+1])
            im.putpixel((x,y),(((c & 0xf800)>>11) << 3, ((c & 0x07e0)>>5) << 2 , (c & 0x001f)<<3, 255))
            i = i + 2        

    im.save(sys.argv[2])

def scan():
    i = 0
    while i < 32: 

        set_reg(i,0x61,3)
        v = flReadChannel(handle, 5000, 0x62,1)
        set_reg(i,0x61,0)
        print str(i) + ": rd_id = " + str(v)
#    if i == 0 and v != 0:
#        print "error"
#        while 1==1:
#            a  = 0
#    if i == 1 and v != 1:
#        print "error"
#        while 1==1:
#            a  = 0
#    if i == 29 and v != 8:
#        print "error"
#        while 1==1:
#            a  = 0
#    if i == 30 and v != 11:
#        print "error"
#        while 1==1:
#            a  = 0
#    if i == 31 and v != 7:
#        print "error"
#       while 1==1:
#           a  = 0
        i = i + 1

if sys.argv[1] == "pic":
    readpic()
elif sys.argv[1] == "stream":
    stream()
elif sys.argv[1] == "snap":
    snap()
elif sys.argv[1] == "show0":
    show0()
elif sys.argv[1] == "show1":
    show1()
elif sys.argv[1] == "req":
    reqpic()
elif sys.argv[1] == "scan":
    scan()

#f.close()
flClose(handle)
exit()


