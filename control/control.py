#!/usr/bin/python
from sip import *
import sip
from controlui import *

from enable import * 
from morph import *
from motion import *
from hist import *


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

class Enable(Ui_EnableBox):
    def __init__(self, box,pid,name):
        self.pid = pid
        self.pipe = box
        self.box = QtGui.QGroupBox(box.parentWidget())
        self.setupUi(self.box)
        self.pipe.addWidget(self.box)
        self.enable.stateChanged.connect(self.en)
        self.p00.stateChanged.connect(self.p)
        self.en(0)
        self.box.setTitle(name)
#        self.box.setWindowTitle(QtGui.QApplication.translate("SkinBox", "GroupBox", None, QtGui.QApplication.UnicodeUTF8))
#        SkinBox.setTitle(QtGui.QApplication.translate("SkinBox", "SkinBox", None, QtGui.QApplication.UnicodeUTF8))
#        self.enable.setText(QtGui.QApplication.translate("SkinBox", "enable", None, QtGui.QApplication.UnicodeUTF8))


    def en(self,v):
        self.enable.setChecked(v)
        if v:
            set_enable(self.pid,1)
        else:
            set_enable(self.pid,0)

    def p(self,v):
        self.p00.setChecked(v)
        if v:
            set_reg(self.pid,0x70,1)        
        else:
            set_reg(self.pid,0x70,0)        

class Hist(Ui_HistBox):
    def __init__(self, box,pid,name):
        self.pid = pid
        self.pipe = box
        self.box = QtGui.QGroupBox(box.parentWidget())
        self.setupUi(self.box)
        self.pipe.addWidget(self.box)
        self.enable.stateChanged.connect(self.en)
        self.show.stateChanged.connect(self.sh)
        self.show_2.stateChanged.connect(self.sh2)
        self.verticalSlider.valueChanged.connect(self.val)
        self.en(0)
        self.box.setTitle(name)

    def en(self,v):
        self.enable.setChecked(v)
        if v:
            set_enable(self.pid,1)
        else:
            set_enable(self.pid,0)

    def sh(self,v):
        self.show.setChecked(v)
        if v > 0:
            v = 1
       
        set_reg(self.pid,0x70,v)        

    def sh2(self,v):
        self.show_2.setChecked(v)
        if v > 0:
            v = 1
        
        set_reg(self.pid,0x70,v<<1)



    def val(self,v):
        set_reg(self.pid,0x71,v)        

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
        self.enable.setChecked(v)
        if v:
            for i in range(0,20):
                set_enable(self.pid+i,1)
        else:
            for i in range(0,20):
                set_enable(self.pid+i,0)

    def th1_c(self,v):
        set_reg(self.pid+4,0x70,v)
    def th2_c(self,v):
        set_reg(self.pid+9,0x70,v)
    def th3_c(self,v):
        set_reg(self.pid+14,0x70,v)
    def th4_c(self,v):
        set_reg(self.pid+19,0x70,v)


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
        self.enable.setChecked(v)
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
    v = flReadChannel(handle, 5000, 0x62,2)
    set_reg(i,0x61,0)
    print "rd_id = " + str(v[0])
    if v[0] == 0x01:
        print "MCBFeed at " + str(i)
        t.append(Enable(ui.pipe,i,"MCBFeed"))
    if v[0] == 0x02:
        print "Skin at " + str(i)
        t.append(Enable(ui.pipe,i,"Skin")) 
    if v[0] == 0x03:
        print "Motion at " + str(i)
        t.append(Motion(ui.pipe,i)) 
    if v[0] == 0x04:
        print "Morph at " + str(i-4)
        t.append(Morph(ui.pipe,i-4))
        i = i + 16
    if v[0] == 0x05:
        print "HistX at " + str(i)
        t.append(Hist(ui.pipe,i,"HistX")) 
    if v[0] == 0x06:
        print "HistY at " + str(i)
        t.append(Hist(ui.pipe,i,"HistY")) 
    if v[0] == 0x07:
        print "MCBSink at " + str(i)
        t.append(Enable(ui.pipe,i,"MCBSink"))
    if v[0] == 0x08:
        print "ColMux at " + str(i)
        t.append(Enable(ui.pipe,i,"ColMux"))

    if v[0] == 0x0C:
        print "Translate at " + str(i)
        t.append(Enable(ui.pipe,i,"Translate"))

       
    i = i + 1
    if i > 31:
        break
QtCore.QObject.connect(ui.pushButton_exit, QtCore.SIGNAL("clicked()"), do_exit)


MainWindow.show()
r = app.exec_()
sys.exit(r)


