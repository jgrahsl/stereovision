# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'mcbfeed.ui'
#
# Created: Thu Jul 26 16:24:05 2012
#      by: PyQt4 UI code generator 4.9.1
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_MCBFeedBox(object):
    def setupUi(self, MCBFeedBox):
        MCBFeedBox.setObjectName(_fromUtf8("MCBFeedBox"))
        MCBFeedBox.resize(116, 298)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(MCBFeedBox.sizePolicy().hasHeightForWidth())
        MCBFeedBox.setSizePolicy(sizePolicy)
        MCBFeedBox.setMinimumSize(QtCore.QSize(116, 0))
        self.enable = QtGui.QCheckBox(MCBFeedBox)
        self.enable.setGeometry(QtCore.QRect(10, 40, 93, 26))
        self.enable.setObjectName(_fromUtf8("enable"))

        self.retranslateUi(MCBFeedBox)
        QtCore.QMetaObject.connectSlotsByName(MCBFeedBox)

    def retranslateUi(self, MCBFeedBox):
        MCBFeedBox.setWindowTitle(QtGui.QApplication.translate("MCBFeedBox", "GroupBox", None, QtGui.QApplication.UnicodeUTF8))
        MCBFeedBox.setTitle(QtGui.QApplication.translate("MCBFeedBox", "MCBFeed", None, QtGui.QApplication.UnicodeUTF8))
        self.enable.setText(QtGui.QApplication.translate("MCBFeedBox", "enable", None, QtGui.QApplication.UnicodeUTF8))

