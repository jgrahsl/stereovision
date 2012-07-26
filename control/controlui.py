# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'control.ui'
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

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName(_fromUtf8("MainWindow"))
        MainWindow.resize(1312, 424)
        self.centralwidget = QtGui.QWidget(MainWindow)
        self.centralwidget.setObjectName(_fromUtf8("centralwidget"))
        self.pushButton_exit = QtGui.QPushButton(self.centralwidget)
        self.pushButton_exit.setGeometry(QtCore.QRect(400, 340, 140, 31))
        self.pushButton_exit.setFlat(False)
        self.pushButton_exit.setObjectName(_fromUtf8("pushButton_exit"))
        self.horizontalLayoutWidget = QtGui.QWidget(self.centralwidget)
        self.horizontalLayoutWidget.setGeometry(QtCore.QRect(0, 0, 1311, 341))
        self.horizontalLayoutWidget.setObjectName(_fromUtf8("horizontalLayoutWidget"))
        self.pipe = QtGui.QHBoxLayout(self.horizontalLayoutWidget)
        self.pipe.setMargin(0)
        self.pipe.setObjectName(_fromUtf8("pipe"))
        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtGui.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 1312, 29))
        self.menubar.setObjectName(_fromUtf8("menubar"))
        MainWindow.setMenuBar(self.menubar)
        self.statusbar = QtGui.QStatusBar(MainWindow)
        self.statusbar.setObjectName(_fromUtf8("statusbar"))
        MainWindow.setStatusBar(self.statusbar)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        MainWindow.setWindowTitle(QtGui.QApplication.translate("MainWindow", "MainWindow", None, QtGui.QApplication.UnicodeUTF8))
        self.pushButton_exit.setText(QtGui.QApplication.translate("MainWindow", "EXIT", None, QtGui.QApplication.UnicodeUTF8))

