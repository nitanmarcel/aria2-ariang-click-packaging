import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtWebEngine 1.7

import Example 1.0

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'ariang.nitanmarcel'
    automaticOrientation: true
    backgroundColor : "transparent"

    Page {
        anchors.fill: parent
        WebEngineView {
            id: webView
            anchors.fill: parent
            url: "http://localhost:6888"
        }
    }
}
