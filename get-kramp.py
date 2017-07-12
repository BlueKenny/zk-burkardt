#!/usr/bin/env python3
#import convert
from BlueVar import *
import os
import sys
from debug import *
from RoundUp import *
from keybinder import *


title = "kramp"

DataFile = title + "Data"
DataPfad = title + "-data/"
DataPreis = title + "-preis/"


if not os.path.exists(DataPfad): os.mkdir(DataPfad)
if not os.path.exists(DataPreis): os.mkdir(DataPreis)

#for x in os.listdir(DataPreis): os.remove(DataPreis + x)

# http://pyautogui.readthedocs.io/en/latest/cheatsheet.html

Debug(" ")

for file in os.listdir("text/"):
	Debug("Datei " + file)

	DataRechnung = open("text/" + file, "r").read()
	Begin = open(DataPfad + "Begin").read()
	Debug("Begin : " + Begin)
	End = open(DataPfad + "End").read()
	Debug("End : " + End)
	DataRechnung = DataRechnung.split(Begin)[1]
	DataRechnung = DataRechnung.split(End)[0]

	for Linie in DataRechnung.split("\n"):
		if not Linie.rstrip() == "":
			Worte = Linie.split(" ")
		

			Debug(" ")
			Debug("Linie : " + Linie)
			Art = Worte[1]
			Debug("Art : " + Art)
			Filepath = DataPreis + Art
			Debug("Filepath : " + Filepath)
			Anzahl = Worte[len(Worte)-5]
			Debug("Anzahl : " + Anzahl)
			PreisVKH = Worte[len(Worte)-2]
			PreisVKH = PreisVKH.replace(",", ".")
			Debug("PreisVKH : " + PreisVKH)
			Name = Linie.split(Worte[0] + " " + Worte[1] + " ")[1]
			Name = Name.split(" " + Worte[len(Worte)-6] + " " + Worte[len(Worte)-5] + " " + Worte[len(Worte)-4] + " " + Worte[len(Worte)-3] + " " + Worte[len(Worte)-2] + " " + Worte[len(Worte)-1])[0]
			Debug("Name : " + Name)
			
			PreisVK = float(PreisVKH) * 1.2100
			Debug("PreisVK : " + str(PreisVK))
			PreisEK = float(PreisVKH) * 0.7500
			Debug("PreisEK : " + str(PreisEK))
			
			BlueSave("Name", Name, Filepath)
			BlueSave("Anzahl", Anzahl, Filepath)
			BlueSave("PreisVKH", PreisVKH, Filepath)
			BlueSave("PreisVK", RoundUp05(PreisVK), Filepath)
			BlueSave("PreisEK", PreisEK, Filepath)

# Start HERE
#Key("F11")
#Maus(4,5)

#input("\nFertig")