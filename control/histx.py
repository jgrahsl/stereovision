# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'histx.ui'
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

class Ui_HistXBox(object):
    def setupUi(self, HistXBox):
        HistXBox.setObjectName(_fromUtf8("HistXBox"))
        HistXBox.resize(116, 298)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(HistXBox.sizePolicy().hasHeightForWidth())
        HistXBox.setSizePolicy(sizePolicy)
        HistXBox.setMinimumSize(QtCore.QSize(116, 0))
        self.enable = QtGui.QCheckBox(HistXBox)
        self.enable.setGeometry(QtCore.QRect(10, 40, 93, 26))
        self.enable.setObjectName(_fromUtf8("enable"))

        self.retranslateUi(HistXBox)
        QtCore.QMetaObject.connectSlotsByName(HistXBox)

    def retranslateUi(self, HistXBox):
        HistXBox.setWindowTitle(QtGui.QApplication.translate("HistXBox", "GroupBox", None, QtGui.QApplication.UnicodeUTF8))
        HistXBox.setTitle(QtGui.QApplication.translate("HistXBox", "HistX", None, QtGui.QApplication.UnicodeUTF8))
        self.enable.setText(QtGui.QApplication.translate("HistXBox", "enable", None, QtGui.QApplication.UnicodeUTF8))

