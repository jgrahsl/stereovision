# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'mcbsink.ui'
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

class Ui_MCBSinkBox(object):
    def setupUi(self, MCBSinkBox):
        MCBSinkBox.setObjectName(_fromUtf8("MCBSinkBox"))
        MCBSinkBox.resize(116, 298)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(MCBSinkBox.sizePolicy().hasHeightForWidth())
        MCBSinkBox.setSizePolicy(sizePolicy)
        MCBSinkBox.setMinimumSize(QtCore.QSize(116, 0))
        self.enable = QtGui.QCheckBox(MCBSinkBox)
        self.enable.setGeometry(QtCore.QRect(10, 40, 93, 26))
        self.enable.setObjectName(_fromUtf8("enable"))

        self.retranslateUi(MCBSinkBox)
        QtCore.QMetaObject.connectSlotsByName(MCBSinkBox)

    def retranslateUi(self, MCBSinkBox):
        MCBSinkBox.setWindowTitle(QtGui.QApplication.translate("MCBSinkBox", "GroupBox", None, QtGui.QApplication.UnicodeUTF8))
        MCBSinkBox.setTitle(QtGui.QApplication.translate("MCBSinkBox", "MCBSink", None, QtGui.QApplication.UnicodeUTF8))
        self.enable.setText(QtGui.QApplication.translate("MCBSinkBox", "enable", None, QtGui.QApplication.UnicodeUTF8))

