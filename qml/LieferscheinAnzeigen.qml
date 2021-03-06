import QtQuick 2.2
import io.thp.pyotherside 1.2
import QtQuick.Controls 1.1//2.0


Rectangle {
    id: window
    width: mainWindow.width
    height: mainWindow.height

    Item {
        id: variable
        property int listeIndex: 0
        property bool switchFinishChecked: false
    }

    function antwortGetLieferschein(item, summe, fertig, kunde_id, kunde_name) {
        //console.warn("antwortGetLieferschein")
        //variable.listeIndex = liste.currentIndex
        //console.warn("Current Index: " + variable.listeIndex)
        contactModel.clear();
        for (var i=0; i<item.length; i++) {
            contactModel.append(item[i]);
        }
        if (variable.listeIndex == -1) { variable.listeIndex = 0 }
        liste.currentIndex = liste.count - 1//variable.listeIndex
        labelTotal.text = summe
        variable.switchFinishChecked = fertig
        switchFinish.text = variable.switchFinishChecked ? "Fertig" : "Nicht Fertig"
        textLieferscheinAnzeigenKundeID.text = kunde_id
        labelLieferscheinAnzeigenKundeName.text = kunde_name
    }

    Label {
        id: labelLieferscheinAnzeigenTitle
        text: "Lieferschein: "
        font.pixelSize: vars.isPhone ? mainWindow.width / 20 : mainWindow.width / 50
        x: mainWindow.width / 2 - width / 2
    }

    Label {
        id: labelLieferscheinAnzeigenKundeID
        text: "Kunde : "
        font.pixelSize: vars.isPhone ? mainWindow.width / 20 : mainWindow.width / 50
        x: mainWindow.width / 10 * 7 - width / 2
    }
    Button {
        text: "X"
        y: labelLieferscheinAnzeigenKundeID.y
        x: labelLieferscheinAnzeigenKundeID.x + labelLieferscheinAnzeigenKundeID.width
        onClicked: {
            textLieferscheinAnzeigenKundeID.text = ""
        }
    }
    TextField {
        id: textLieferscheinAnzeigenKundeID
        text: vars.lieferscheinAnzeigenKundeID
        font.pixelSize: vars.isPhone ? mainWindow.width / 20 : mainWindow.width / 50
        x: mainWindow.width / 10 * 8
        width: mainWindow.width / 5
        MouseArea {
            anchors.fill: textLieferscheinAnzeigenKundeID
            onClicked: {
                vars.kundenSuchenVorherigeAnsicht = "frameLieferscheinAnzeigen"
                view.push(frameKundenSuchen)
            }
        }
        onTextChanged: {
            python.call('LieferscheinAnzeigen.main.SetKunde', [text], function(kunde_name) {labelLieferscheinAnzeigenKundeName.text = kunde_name});
        }
    }
    Text {
        id: labelLieferscheinAnzeigenKundeName
        text: ""
        font.pixelSize: vars.isPhone ? mainWindow.width / 20 : mainWindow.width / 50
        x: mainWindow.width / 10 * 8
        y: textLieferscheinAnzeigenKundeID.y + textLieferscheinAnzeigenKundeID.height
        width: mainWindow.width / 5
    }

    Label {
        id: labelTitle1
        text: "Anzahl"
        font.pixelSize: labelLieferscheinAnzeigenTitle.font.pixelSize
        x: window.width / 10 - width / 2//window.width / 5 - width / 2
        y: window.height / 10
    }
    Label {
        id: labelTitle2
        text: "Barcode"
        font.pixelSize: labelLieferscheinAnzeigenTitle.font.pixelSize
        x: labelTitle1.x + labelTitle1.width + mainWindow.width / 20//window.width / 5 * 2 - width / 2
        y: window.height / 10
    }
    Label {
        id: labelTitle3
        text: "Name"
        font.pixelSize: labelLieferscheinAnzeigenTitle.font.pixelSize
        x: mainWindow.width / 2//window.width / 5 * 3 - width / 2
        y: window.height / 10
    }
    Label {
        id: labelTitle4
        text: "Preis"
        font.pixelSize: labelLieferscheinAnzeigenTitle.font.pixelSize
        x: window.width / 5 * 4 - width / 2
        y: window.height / 10
    }

    ListView {
        id: liste
        y: window.height / 10 * 2
        focus: true
        highlightMoveDuration: 0
        highlight: Rectangle { color: "lightsteelblue"; width: window.width}
/*
        ScrollBar.vertical: ScrollBar {
            active: true;
            policy: ScrollBar.AlwaysOn
        }*/

        width: window.width
        height: window.height * 0.5

        ListModel {
            id: contactModel
        }

        Component {
            id: contactDelegate
            Item {
                id: itemListe
                property int currentIndex: index // store item index
                width: window.width
                height: vars.isPhone ? window.height/6 : window.height/10
                MouseArea {
                    anchors.fill: parent
                    onClicked: liste.currentIndex = index
                }
                Keys.onReturnPressed: {
                    liste.currentIndex = index + 1
                    if (liste.currentIndex == liste.count) {
                        //python.call('LieferscheinAnzeigen.main.AddLinie', [], function() {});
                        python.call('LieferscheinAnzeigen.main.GetLieferschein', [], function() {});
                    }
                }
                onActiveFocusChanged: {
                    //console.warn("Focus Changed")
                    //console.warn(liste.currentIndex)
                    textBarcode.forceActiveFocus()
                    textBarcode.selectAll()
                }
                Button {
                    id: buttonOption
                    text: "X"
                    width: vars.isPhone ? parent.width / 10 : parent.width / 20
                    height: parent.height * 0.8
                    y: parent.height / 2 - height / 2
                    onClicked: {
                        liste.currentIndex = itemListe.currentIndex;
                        python.call('LieferscheinAnzeigen.main.LinieEntfernen', [liste.currentIndex], function() {});
                    }
                }
                TextField {
                    id: textAnzahl
                    height: vars.isPhone ? parent.height * 0.2 : parent.height * 0.8
                    font.pixelSize: vars.isPhone ? parent.height * 0.15 : parent.height * 0.3
                    width: vars.isPhone ? parent.width / 5 : parent.width / 10
                    x: vars.isPhone ? window.width / 3 - width / 2 : window.width / 10 - width / 2
                    y: vars.isPhone ? parent.height / 6 * 2 - height / 2 : parent.height / 2 - height / 2
                    text: anzahl
                    inputMethodHints: Qt.ImhDigitsOnly
                    horizontalAlignment: TextEdit.AlignHCenter

                    focus: false

                    onAccepted: {
                        deselect();
                        python.call('LieferscheinAnzeigen.main.SetLieferschein', [liste.currentIndex, textAnzahl.text, textBarcode.text, textName.text, textPreis.text], function() {});
                    }
                    onFocusChanged: {
                        if(focus) {
                            liste.currentIndex = itemListe.currentIndex;
                        }
                    }
                }
                TextField {
                    id: textBarcode
                    height: vars.isPhone ? parent.height * 0.2 : parent.height * 0.8
                    font.pixelSize: vars.isPhone ? parent.height * 0.15 : parent.height * 0.3
                    width: vars.isPhone ? window.width / 3 : window.width / 10
                    x: vars.isPhone ? window.width / 3 * 2 - width / 2 : textAnzahl.x + textAnzahl.width
                    y: vars.isPhone ? parent.height / 6 * 2 - height / 2 : parent.height / 2 - height / 2
                    text: bcode
                    inputMethodHints: Qt.ImhDigitsOnly
                    horizontalAlignment: TextEdit.AlignHCenter

                    onAccepted: {
                        deselect();
                        python.call('LieferscheinAnzeigen.main.SetLieferschein', [liste.currentIndex, textAnzahl.text, textBarcode.text, textName.text, textPreis.text], function() {});
                    }
                    onFocusChanged: {
                        if(focus) {
                            liste.currentIndex = itemListe.currentIndex;
                        }
                    }
                }
                TextField {
                    id: textName
                    height: vars.isPhone ? parent.height * 0.2 : parent.height * 0.8
                    font.pixelSize: vars.isPhone ? parent.height * 0.15 : parent.height * 0.3
                    width: vars.isPhone ? window.width / 3 : window.width / 2
                    x: vars.isPhone ? window.width / 3 - width / 2 : textBarcode.x + textBarcode.width
                    y: vars.isPhone ? parent.height / 6 * 4 - height / 2 : parent.height / 2 - height / 2
                    text: name
                    horizontalAlignment: TextEdit.AlignHCenter

                    onAccepted: {
                        deselect();
                        python.call('LieferscheinAnzeigen.main.SetLieferschein', [liste.currentIndex, textAnzahl.text, textBarcode.text, textName.text, textPreis.text], function() {});
                    }
                    onFocusChanged: {
                        if(focus) {
                            liste.currentIndex = itemListe.currentIndex;
                        }
                    }
                }
                TextField {
                    id: textPreis
                    height: vars.isPhone ? parent.height * 0.2 : parent.height * 0.8
                    font.pixelSize: vars.isPhone ? parent.height * 0.15 : parent.height * 0.3
                    width: vars.isPhone ? window.width / 5 : window.width / 10
                    x: vars.isPhone ? window.width / 3 * 2 - width / 2 : window.width / 5 * 4 - width / 2
                    y: vars.isPhone ? parent.height / 6 * 4 - height / 2 : parent.height / 2 - height / 2
                    text: preis
                    inputMethodHints: Qt.ImhDigitsOnly
                    horizontalAlignment: TextEdit.AlignHCenter
                    onAccepted: {
                        deselect();
                        python.call('LieferscheinAnzeigen.main.SetLieferschein', [liste.currentIndex, textAnzahl.text, textBarcode.text, textName.text, textPreis.text], function() {});
                    }
                    onFocusChanged: {
                        if(focus) {
                            liste.currentIndex = itemListe.currentIndex;
                        }
                    }
                }
            }
        }

        model: contactModel
        delegate: contactDelegate
    }

    Label {
        id: labelTotal
        text: "0.00 €"
        font.pixelSize: window.height / 20
        x: window.width / 2 - width / 2
        y: window.height * 0.8

    }

    Button {
        id: buttonOK
        text: "Züruck"
        height: window.height / 15
        width: window.width / 5
        //x: window.width / 3 - width / 2
        //y: window.height * 0.9

        onClicked: {
            //python.call('LieferscheinAnzeigen.main.Ok', [], function() {});
            view.push(frameLieferscheinSuchen)
        }
    }
/*
    Label {
        text: "Fertig"
        font.pixelSize: window.width / 50
        x: window.width / 11 * 5 - width / 2
        y: window.height * 0.9
    }*/

    Button {
        id: switchFinish
        height: window.height / 15
        width: window.width / 5
        x: window.width / 11 * 5 - width / 2
        y: window.height * 0.9
        text: variable.switchFinishChecked ? "Fertig" : "Nicht Fertig"

        onClicked: {
            variable.switchFinishChecked = variable.switchFinishChecked ? false : true
            text = variable.switchFinishChecked ? "Fertig" : "Nicht Fertig"
            python.call("LieferscheinAnzeigen.main.Fertig", [variable.switchFinishChecked], function() {});
        }
    }
    Button {
        text: "Drucken"
        height: window.height / 15
        width: window.width / 5
        x: window.width / 11 * 9 - width / 2
        y: window.height * 0.9

        onClicked: {
            python.call("LieferscheinAnzeigen.main.Drucken", [], function() {});
            switchFinish.text = variable.switchFinishChecked ? "Fertig" : "Nicht Fertig";
        }
    }
    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('.'));
            importModule('LieferscheinAnzeigen', function () {});

            setHandler("busy", busy);
            setHandler("antwortGetLieferschein", antwortGetLieferschein);

            call('LieferscheinAnzeigen.main.GetLieferschein', [], function() {});
            call('LieferscheinAnzeigen.main.GetIdentification', [], function(lieferscheinNummer) {labelLieferscheinAnzeigenTitle.text = "Lieferschein: " + lieferscheinNummer});
        }
    }
}
