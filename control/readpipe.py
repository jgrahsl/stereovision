#!/usr/bin/python
import time
import sys
from fpgalink2 import *
from PIL import Image

caminit = [
"7930001580", "Read chipversion",
"7833860501", "MCU Reset",
"7833860500", "MCU Release from reset",
"7832140D85", "Slew rate control, PCLK 5, D 5",
"78341E8F0B", "PLL control; bypassed, powered down",
"78341C0250", "PLL dividers; M=80,N=2,fMCLK=fCLKIN*M/(N+1)/8=80MHz",
"78341E8F09", "PLL control; Power-up PLL; wait 1ms after this!",
"78341E8F08", "PLL control; Turn off bypass",
"7832020008", "Standby control; Wake up",
"78338C2797", "Output format; Context B shadow",
"7833900030", "RGB with BT656 codes",
"78338C272F", "Sensor Row Start Context B",
"7833900004", "4",
"78338C2733", "Sensor Row End Context B",
"78339004BB", "1211",
"78338C2731", "Sensor Column Start Context B",
"7833900004", "4",
"78338C2735", "Sensor Column End Context B",
"783390064B", "1611=64B",
"78338C2707", "Output width; Context B",
"7833900140", "1600",
"78338C2709", "Output height; Context B",
"78339000F0", "1200",
"78338C275F", "Crop X0; Context B",
"7833900000", "0",
"78338C2763", "Crop Y0; Context B",
"7833900000", "0",
"78338C2761", "Crop X1; Context B",
"7833900640", "1600",
"78338C2765", "Crop Y1; Context B",
"78339004B0", "1200",
"78338C2741", "Sensor_Fine_IT_min B",
"7833900169", "78361               ",
"78338CA120", "Capture mode options",
"7833900002", "Turn on AE, Video",
"78338CA137", "Capture mode options",
"7833900000", "AE Manual mde",
"78338CA223", "Capture mode options",
"7833900000", "Integration time                                         ",
"78338CA103", "Refresh Sequencer Mode",
"7833900002", "Capture",
"7933900000", "Wait until seq in mode 0(run)",
"78301A02CC","reset/output control; parallel enable, drive pins, start streaming"
]

I2CA = 0x21
I2CB = 0x22
P0 = 0x70
P1 = 0x71
PADDR = 0x60
PEN = 0x61


def flwr(pipe,data):
    flWriteChannel(handle,1000,pipe,data)
def flrd(pipe,l):
    return flReadChannel(handle,1000,pipe,l)

def send_byte(chan,val):
    ba = bytearray(1)
    ba[0] = val
    flwr(chan,ba)
def recv_byte(chan):
    return flrd(chan,1)
def set_pipe(n):
    send_byte(PADDR,n)
def set_enable(adr,en):
    set_reg(adr,PEN,en)
def set_reg(adr,reg,en):
    set_pipe(adr)
    send_byte(reg,en)
def get_reg(adr,reg):
    set_pipe(adr)
    return recv_byte(reg)

vp = "1443:0007"
handle = None
need_init = False
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
    xsvfFile = "../top.xsvf"
    print "Playing \"%s\" into the JTAG chain on FPGALink device %s..." % (xsvfFile, vp)
    flPlayXSVF(handle, xsvfFile)  # Or other SVF, XSVF or CSVF
    need_init = True

def stream():
    set_reg(2,PEN,1)
    set_reg(2,P0,1)        

    set_reg(0,PEN,1)
    set_reg(0,P0,1)        

    set_reg(1,PEN,1)
    set_reg(1,P0,1)        

    set_reg(2,P1,1)

def snap():
    set_reg(2,P1,0)

def show0():
    set_reg(1,P1,0)        

def show1():
    set_reg(1,P1,1)        

def reqpic():
    set_reg(4,PEN,1)
    if (get_reg(4,P0) & 1): 
        set_reg(4,P0,0)
    else:
        set_reg(4,P0,1)

def readpic():
    reqpic()
    a = flrd(0x20,320*240*2)
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
        set_reg(i,PEN,3)
        v = flrd(0x62,1)
        set_reg(i,PEN,0)
        print str(i) + ": rd_id = " + hex(v)
        i = i + 1

def on():
    i = 0
    while i < 32: 
        set_reg(i,PEN,3)
        v = flrd(0x62,1)
        if v != 0:
            set_reg(i,PEN,1)
            print str(i) + ": on"

            if v == 0x01:
                set_reg(i,P0,1)
                set_reg(i,P1,1)
            if v == 0x07:
                set_reg(i,P0,1)
                set_reg(i,P1,1)
        else:
            set_reg(i,PEN,0)
        i = i + 1

def hex2ba(s):
    c = len(s)/2
    ba = bytearray(c)
    for i in range(c):
        ba[i] = int(s[2*i:2*i+2],16)
    return ba
def cfg(addr):
    for i in range(len(caminit)/2):
#        print i
        flwr(addr,hex2ba(caminit[2*i]))
def i2c():
    cfg(I2CA)
    cfg(I2CB)
if need_init:
    i2c()

print sys.argv[1]
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
elif sys.argv[1] == "on":
    on()
elif sys.argv[1] == "i2c":
    i2c()
#f.close()
flClose(handle)
exit()


