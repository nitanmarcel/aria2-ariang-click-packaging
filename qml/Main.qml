import QtQuick 2.12
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtWebEngine 1.7

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'ariang.nitanmarcel'
    automaticOrientation: true
    backgroundColor : "transparent"

    Page {
        anchors.fill: parent
        Loader {
            id: pageLoader
            anchors.fill: parent
        }

        Connections {
            target: Qt.application
            onStateChanged: (state) => {
                if (Qt.application.state !== Qt.ApplicationActive) {
                    pageLoader.sourceComponent = null
                    console.log("Unload WebView")
                }
                else {
                    pageLoader.sourceComponent = ariangComponent
                    console.log("Load WebView")
                }
            }
        }
    }

    Component {
        id: ariangComponent
        WebEngineView {
            id: webView
            anchors.fill: parent
            url: "http://localhost:6888"
        }
    }
}
