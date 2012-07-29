# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'skin.ui'
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

class Ui_SkinBox(object):
    def setupUi(self, SkinBox):
        SkinBox.setObjectName(_fromUtf8("SkinBox"))
        SkinBox.resize(116, 298)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(SkinBox.sizePolicy().hasHeightForWidth())
        SkinBox.setSizePolicy(sizePolicy)
        SkinBox.setMinimumSize(QtCore.QSize(116, 0))
        self.enable = QtGui.QCheckBox(SkinBox)
        self.enable.setGeometry(QtCore.QRect(10, 40, 93, 26))
        self.enable.setObjectName(_fromUtf8("enable"))

        self.retranslateUi(SkinBox)
        QtCore.QMetaObject.connectSlotsByName(SkinBox)

    def retranslateUi(self, SkinBox):
        SkinBox.setWindowTitle(QtGui.QApplication.translate("SkinBox", "GroupBox", None, QtGui.QApplication.UnicodeUTF8))
        SkinBox.setTitle(QtGui.QApplication.translate("SkinBox", "SkinBox", None, QtGui.QApplication.UnicodeUTF8))
        self.enable.setText(QtGui.QApplication.translate("SkinBox", "enable", None, QtGui.QApplication.UnicodeUTF8))

