# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'histy.ui'
#
# Created: Thu Jul 26 10:21:06 2012
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
        self.enable.setGeometry(QtCore.QRect(10, 40, 93, 26))
        self.enable.setObjectName(_fromUtf8("enable"))

        self.retranslateUi(HistYBox)
        QtCore.QMetaObject.connectSlotsByName(HistYBox)

    def retranslateUi(self, HistYBox):
        HistYBox.setWindowTitle(QtGui.QApplication.translate("HistYBox", "GroupBox", None, QtGui.QApplication.UnicodeUTF8))
        HistYBox.setTitle(QtGui.QApplication.translate("HistYBox", "HistY", None, QtGui.QApplication.UnicodeUTF8))
        self.enable.setText(QtGui.QApplication.translate("HistYBox", "enable", None, QtGui.QApplication.UnicodeUTF8))

