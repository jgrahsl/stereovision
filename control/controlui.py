# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'control.ui'
#
# Created: Fri Jul 20 19:33:10 2012
#      by: PyQt4 UI code generator 4.9.1
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName(_fromUtf8("MainWindow"))
        MainWindow.resize(800, 600)
        self.centralwidget = QtGui.QWidget(MainWindow)
        self.centralwidget.setObjectName(_fromUtf8("centralwidget"))
        self.enable = QtGui.QListWidget(self.centralwidget)
        self.enable.setGeometry(QtCore.QRect(60, 40, 221, 391))
        self.enable.setSelectionMode(QtGui.QAbstractItemView.NoSelection)
        self.enable.setObjectName(_fromUtf8("enable"))
        self.pushButton_exit = QtGui.QPushButton(self.centralwidget)
        self.pushButton_exit.setGeometry(QtCore.QRect(540, 50, 95, 31))
        self.pushButton_exit.setObjectName(_fromUtf8("pushButton_exit"))
        self.horizontalLayoutWidget = QtGui.QWidget(self.centralwidget)
        self.horizontalLayoutWidget.setGeometry(QtCore.QRect(330, 180, 281, 231))
        self.horizontalLayoutWidget.setObjectName(_fromUtf8("horizontalLayoutWidget"))
        self.slides = QtGui.QHBoxLayout(self.horizontalLayoutWidget)
        self.slides.setMargin(0)
        self.slides.setObjectName(_fromUtf8("slides"))
        self.morph_th = QtGui.QSlider(self.horizontalLayoutWidget)
        self.morph_th.setMinimum(1)
        self.morph_th.setMaximum(21)
        self.morph_th.setOrientation(QtCore.Qt.Vertical)
        self.morph_th.setInvertedAppearance(False)
        self.morph_th.setInvertedControls(False)
        self.morph_th.setTickPosition(QtGui.QSlider.TicksBelow)
        self.morph_th.setTickInterval(3)
        self.morph_th.setObjectName(_fromUtf8("morph_th"))
        self.slides.addWidget(self.morph_th)
        self.morph_th_2 = QtGui.QSlider(self.horizontalLayoutWidget)
        self.morph_th_2.setMinimum(1)
        self.morph_th_2.setMaximum(21)
        self.morph_th_2.setOrientation(QtCore.Qt.Vertical)
        self.morph_th_2.setInvertedAppearance(False)
        self.morph_th_2.setInvertedControls(False)
        self.morph_th_2.setTickPosition(QtGui.QSlider.TicksBelow)
        self.morph_th_2.setTickInterval(3)
        self.morph_th_2.setObjectName(_fromUtf8("morph_th_2"))
        self.slides.addWidget(self.morph_th_2)
        self.morph_th_3 = QtGui.QSlider(self.horizontalLayoutWidget)
        self.morph_th_3.setMinimum(1)
        self.morph_th_3.setMaximum(21)
        self.morph_th_3.setOrientation(QtCore.Qt.Vertical)
        self.morph_th_3.setInvertedAppearance(False)
        self.morph_th_3.setInvertedControls(False)
        self.morph_th_3.setTickPosition(QtGui.QSlider.TicksBelow)
        self.morph_th_3.setTickInterval(3)
        self.morph_th_3.setObjectName(_fromUtf8("morph_th_3"))
        self.slides.addWidget(self.morph_th_3)
        self.morph_th_4 = QtGui.QSlider(self.horizontalLayoutWidget)
        self.morph_th_4.setMinimum(1)
        self.morph_th_4.setMaximum(21)
        self.morph_th_4.setOrientation(QtCore.Qt.Vertical)
        self.morph_th_4.setInvertedAppearance(False)
        self.morph_th_4.setInvertedControls(False)
        self.morph_th_4.setTickPosition(QtGui.QSlider.TicksBelow)
        self.morph_th_4.setTickInterval(3)
        self.morph_th_4.setObjectName(_fromUtf8("morph_th_4"))
        self.slides.addWidget(self.morph_th_4)
        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtGui.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 800, 29))
        self.menubar.setObjectName(_fromUtf8("menubar"))
        MainWindow.setMenuBar(self.menubar)
        self.statusbar = QtGui.QStatusBar(MainWindow)
        self.statusbar.setObjectName(_fromUtf8("statusbar"))
        MainWindow.setStatusBar(self.statusbar)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        MainWindow.setWindowTitle(QtGui.QApplication.translate("MainWindow", "MainWindow", None, QtGui.QApplication.UnicodeUTF8))
        self.pushButton_exit.setText(QtGui.QApplication.translate("MainWindow", "Exit", None, QtGui.QApplication.UnicodeUTF8))

