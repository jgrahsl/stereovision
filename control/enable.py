# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'enable.ui'
#
# Created: Sun Jul 29 17:18:41 2012
#      by: PyQt4 UI code generator 4.9.1
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_EnableBox(object):
    def setupUi(self, EnableBox):
        EnableBox.setObjectName(_fromUtf8("EnableBox"))
        EnableBox.resize(116, 298)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(EnableBox.sizePolicy().hasHeightForWidth())
        EnableBox.setSizePolicy(sizePolicy)
        EnableBox.setMinimumSize(QtCore.QSize(116, 0))
        self.enable = QtGui.QCheckBox(EnableBox)
        self.enable.setGeometry(QtCore.QRect(10, 40, 93, 26))
        self.enable.setObjectName(_fromUtf8("enable"))

        self.retranslateUi(EnableBox)
        QtCore.QMetaObject.connectSlotsByName(EnableBox)

    def retranslateUi(self, EnableBox):
        EnableBox.setWindowTitle(QtGui.QApplication.translate("EnableBox", "GroupBox", None, QtGui.QApplication.UnicodeUTF8))
        EnableBox.setTitle(QtGui.QApplication.translate("EnableBox", "EnableBox", None, QtGui.QApplication.UnicodeUTF8))
        self.enable.setText(QtGui.QApplication.translate("EnableBox", "enable", None, QtGui.QApplication.UnicodeUTF8))
