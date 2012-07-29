# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'colmux.ui'
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

class Ui_ColMuxBox(object):
    def setupUi(self, ColMuxBox):
        ColMuxBox.setObjectName(_fromUtf8("ColMuxBox"))
        ColMuxBox.resize(116, 298)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(ColMuxBox.sizePolicy().hasHeightForWidth())
        ColMuxBox.setSizePolicy(sizePolicy)
        ColMuxBox.setMinimumSize(QtCore.QSize(116, 0))
        self.enable = QtGui.QCheckBox(ColMuxBox)
        self.enable.setGeometry(QtCore.QRect(10, 40, 93, 26))
        self.enable.setObjectName(_fromUtf8("enable"))

        self.retranslateUi(ColMuxBox)
        QtCore.QMetaObject.connectSlotsByName(ColMuxBox)

    def retranslateUi(self, ColMuxBox):
        ColMuxBox.setWindowTitle(QtGui.QApplication.translate("ColMuxBox", "GroupBox", None, QtGui.QApplication.UnicodeUTF8))
        ColMuxBox.setTitle(QtGui.QApplication.translate("ColMuxBox", "ColMux", None, QtGui.QApplication.UnicodeUTF8))
        self.enable.setText(QtGui.QApplication.translate("ColMuxBox", "enable", None, QtGui.QApplication.UnicodeUTF8))

