import QtQuick 2.2
import io.thp.pyotherside 1.2
import QtQuick.Controls 1.1//2.0

Rectangle {
    height: mainWindow.height
    width: mainWindow.width


    function antwortSearchLieferscheine(item) {
        console.warn("antwortSearchLieferscheine")
        //variable.listeIndex = liste.currentIndex
        //console.warn("Current Index: " + variable.listeIndex)
        listLieferscheinSuchen.currentIndex = 0
        contactModel.clear();
        for (var i=0; i<item.length; i++) {
            contactModel.append(item[i]);
        }
        listLieferscheinSuchen.currentIndex = listLieferscheinSuchen.count - 1//variable.listeIndex
        //labelTotal.text = summe
        //checkBoxFinish.checked = fertig
    }

    Button {
        text: "Hauptmenu"
        height: mainWindow.height / 15
        width: mainWindow.width / 5
        onClicked: {
            view.push(frameSelect)
        }
    }

    Label {
        id: labelLieferscheinSuchenTitle
        text: "Lieferscheine Suchen"
        font.pixelSize: vars.isPhone ? mainWindow.width / 20 : mainWindow.width / 50
        x: mainWindow.width / 2 - width / 2
    }

    Label {
        text: "Lieferscheinnummer"
        font.pixelSize: mainWindow.width / 50
        x: mainWindow.width / 3 - width / 2
        y: mainWindow.height / 20
    }
    TextField {
        id: textLieferscheinSuchenIdentification
        text: vars.lieferscheinSuchenTextIdentification
        width: mainWindow.width / 10
        x: mainWindow.width / 3 * 2 - width / 2
        y: mainWindow.height / 20
        onAccepted: {
            vars.lieferscheinSuchenTextIdentification = text
            python.call("LieferscheinSuchen.main.GetLieferscheine", [textLieferscheinSuchenIdentification.text, textLieferscheinSuchenName.text, checkLieferscheinSuchenFertige.checked, checkLieferscheinSuchenEigene.checked], function() {});
        }
    }


    Label {
        text: "Kunde"
        font.pixelSize: mainWindow.width / 50
        x: mainWindow.width / 3 - width / 2
        y: mainWindow.height / 20 * 2
    }
    TextField {
        id: textLieferscheinSuchenName
        text: vars.lieferscheinSuchenTextName
        width: mainWindow.width / 10
        x: mainWindow.width / 3 * 2 - width / 2
        y: mainWindow.height / 20 * 2
        MouseArea {
            anchors.fill: textLieferscheinSuchenName
            onClicked: {
                vars.kundenSuchenVorherigeAnsicht = "frameLieferscheinSuchen"
                view.push(frameKundenSuchen)
            }
        }
    }
    Button {
        id: buttonLieferscheinSucheKundenClear
        text: "X"
        x: textLieferscheinSuchenName.x + textLieferscheinSuchenName.width
        y: textLieferscheinSuchenName.y
        height: textLieferscheinSuchenName.height
        width: textLieferscheinSuchenName.width / 2
        onClicked: {
            vars.lieferscheinSuchenTextName = ""
            textLieferscheinSuchenName.text = ""
            python.call("LieferscheinSuchen.main.GetLieferscheine", [textLieferscheinSuchenIdentification.text, textLieferscheinSuchenName.text, checkLieferscheinSuchenFertige.checked, checkLieferscheinSuchenEigene.checked], function() {});
        }
    }

    Label {
        text: "Auch fertige Lieferscheine anzeigen"
        font.pixelSize: mainWindow.width / 50
        x: mainWindow.width / 3 - width / 2
        y: mainWindow.height / 20 * 3
    }
    CheckBox {
        id: checkLieferscheinSuchenFertige
        x: mainWindow.width / 3 * 2 - width / 2
        y: mainWindow.height / 20 * 3
        checked: vars.lieferscheinSuchenCheckFertige
        onCheckedChanged: {
            vars.lieferscheinSuchenCheckFertige = checkLieferscheinSuchenFertige.checked
            python.call("LieferscheinSuchen.main.GetLieferscheine", [textLieferscheinSuchenIdentification.text, textLieferscheinSuchenName.text, checkLieferscheinSuchenFertige.checked, checkLieferscheinSuchenEigene.checked], function() {});
        }
    }

    Label {
        text: "Nur die eigenen Lieferscheine anzeigen"
        font.pixelSize: mainWindow.width / 50
        x: mainWindow.width / 3 - width / 2
        y: mainWindow.height / 20 * 4
    }
    CheckBox {
        id: checkLieferscheinSuchenEigene
        x: mainWindow.width / 3 * 2 - width / 2
        y: mainWindow.height / 20 * 4
        checked: vars.lieferscheinSuchenCheckEigene
        onCheckedChanged: {
            vars.lieferscheinSuchenCheckEigene = checkLieferscheinSuchenEigene.checked
            python.call("LieferscheinSuchen.main.GetLieferscheine", [textLieferscheinSuchenIdentification.text, textLieferscheinSuchenName.text, checkLieferscheinSuchenFertige.checked, checkLieferscheinSuchenEigene.checked], function() {});
        }
    }

    Button {
        id: buttonLieferscheinSuchenNeu
        text: "Neu"
        x: mainWindow.width / 2 - width / 2
        y: mainWindow.height / 20 * 5
        height: mainWindow.height / 15
        width: mainWindow.width / 5

        onClicked: {
            python.call("LieferscheinSuchen.main.LastLieferschein", [""], function() {});
            view.push(frameLieferscheinAnzeigen)
        }
    }
    ListView {
        id: listLieferscheinSuchen
        y: mainWindow.height / 20 * 7

        focus: true
        highlightMoveDuration: 0
        highlight: Rectangle { visible: false ; color: "lightsteelblue"; width: mainWindow.width}

        height: (mainWindow.height / 20) * 13
        width: mainWindow.width

        ListModel {
            id: contactModel
        }
        Component {
            id: contactDelegate
            Item {
                id: itemListe
                width: listLieferscheinSuchen.width
                height: vars.isPhone ? listLieferscheinSuchen.height / 8 : listLieferscheinSuchen.height / 12

                Label {
                    id: labelLieferscheinSucheListeEintrag
                    text: identification + " | " + kunde_name + " [" + kunde_id + "] | Preis: " + total + "€"
                    font.pixelSize: vars.isPhone ? listLieferscheinSuchen.width / 15 : listLieferscheinSuchen.width / 40
                    x: listLieferscheinSuchen.width / 2 - width / 2
                    color: fertig ? "blue" : "red"

                    MouseArea {
                        anchors.fill: labelLieferscheinSucheListeEintrag
                        onClicked: {
                            python.call("LieferscheinSuchen.main.LastLieferschein", [parent.text], function() {});
                            view.push(frameLieferscheinAnzeigen)
                        }
                    }
                }
            }
        }

        model: contactModel
        delegate: contactDelegate
    }


    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('./'));
            importModule('LieferscheinSuchen', function () {});

            setHandler("antwortSearchLieferscheine", antwortSearchLieferscheine);
            setHandler("busy", busy);

            call("LieferscheinSuchen.main.GetLieferscheine", [textLieferscheinSuchenIdentification.text, textLieferscheinSuchenName.text, checkLieferscheinSuchenFertige.checked, checkLieferscheinSuchenEigene.checked], function() {});
        }
    }
}
