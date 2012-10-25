#!/usr/bin/python
import time
import sys
from fpgalink2 import *
from PIL import Image
vp = "1443:0007"
handle = None


#                IRD & x"30001580", -- Chip version. Default 0x1580


init = ["33860501", "MCU Reset",
"33860500", "MCU Release from reset",
"32140D85", "Slew rate control, PCLK 5, D 5",
"341E8F0B", "PLL control; bypassed, powered down",
"341C0250", "PLL dividers; M=80,N=2,fMCLK=fCLKIN*M/(N+1)/8=80MHz",
"341E8F09", "PLL control; Power-up PLL; wait 1ms after this!",
"341E8F08", "PLL control; Turn off bypass",
"32020008", "Standby control; Wake up",
"338C2797", "Output format; Context B shadow",
"33900030", "RGB with BT656 codes",

"338C272F", "Sensor Row Start Context B",
"33900004", "4",
"338C2733", "Sensor Row End Context B",
"339004BB", "1211",
"338C2731", "Sensor Column Start Context B",
"33900004", "4",
"338C2735", "Sensor Column End Context B",
"3390064B", "1611",
"338C2707", "Output width; Context B",
"33900140", "1600",

"338C2709", "Output height; Context B",
"339000F0", "1200",
"338C275F", "Crop X0; Context B",
"33900000", "0",
"338C2763", "Crop Y0; Context B",
"33900000", "0",
"338C2761", "Crop X1; Context B",
"33900640", "1600",
"338C2765", "Crop Y1; Context B",
"339004B0", "1200",

"338C2741", "Sensor_Fine_IT_min B",
"33900169", "361               ",
"338CA120", "Capture mode options",
"33900002", "Turn on AE, Video",
"338CA137", "Capture mode options",
"33900000", "AE Manual mde",
"338CA223", "Capture mode options",
"33900000", "Integration time                                         ",
"338CA103", "Refresh Sequencer Mode",
"33900002", "Capture"]

init2 = ["301A02CC","reset/output control; parallel enable, drive pins, start streaming"]

         #       IRD & x"33900000", -- Read until sequencer in mode 0 (run)
                






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

        flWriteChannel(handle, 1000, 0x21,0)

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
    flWriteChannel(handle, 1000, 0x21,ba)

def tx2():
    ba = bytearray(2)
#    ba[0] = 0x02
    ba[1] = 0xCC
    flWriteChannel(handle, 1000, 0x21,ba)

def rx(ba):
    l = 5
    a = flReadChannel(handle,2000, 0x21,l)
    for i in range(l):
        print hex(a[i]),
        if a[i] != ba[i]:
            print "err"
        else:
            print "ok"

for i in range(1):
    ba = bytearray(5)
    ba[0] = 0x78
    c = 2*i
    ba[1] = int(init[c][0:2],16)
    ba[2] = int(init[c][2:4],16)
    ba[3] = int(init[c][4:6],16)
    ba[4] = int(init[c][6:8],16)  
    print i
    tx(ba)
    rx(ba)

#    rx()
#    sys.stdin.readline()

flClose(handle)
exit()

#tx()
#tx2()
#rx()
#f.close()
flClose(handle)
exit()


