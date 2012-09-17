# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'hist.ui'
#
# Created: Mon Sep 17 22:15:18 2012
#      by: PyQt4 UI code generator 4.9.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_HistBox(object):
    def setupUi(self, HistBox):
        HistBox.setObjectName(_fromUtf8("HistBox"))
        HistBox.resize(116, 298)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(HistBox.sizePolicy().hasHeightForWidth())
        HistBox.setSizePolicy(sizePolicy)
        HistBox.setMinimumSize(QtCore.QSize(116, 0))
        self.enable = QtGui.QCheckBox(HistBox)
        self.enable.setGeometry(QtCore.QRect(10, 260, 93, 26))
        self.enable.setObjectName(_fromUtf8("enable"))
        self.verticalSlider = QtGui.QSlider(HistBox)
        self.verticalSlider.setGeometry(QtCore.QRect(40, 72, 19, 159))
        self.verticalSlider.setMaximum(255)
        self.verticalSlider.setPageStep(16)
        self.verticalSlider.setOrientation(QtCore.Qt.Vertical)
        self.verticalSlider.setTickPosition(QtGui.QSlider.TicksBothSides)
        self.verticalSlider.setTickInterval(16)
        self.verticalSlider.setObjectName(_fromUtf8("verticalSlider"))
        self.label = QtGui.QLabel(HistBox)
        self.label.setGeometry(QtCore.QRect(20, 232, 66, 20))
        self.label.setObjectName(_fromUtf8("label"))
        self.show = QtGui.QCheckBox(HistBox)
        self.show.setGeometry(QtCore.QRect(10, 20, 93, 26))
        self.show.setObjectName(_fromUtf8("show"))
        self.show_2 = QtGui.QCheckBox(HistBox)
        self.show_2.setGeometry(QtCore.QRect(10, 40, 93, 26))
        self.show_2.setObjectName(_fromUtf8("show_2"))

        self.retranslateUi(HistBox)
        QtCore.QMetaObject.connectSlotsByName(HistBox)

    def retranslateUi(self, HistBox):
        HistBox.setWindowTitle(QtGui.QApplication.translate("HistBox", "GroupBox", None, QtGui.QApplication.UnicodeUTF8))
        HistBox.setTitle(QtGui.QApplication.translate("HistBox", "Hist", None, QtGui.QApplication.UnicodeUTF8))
        self.enable.setText(QtGui.QApplication.translate("HistBox", "enable", None, QtGui.QApplication.UnicodeUTF8))
        self.label.setText(QtGui.QApplication.translate("HistBox", "threshold", None, QtGui.QApplication.UnicodeUTF8))
        self.show.setText(QtGui.QApplication.translate("HistBox", "show", None, QtGui.QApplication.UnicodeUTF8))
        self.show_2.setText(QtGui.QApplication.translate("HistBox", "show2", None, QtGui.QApplication.UnicodeUTF8))

