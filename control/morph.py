# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'morph.ui'
#
# Created: Mon Oct  8 20:37:55 2012
#      by: PyQt4 UI code generator 4.9.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_MorphBox(object):
    def setupUi(self, MorphBox):
        MorphBox.setObjectName(_fromUtf8("MorphBox"))
        MorphBox.resize(180, 280)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(MorphBox.sizePolicy().hasHeightForWidth())
        MorphBox.setSizePolicy(sizePolicy)
        MorphBox.setMinimumSize(QtCore.QSize(180, 0))
        self.horizontalLayoutWidget = QtGui.QWidget(MorphBox)
        self.horizontalLayoutWidget.setGeometry(QtCore.QRect(0, 20, 181, 231))
        self.horizontalLayoutWidget.setObjectName(_fromUtf8("horizontalLayoutWidget"))
        self.slides_2 = QtGui.QHBoxLayout(self.horizontalLayoutWidget)
        self.slides_2.setMargin(0)
        self.slides_2.setObjectName(_fromUtf8("slides_2"))
        self.morph_th_5 = QtGui.QSlider(self.horizontalLayoutWidget)
        self.morph_th_5.setMinimum(1)
        self.morph_th_5.setMaximum(21)
        self.morph_th_5.setPageStep(4)
        self.morph_th_5.setOrientation(QtCore.Qt.Vertical)
        self.morph_th_5.setInvertedAppearance(False)
        self.morph_th_5.setInvertedControls(False)
        self.morph_th_5.setTickPosition(QtGui.QSlider.TicksBelow)
        self.morph_th_5.setTickInterval(1)
        self.morph_th_5.setObjectName(_fromUtf8("morph_th_5"))
        self.slides_2.addWidget(self.morph_th_5)
        self.morph_th_6 = QtGui.QSlider(self.horizontalLayoutWidget)
        self.morph_th_6.setMinimum(1)
        self.morph_th_6.setMaximum(21)
        self.morph_th_6.setPageStep(4)
        self.morph_th_6.setOrientation(QtCore.Qt.Vertical)
        self.morph_th_6.setInvertedAppearance(False)
        self.morph_th_6.setInvertedControls(False)
        self.morph_th_6.setTickPosition(QtGui.QSlider.TicksBelow)
        self.morph_th_6.setTickInterval(1)
        self.morph_th_6.setObjectName(_fromUtf8("morph_th_6"))
        self.slides_2.addWidget(self.morph_th_6)
        self.morph_th_7 = QtGui.QSlider(self.horizontalLayoutWidget)
        self.morph_th_7.setMinimum(1)
        self.morph_th_7.setMaximum(21)
        self.morph_th_7.setPageStep(4)
        self.morph_th_7.setOrientation(QtCore.Qt.Vertical)
        self.morph_th_7.setInvertedAppearance(False)
        self.morph_th_7.setInvertedControls(False)
        self.morph_th_7.setTickPosition(QtGui.QSlider.TicksBelow)
        self.morph_th_7.setTickInterval(1)
        self.morph_th_7.setObjectName(_fromUtf8("morph_th_7"))
        self.slides_2.addWidget(self.morph_th_7)
        self.morph_th_8 = QtGui.QSlider(self.horizontalLayoutWidget)
        self.morph_th_8.setMinimum(1)
        self.morph_th_8.setMaximum(21)
        self.morph_th_8.setPageStep(4)
        self.morph_th_8.setOrientation(QtCore.Qt.Vertical)
        self.morph_th_8.setInvertedAppearance(False)
        self.morph_th_8.setInvertedControls(False)
        self.morph_th_8.setTickPosition(QtGui.QSlider.TicksBelow)
        self.morph_th_8.setTickInterval(1)
        self.morph_th_8.setObjectName(_fromUtf8("morph_th_8"))
        self.slides_2.addWidget(self.morph_th_8)
        self.enable = QtGui.QCheckBox(MorphBox)
        self.enable.setGeometry(QtCore.QRect(50, 250, 93, 26))
        self.enable.setObjectName(_fromUtf8("enable"))

        self.retranslateUi(MorphBox)
        QtCore.QMetaObject.connectSlotsByName(MorphBox)

    def retranslateUi(self, MorphBox):
        MorphBox.setWindowTitle(QtGui.QApplication.translate("MorphBox", "GroupBox", None, QtGui.QApplication.UnicodeUTF8))
        MorphBox.setTitle(QtGui.QApplication.translate("MorphBox", "Morph kernel", None, QtGui.QApplication.UnicodeUTF8))
        self.enable.setText(QtGui.QApplication.translate("MorphBox", "enabled", None, QtGui.QApplication.UnicodeUTF8))

