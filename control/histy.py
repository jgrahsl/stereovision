# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'histy.ui'
#
# Created: Sun Jul 29 14:31:00 2012
#      by: PyQt4 UI code generator 4.9.1
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_HistYBox(object):
    def setupUi(self, HistYBox):
        HistYBox.setObjectName(_fromUtf8("HistYBox"))
        HistYBox.resize(116, 298)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(HistYBox.sizePolicy().hasHeightForWidth())
        HistYBox.setSizePolicy(sizePolicy)
        HistYBox.setMinimumSize(QtCore.QSize(116, 0))
        self.enable = QtGui.QCheckBox(HistYBox)
        self.enable.setGeometry(QtCore.QRect(10, 260, 93, 26))
        self.enable.setObjectName(_fromUtf8("enable"))
        self.verticalSlider = QtGui.QSlider(HistYBox)
        self.verticalSlider.setGeometry(QtCore.QRect(40, 72, 19, 159))
        self.verticalSlider.setMaximum(255)
        self.verticalSlider.setPageStep(16)
        self.verticalSlider.setOrientation(QtCore.Qt.Vertical)
        self.verticalSlider.setTickPosition(QtGui.QSlider.TicksBothSides)
        self.verticalSlider.setTickInterval(16)
        self.verticalSlider.setObjectName(_fromUtf8("verticalSlider"))
        self.label = QtGui.QLabel(HistYBox)
        self.label.setGeometry(QtCore.QRect(20, 232, 66, 20))
        self.label.setObjectName(_fromUtf8("label"))
        self.show = QtGui.QCheckBox(HistYBox)
        self.show.setGeometry(QtCore.QRect(10, 30, 93, 26))
        self.show.setObjectName(_fromUtf8("show"))

        self.retranslateUi(HistYBox)
        QtCore.QMetaObject.connectSlotsByName(HistYBox)

    def retranslateUi(self, HistYBox):
        HistYBox.setWindowTitle(QtGui.QApplication.translate("HistYBox", "GroupBox", None, QtGui.QApplication.UnicodeUTF8))
        HistYBox.setTitle(QtGui.QApplication.translate("HistYBox", "HistY", None, QtGui.QApplication.UnicodeUTF8))
        self.enable.setText(QtGui.QApplication.translate("HistYBox", "enable", None, QtGui.QApplication.UnicodeUTF8))
        self.label.setText(QtGui.QApplication.translate("HistYBox", "threshold", None, QtGui.QApplication.UnicodeUTF8))
        self.show.setText(QtGui.QApplication.translate("HistYBox", "show", None, QtGui.QApplication.UnicodeUTF8))

