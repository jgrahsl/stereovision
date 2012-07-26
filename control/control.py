#!/usr/bin/python
from sip import *
import sip
from controlui import *
from morph import *
from motion import *
from skin import *
from histx import *
from histy import *
from mcbfeed import *
from mcbsink import *

import time
from fpgalink2 import *

def send_byte(chan,val):
    global handle
    ba = bytearray(b"    ")
    ba[0] = val
    ba[1] = val
    ba[2] = val
    ba[3] = val
    print "wrChan:" +str(chan) + " " + str(val)
    flWriteChannel(handle, 1000, chan,ba)

def set_pipe(n):
    send_byte(0x60,n)

def set_enable(adr,en):
    set_reg(adr,0x61,en)

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
    xsvfFile = "../top.xsvf"
    print "Playing \"%s\" into the JTAG chain on FPGALink device %s..." % (xsvfFile, vp)
    flPlayXSVF(handle, xsvfFile)  # Or other SVF, XSVF or CSVF
set_reg(0,0,0)

############
############
############





def do_exit():
    global handle

    flClose(handle)
    app.exit(0)

class MCBFeed(Ui_MCBFeedBox):
    def __init__(self, box,pid):
        self.pid = pid
        self.pipe = box
        self.box = QtGui.QGroupBox(box.parentWidget())
        self.setupUi(self.box)
        self.pipe.addWidget(self.box)
        self.enable.stateChanged.connect(self.en)
        self.en(1)

    def en(self,v):
        self.enable.setCheckState(v)
        if v:
            set_enable(self.pid,1)
        else:
            set_enable(self.pid,0)

class MCBSink(Ui_MCBSinkBox):
    def __init__(self, box,pid):
        self.pid = pid
        self.pipe = box
        self.box = QtGui.QGroupBox(box.parentWidget())
        self.setupUi(self.box)
        self.pipe.addWidget(self.box)
        self.enable.stateChanged.connect(self.en)
        self.en(1)

    def en(self,v):
        self.enable.setCheckState(v)
        if v:
            set_enable(self.pid,1)
        else:
            set_enable(self.pid,0)


class Skin(Ui_SkinBox):
    def __init__(self, box,pid):
        self.pid = pid
        self.pipe = box
        self.box = QtGui.QGroupBox(box.parentWidget())
        self.setupUi(self.box)
        self.pipe.addWidget(self.box)
        self.enable.stateChanged.connect(self.en)
        self.en(0)

    def en(self,v):
        self.enable.setCheckState(v)
        if v:
            set_enable(self.pid,1)
        else:
            set_enable(self.pid,0)

class HistX(Ui_HistXBox):
    def __init__(self, box,pid):
        self.pid = pid
        self.pipe = box
        self.box = QtGui.QGroupBox(box.parentWidget())
        self.setupUi(self.box)
        self.pipe.addWidget(self.box)
        self.enable.stateChanged.connect(self.en)
        self.en(0)

    def en(self,v):
        self.enable.setCheckState(v)
        if v:
            set_enable(self.pid,1)
        else:
            set_enable(self.pid,0)

class HistY(Ui_HistYBox):
    def __init__(self, box,pid):
        self.pid = pid
        self.pipe = box
        self.box = QtGui.QGroupBox(box.parentWidget())
        self.setupUi(self.box)
        self.pipe.addWidget(self.box)
        self.enable.stateChanged.connect(self.en)
        self.en(0)

    def en(self,v):
        self.enable.setCheckState(v)
        if v:
            set_enable(self.pid,1)
        else:
            set_enable(self.pid,0)

class Morph(Ui_MorphBox):
    def __init__(self, box,pid):
        self.pid = pid
        self.pipe = box
        self.box = QtGui.QGroupBox(box.parentWidget())
        self.setupUi(self.box)
        self.pipe.addWidget(self.box)
        self.enable.stateChanged.connect(self.en)

        self.morph_th_5.valueChanged.connect(self.th1_c)
        self.morph_th_6.valueChanged.connect(self.th2_c)
        self.morph_th_7.valueChanged.connect(self.th3_c)
        self.morph_th_8.valueChanged.connect(self.th4_c)
        self.en(0)

    def en(self,v):
        self.enable.setCheckState(v)
        if v:
            for i in range(0,12):
                set_enable(self.pid+i,1)
        else:
            for i in range(0,12):
                set_enable(self.pid+i,0)

    def th1_c(self,v):
        set_reg(self.pid+2,0x70,v)
    def th2_c(self,v):
        set_reg(self.pid+5,0x70,v)
    def th3_c(self,v):
        set_reg(self.pid+8,0x70,v)
    def th4_c(self,v):
        set_reg(self.pid+11,0x70,v)


class Motion(Ui_MotionBox):

    def __init__(self,box,pid):
        self.pid = pid
        self.pipe = box        
        self.box = QtGui.QGroupBox(box.parentWidget())
        self.setupUi(self.box) 
        self.pipe.addWidget(self.box)     
        self.enable.stateChanged.connect(self.en)

        self.radioButton.toggled.connect(self.radio)
        self.radioButton_2.toggled.connect(self.radio)
        self.radioButton_3.toggled.connect(self.radio)
        self.radioButton_4.toggled.connect(self.radio)
        self.radioButton_5.toggled.connect(self.radio)

        self.motion_p01.valueChanged.connect(self.motion_c)
        self.motion_p23.valueChanged.connect(self.motion_c)
        self.motion_p4.valueChanged.connect(self.motion_c)

        self.learn.clicked.connect(self.setlearn)
        self.detect.clicked.connect(self.setdetect)
        self.lock.stateChanged.connect(self.radio)
        self.en(0)

    def en(self,v):
        self.enable.setCheckState(v)
        if v:
            set_enable(self.pid,1)
        else:
            set_enable(self.pid,0)

    def motion_c(self,v):
        set_reg(self.pid,0x70,self.motion_p01.value()%256)
        set_reg(self.pid,0x71,self.motion_p01.value()/256)
        set_reg(self.pid,0x72,self.motion_p23.value()%256)
        set_reg(self.pid,0x73,self.motion_p23.value()/256)
        set_reg(self.pid,0x74,self.motion_p4.value())


    def radio(self,p):
        v = 0
        if self.lock.isChecked():
            v = 0x80
        
        if self.radioButton.isChecked():
            set_reg(self.pid,0x075,v)
        if self.radioButton_2.isChecked():
            set_reg(self.pid,0x075,v|4)
        if self.radioButton_3.isChecked():
            set_reg(self.pid,0x075,v|2)
        if self.radioButton_4.isChecked():
            set_reg(self.pid,0x075,v|1)
        if self.radioButton_5.isChecked():
            set_reg(self.pid,0x075,v|3)
            

    def setlearn(self):

        set_enable(self.pid,1)
        set_reg(self.pid,0x70,4)
        set_reg(self.pid,0x71,0)
        
        set_reg(self.pid,0x72,0)
        set_reg(self.pid,0x73,2)

        set_reg(self.pid,0x74,1)

        set_reg(self.pid,0x75,3)

    def setdetect(self):
    
        set_reg(self.pid,0x70,8)
        set_reg(self.pid,0x71,0)
        set_reg(self.pid,0x72,8)
        set_reg(self.pid,0x73,0)
        
        set_reg(self.pid,0x74,1)
        
        set_reg(self.pid,0x75,0)



#f = open("w.dat")
#s = f.read()
#qi = QtGui.QImage(s,640/128,480, QtGui.QImage.Format_RGB888);
#ui.label_pic.setPixmap(QtGui.QPixmap.fromImage(qi));

#myLabel.show();


app = QtGui.QApplication(sys.argv)
MainWindow = QtGui.QMainWindow(None)
ui = Ui_MainWindow()
ui.setupUi(MainWindow)
t = []
i = 0
while True:
    set_reg(i,0x61,3)
    v = flReadChannel(handle, 5000, 0x62,6)

    set_reg(i,0x61,0)

    if v[0] == 0x01:
        print "MCBFeed at " + str(i)
        t.append(MCBFeed(ui.pipe,i))
    if v[0] == 0x02:
        print "Skin at " + str(i)
        t.append(Skin(ui.pipe,i)) 
    if v[0] == 0x03:
        print "Motion at " + str(i)
        t.append(Motion(ui.pipe,i)) 
    if v[0] == 0x04:
        print "Morph at " + str(i-2)
        t.append(Morph(ui.pipe,i-2))
        i = i + 9
    if v[0] == 0x05:
        print "HistX at " + str(i)
        t.append(HistX(ui.pipe,i)) 
    if v[0] == 0x06:
        print "HistY at " + str(i)
        t.append(HistY(ui.pipe,i)) 
    if v[0] == 0x07:
        print "MCBSink at " + str(i)
        t.append(MCBSink(ui.pipe,i))
       
    i = i + 1
    if i > 20:
        break
QtCore.QObject.connect(ui.pushButton_exit, QtCore.SIGNAL("clicked()"), do_exit)


MainWindow.show()
r = app.exec_()
sys.exit(r)


