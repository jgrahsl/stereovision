#!/usr/bin/python

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
    flWriteChannel(handle, 1000, chan,ba)

def set_pipe(n):
    send_byte(0x60,n)

def set_enable(adr,en):
    set_pipe(adr)
    send_byte(0x61,en)

def set_reg(adr,reg,en):
    print "Set pipe " + str(adr) + " reg " + str(reg) + " to " + str(en)
    set_pipe(adr)
    send_byte(reg,en)


vp = "1443:0007"
flLoadStandardFirmware(vp, vp, "D0234")                # 1443:0007 for Nexys3 & Atlys
flAwaitDevice(vp, 600)
handle = flOpen(vp)                                             # Open the connection
#flPortAccess(handle, 0x0080, 0x0080)                                     # Skip this for Nexys3 & Atlys
flPlayXSVF(handle, "/home/julian/cam/top.xsvf")  # Or other SVF, XSVF or CSVF


app = QtGui.QApplication(sys.argv)
MainWindow = QtGui.QMainWindow(None)
ui = Ui_MainWindow()
ui.setupUi(MainWindow)


def add_item(s):
    t = QtGui.QListWidgetItem(s)
    t.setFlags(t.flags() | QtCore.Qt.ItemIsUserCheckable)
    t.setCheckState(QtCore.Qt.Unchecked)
    ui.enable.addItem(t)

def add_morph():
    add_item("Morph: 1d")
    add_item("Morph: 2d")
    add_item("Morph: kernel")


add_item("Skin")
add_item("Hist")
add_item("Motion")
add_morph()
add_morph()
add_morph()
add_morph()

def do_exit():
    global handle

    flClose(handle)
    app.exit(0)

def clicked(item):
    en = 0
    if item.checkState() == QtCore.Qt.Checked:
        en = 1

    set_enable(ui.enable.row(item),en)

QtCore.QObject.connect(ui.pushButton_exit, QtCore.SIGNAL("clicked()"), do_exit)
ui.enable.itemClicked.connect(clicked)

def th1_c(v):
    set_reg(5,0x70,v)
def th2_c(v):
    set_reg(8,0x70,v)
def th3_c(v):
    set_reg(11,0x70,v)
def th4_c(v):
    set_reg(14,0x70,v)

ui.morph_th.valueChanged.connect(th1_c)
ui.morph_th_2.valueChanged.connect(th2_c)
ui.morph_th_3.valueChanged.connect(th3_c)
ui.morph_th_4.valueChanged.connect(th4_c)

for i in range(0,16):
    set_enable(i,0)

MainWindow.show()
r = app.exec_()
sys.exit(r)

