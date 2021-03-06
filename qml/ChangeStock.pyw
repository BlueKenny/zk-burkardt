#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os

from libs.appjar0900 import gui
from libs.RoundUp import *
from libs.debug import Debug
from libs.BlueFunc import *
from libs.send import *
from libs.barcode import *
import platform
import sys


EntryList=["Barcode", "Artikel", "Artikel2", "Artikel3", "Lieferant", "Name", "Ort", "PreisEK", "PreisVKH", "PreisVK", "Grösse"]

if len(sys.argv) == 1:
    ID = StockSetBCode()
    IDExists = False
else:
    ID = sys.argv[1]
    IDExists = True

def Save():
    global DATA
    print("Save")
    DATA["name_de"] = appChange.getEntry("Name")
    DATA["lieferant"] = appChange.getEntry("Lieferant")
    DATA["artikel"] = appChange.getEntry("Artikel")
    DATA["artikel2"] = appChange.getEntry("Artikel2")
    DATA["artikel3"] = appChange.getEntry("Artikel3")
    DATA["artikel4"] = appChange.getEntry("Artikel4")
    DATA["preisek"] = appChange.getEntry("Einkaufspreis")
    DATA["preisvkh"] = appChange.getEntry("Verkaufspreis HTVA")
    DATA["preisvk"] = appChange.getEntry("Verkaufspreis TVAC")
    DATA["barcode"] = appChange.getEntry("Barcode")
    DATA["ort"] = appChange.getEntry("Ort")
    DATA["minimum"] = appChange.getEntry("Minimum")
    DATA["groesse"] = appChange.getEntry("Grösse")
    
    if not GetArt(ID)["lastchange"] == DATA["lastchange"] and not PID:
        appChange.infoBox("Achtung", "Dieser Artikel wurde gerade von einem anderen ort aus geändert", parent=None)
        return False
    else:
        print("Send Data to Server")
        if SetArt(DATA):
            return True
        else:
            appChange.infoBox("Achtung", "Artikel konnte nicht gespeichert werden", parent=None)
            return False

def VerifyInputFloat(Entry):
    print("VerifyInputFloat")
    print("Verify this input " + str(appChange.getEntry(Entry)))
    myFloat = appChange.getEntry(Entry)
    myFloat = myFloat.replace(",", ".")
    myFloat = myFloat.replace("..", ".")
    myFloat = myFloat.replace(".0.", ".")
    try:
        if Entry == "Minimum":
            print("Minimum")
            myFloat = float(myFloat)
        if Entry == "Einkaufspreis":
            print("Einkaufspreis")
            myFloat = RoundUp0000(myFloat)
            myFloat = float(myFloat)
        if Entry == "Verkaufspreis HTVA":
            print("Verkaufspreis HTVA")
            myFloat = RoundUp0000(myFloat)
            appChange.setEntry("Verkaufspreis TVAC", RoundUp05(myFloat*1.21), callFunction=False)
            myFloat = RoundUp0000(float(appChange.getEntry("Verkaufspreis TVAC"))/1.21)
            myFloat = float(myFloat)
        if Entry == "Verkaufspreis TVAC":
            print("Verkaufspreis TVAC")
            myFloat = RoundUp05(myFloat)
            appChange.setEntry("Verkaufspreis HTVA", RoundUp0000(myFloat/1.2100), callFunction=False)
            myFloat = RoundUp05(float(appChange.getEntry("Verkaufspreis HTVA"))*1.21)
            myFloat = float(myFloat)
    except:
        myFloat = 0.0
    appChange.setEntry(Entry, myFloat)


def VerifyInputInt(Entry):
    print("VerifyInputInt")
    print("Verify this input " + str(appChange.getEntry(Entry)))
    myInt = appChange.getEntry(Entry)
    appChange.setEntryMaxLength(Entry, 13)
    try:
        appChange.setEntry(Entry, int(myInt))
        if Entry == "Barcode":
            if not len(appChange.getEntry(Entry)) == 13:
                appChange.setEntry(Entry, IDToBarcode(ID))
                appChange.infoBox("Achtung", "Dieser Barcode ist ungültig und wird jetzt neu generiert")
    except:
        if Entry == "Barcode":
            appChange.setEntry(Entry, IDToBarcode(ID))
        else:
            appChange.setEntry(Entry, "0")

def VerifyInputChar(Entry):
    print("VerifyInputChar")
    print("Verify this input " + str(appChange.getEntry(Entry)))
    appChange.setEntry(Entry, appChange.getEntry(Entry).replace("?", ""))

    if Entry == "Ort":
        myString = appChange.getEntry(Entry).upper()
        myString = myString.replace(",", ".")
        myString = myString.replace(" ", "")
        appChange.setEntry(Entry, myString)

    if Entry == "Artikel" or Entry == "Artikel2" or Entry == "Artikel3" or Entry == "Artikel4" or Entry == "Lieferant":
        myString = appChange.getEntry(Entry).upper()
        EndString = ""
        for character in myString:
            if character.isalpha() or character.isdigit():
                EndString = EndString + str(character)

        appChange.setEntry(Entry, EndString)


def VerifyChanges():
    print("VerifyChanges")
    UserMadeChanges = True
    ID = appChange.getLabel("Title")
    if UserMadeChanges:
        if appChange.yesNoBox("Speichern", "Wollen sie speichern?", parent=None):
            if Save():
                BlueSave("LastID", ID, "DATA/DATA")
                return True
            else:
                appChange.infoBox("Speichern", "änderungen wurden nicht gespeichert", parent=None)
                return False
        else:
            BlueSave("LastID", "None", "DATA/DATA")
            return True

def BtnStockGraph(btn):
    if platform.system() == "Linux": COMMAND = "./ArtGraph.py "
    if platform.system() == "Windows": COMMAND = "ArtGraph.py "
    os.system(COMMAND + str(ID))

DATA = GetArt(ID)

if "P" in ID:
    print("Öffne preisvorschlag")
    PID = ID
    while True:
        try:
            NewData = GetID()
            DATA["identification"] = NewData["identification"]
            DATA["barcode"] = NewData["barcode"]
            break
        except: True
else: PID = False

if platform.system() == "Linux": COMMAND = "./ArtGraph.py "
if platform.system() == "Windows": COMMAND = "ArtGraph.py "
#os.system(COMMAND + str(ID))

appChange = gui("Stock ändern", "800x600", handleArgs=False)
appChange.setBg("#3399ff")
appChange.addLabel("Title", str(DATA["identification"]), 0, 0, 5, 0)

appChange.addLabelEntry("Name", 1, 0, 2, 0)
appChange.setEntryChangeFunction("Name", VerifyInputChar)
appChange.setEntry("Name", DATA["name_de"])
appChange.setFocus("Name")

appChange.addLabelEntry("Lieferant", 1, 3, 2, 0)
appChange.setEntryChangeFunction("Lieferant", VerifyInputChar)
DATA["lieferant"] = DATA["lieferant"].split("_")[0]
appChange.setEntry("Lieferant", DATA["lieferant"])

appChange.addLabel("leer1", "", 2, 0, 2, 0)

appChange.addLabelEntry("Artikel", 3, 0, 2, 0)
appChange.setEntryChangeFunction("Artikel", VerifyInputChar)
appChange.setEntry("Artikel", DATA["artikel"])

appChange.addLabelEntry("Artikel2", 3, 3, 2, 0)
appChange.setEntryChangeFunction("Artikel2", VerifyInputChar)
appChange.setEntry("Artikel2", DATA["artikel2"])

appChange.addLabelEntry("Artikel3", 4, 0, 2, 0)
appChange.setEntryChangeFunction("Artikel3", VerifyInputChar)
appChange.setEntry("Artikel3", DATA["artikel3"])

appChange.addLabelEntry("Artikel4", 4, 3, 2, 0)
appChange.setEntryChangeFunction("Artikel4", VerifyInputChar)
appChange.setEntry("Artikel4", DATA["artikel4"])

appChange.addLabel("leer2", "", 5, 0, 2, 0)

appChange.addLabelEntry("Einkaufspreis", 6, 0, 2, 0)
appChange.setEntryChangeFunction("Einkaufspreis", VerifyInputFloat)
appChange.setEntry("Einkaufspreis", DATA["preisek"])

appChange.addLabelEntry("Verkaufspreis HTVA", 7, 0, 2, 0)
appChange.setEntryChangeFunction("Verkaufspreis HTVA", VerifyInputFloat)
appChange.setEntry("Verkaufspreis HTVA", DATA["preisvkh"])

appChange.addLabelEntry("Verkaufspreis TVAC", 7, 3, 2, 0)
appChange.setEntryChangeFunction("Verkaufspreis TVAC", VerifyInputFloat)
appChange.setEntry("Verkaufspreis TVAC", DATA["preisvk"])


appChange.addLabel("leer3", "", 8, 0, 2, 0)

appChange.addLabelEntry("Barcode", 9, 0, 2, 0)
appChange.setEntryChangeFunction("Barcode", VerifyInputInt)
appChange.setEntry("Barcode", DATA["barcode"])
appChange.setEntryState("Barcode", "disabled")

appChange.addLabelEntry("Ort", 9, 3, 2, 0)
appChange.setEntryChangeFunction("Ort", VerifyInputChar)
appChange.setEntry("Ort", DATA["ort"])

appChange.addLabelEntry("Minimum", 10, 0, 2, 0)
appChange.setEntryChangeFunction("Minimum", VerifyInputFloat)
appChange.setEntry("Minimum", DATA["minimum"])

appChange.addLabelEntry("Grösse", 10, 3, 2, 0)
appChange.setEntryChangeFunction("Grösse", VerifyInputFloat)
appChange.setEntry("Grösse", DATA["groesse"])

def StopWindow(btn):
    Debug("StopWindow")
    appChange.stop()

appChange.setStopFunction(VerifyChanges)
appChange.addLabel("Info", "F5 = Speichern und Schliesen", 15, 0, 5, 0)
appChange.bindKey("<F5>", StopWindow)
appChange.go()

