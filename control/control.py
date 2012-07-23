#!/usr/bin/python
from sip import *
import sip
from controlui import *
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
    xsvfFile = "/home/julian/cam/top.xsvf"
    print "Playing \"%s\" into the JTAG chain on FPGALink device %s..." % (xsvfFile, vp)
    flPlayXSVF(handle, xsvfFile)  # Or other SVF, XSVF or CSVF

set_reg(0,0,0)

app = QtGui.QApplication(sys.argv)
MainWindow = QtGui.QMainWindow(None)
ui = Ui_MainWindow()
ui.setupUi(MainWindow)


def add_item(s):
    t = QtGui.QListWidgetItem(s)
    t.setFlags(t.flags() | QtCore.Qt.ItemIsUserCheckable)
    t.setCheckState(QtCore.Qt.Unchecked)
    ui.enable.addItem(t)
    r = ui.enable.row(t)
    set_enable(r,0)
    return r

def add_morph():
    global morph
    add_item("Morph: 1d")
    add_item("Morph: 2d")
    t = add_item("Morph: kernel")
    morph.append(t)





morph = []
motion = 0
#############################

add_item("Head")
add_item("Feed")
add_item("Skin")
motion = add_item("Motion")
add_morph()
add_morph()
add_morph()
add_morph()
add_item("Hist_X")
add_item("Hist_Y")


def do_exit():
    global handle

    flClose(handle)
    app.exit(0)

def clicked(item):
    en = 0
    if item.checkState() == QtCore.Qt.Checked:
        en = 1

    set_enable(ui.enable.row(item),en)

def th1_c(v):
    set_reg(morph[0],0x70,v)
def th2_c(v):
    set_reg(morph[1],0x70,v)
def th3_c(v):
    set_reg(morph[2],0x70,v)
def th4_c(v):
    set_reg(morph[3],0x70,v)

ui.morph_th.valueChanged.connect(th1_c)
ui.morph_th_2.valueChanged.connect(th2_c)
ui.morph_th_3.valueChanged.connect(th3_c)
ui.morph_th_4.valueChanged.connect(th4_c)
QtCore.QObject.connect(ui.pushButton_exit, QtCore.SIGNAL("clicked()"), do_exit)
ui.enable.itemClicked.connect(clicked)
ui.enable.itemChanged.connect(clicked)


def radio(c):
    if ui.radioButton.isChecked():
        set_reg(motion,0x075,0)
    if ui.radioButton_2.isChecked():
        set_reg(motion,0x075,4)
    if ui.radioButton_3.isChecked():
        set_reg(motion,0x075,2)
    if ui.radioButton_4.isChecked():
        set_reg(motion,0x075,1)
    if ui.radioButton_5.isChecked():
        set_reg(motion,0x075,3)

ui.radioButton.toggled.connect(radio)
ui.radioButton_2.toggled.connect(radio)
ui.radioButton_3.toggled.connect(radio)
ui.radioButton_4.toggled.connect(radio)
ui.radioButton_5.toggled.connect(radio)


def motion_c(v):
    set_reg(motion,0x70,ui.motion_p01.value()%256)
    set_reg(motion,0x71,ui.motion_p01.value()/256)
    set_reg(motion,0x72,ui.motion_p23.value()%256)
    set_reg(motion,0x73,ui.motion_p23.value()/256)
    set_reg(motion,0x74,ui.motion_p4.value())

ui.motion_p01.valueChanged.connect(motion_c)
ui.motion_p23.valueChanged.connect(motion_c)
ui.motion_p4.valueChanged.connect(motion_c)

def preset_1():
    set_reg(morph[0],0x70,21)
    set_reg(morph[1],0x70,12)
    set_reg(morph[2],0x70,12)
    set_reg(morph[3],0x70,12)

    set_enable(morph[0],1)
    set_enable(morph[1],1)
    set_enable(morph[2],1)
    set_enable(morph[3],1)
def preset_2():

    set_enable(morph[0],0)
    set_enable(morph[1],0)
    set_enable(morph[2],0)
    set_enable(morph[3],0)


ui.preset_1.clicked.connect(preset_1)
ui.preset_2.clicked.connect(preset_2)
#ui.preset_3.clicked.connect(preset_3)
#ui.preset_4.clicked.connect(preset_4)



#f = open("w.dat")
#s = f.read()
#qi = QtGui.QImage(s,640/128,480, QtGui.QImage.Format_RGB888);
#ui.label_pic.setPixmap(QtGui.QPixmap.fromImage(qi));

#myLabel.show();


MainWindow.show()
r = app.exec_()
sys.exit(r)

