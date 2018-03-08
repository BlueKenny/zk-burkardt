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
    }

    function antwortGetLieferschein(item, summe, fertig) {
        //console.warn("antwortGetLieferschein")
        variable.listeIndex = liste.currentIndex
        //console.warn("Current Index: " + variable.listeIndex)
        contactModel.clear();
        for (var i=0; i<item.length; i++) {
            contactModel.append(item[i]);
        }
        if (variable.listeIndex == -1) { variable.listeIndex = 0 }
        liste.currentIndex = variable.listeIndex
        labelTotal.text = summe
        switchFinish.checked = fertig
    }

    Label {
        id: labelLieferscheinAnzeigenTitle
        text: "Lieferschein: "
        font.pixelSize: vars.isPhone ? mainWindow.width / 20 : mainWindow.width / 50
        x: mainWindow.width / 2 - width / 2
    }

    Label {
        id: labelTitle1
        text: "Anzahl"
        font.pixelSize: labelLieferscheinAnzeigenTitle.font.pixelSize
        x: window.width / 5 - width / 2
        y: window.height / 10
    }
    Label {
        id: labelTitle2
        text: "Barcode"
        font.pixelSize: window.height / 10 * 0.4
        x: window.width / 5 * 2 - width / 2
        y: window.height / 10
    }
    Label {
        id: labelTitle3
        text: "Name"
        font.pixelSize: window.height / 10 * 0.4
        x: window.width / 5 * 3 - width / 2
        y: window.height / 10
    }
    Label {
        id: labelTitle4
        text: "Preis"
        font.pixelSize: window.height / 10 * 0.4
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
                width: window.width; height: window.height/10
                MouseArea {
                    anchors.fill: parent
                    onClicked: liste.currentIndex = index
                }
                Keys.onReturnPressed: {
                    liste.currentIndex = index + 1
                    if (liste.currentIndex == liste.count) {
                        python.call('LieferscheinAnzeigen.main.AddLinie', [], function() {});
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
                    y: parent.height / 2 - height / 2
                    onClicked: {
                        liste.currentIndex = itemListe.currentIndex;
                        python.call('LieferscheinAnzeigen.main.LinieEntfernen', [liste.currentIndex], function() {});
                    }
                }
                TextField {
                    id: textAnzahl
                    font.pixelSize: parent.height * 0.3
                    width: window.width / 5
                    x: window.width / 5 - width / 2
                    y: parent.height / 2 - height / 2
                    text: anzahl
                    inputMethodHints: Qt.ImhDigitsOnly
                    horizontalAlignment: TextEdit.AlignHCenter

                    focus: false

                    onAccepted: {
                        deselect();
                        python.call('LieferscheinAnzeigen.main.SetLieferschein', ["anzahl", liste.currentIndex, text], function() {});
                    }
                    onFocusChanged: {
                        if(focus) {
                            liste.currentIndex = itemListe.currentIndex;
                        }
                    }
                }
                TextField {
                    id: textBarcode
                    font.pixelSize: parent.height * 0.3
                    width: window.width / 5
                    x: window.width / 5 * 2 - width / 2
                    y: parent.height / 2 - height / 2
                    text: bcode
                    inputMethodHints: Qt.ImhDigitsOnly
                    horizontalAlignment: TextEdit.AlignHCenter

                    onAccepted: {
                        deselect();
                        python.call('LieferscheinAnzeigen.main.SetLieferschein', ["bcode", liste.currentIndex, text], function() {});
                    }
                    onFocusChanged: {
                        if(focus) {
                            liste.currentIndex = itemListe.currentIndex;
                        }
                    }
                }
                TextField {
                    id: textName
                    font.pixelSize: parent.height * 0.3
                    width: window.width / 5
                    x: window.width / 5 * 3 - width / 2
                    y: parent.height / 2 - height / 2
                    text: name
                    horizontalAlignment: TextEdit.AlignHCenter

                    onAccepted: {
                        deselect();
                        python.call('LieferscheinAnzeigen.main.SetLieferschein', ["name", liste.currentIndex, text], function() {});
                    }
                    onFocusChanged: {
                        if(focus) {
                            liste.currentIndex = itemListe.currentIndex;
                        }
                    }
                }
                TextField {
                    id: textPreis
                    font.pixelSize: parent.height * 0.3
                    width: window.width / 5
                    x: window.width / 5 * 4 - width / 2
                    y: parent.height / 2 - height / 2
                    text: preis
                    inputMethodHints: Qt.ImhDigitsOnly
                    horizontalAlignment: TextEdit.AlignHCenter
                    onAccepted: {
                        deselect();
                        python.call('LieferscheinAnzeigen.main.SetLieferschein', ["preis", liste.currentIndex, text], function() {});
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

    Label {
        text: "Fertig"
        font.pixelSize: window.width / 50
        x: window.width / 11 * 5 - width / 2
        y: window.height * 0.9
    }

    Switch {
        id: switchFinish
        x: window.width / 11 * 6 - width / 2
        y: window.height * 0.9

        onClicked: {
            python.call("LieferscheinAnzeigen.main.Fertig", [switchFinish.checked], function() {});
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