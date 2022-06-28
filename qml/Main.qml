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

    property bool force_ui_on: false

    PageStack {
        id: pageStack
        Page {
            id: mainPage
            anchors.fill: parent
            Loader {
                id: pageLoader
                anchors.fill: parent
            }
        }
    }

    Component {
        id: ariangComponent
        WebEngineView {
            id: webView
            anchors.fill: parent
            url: "http://localhost:6888" 

            profile: WebEngineProfile {
                storageName: "Storage"
                persistentStoragePath: "/home/phablet/.local/share/ariang.nitanmarcel/ariang.nitanmarcel/QWebEngine"
                onDownloadRequested: (download) => {
                    let fileName = download.path.replace(/^.*[\\\/]/, '')
                    download.path = "/home/phablet/.local/share/ariang.nitanmarcel/ariang.nitanmarcel/QWebEngine/Downloads"
                    download.accept()
                }
                onDownloadFinished: (download) => {
                    let exportPage = pageStack.push(Qt.resolvedUrl("ExportPage.qml"), {"url": download.path})
                }
            }

            onFileDialogRequested: (request) => {
                request.accepted = true
                force_ui_on = true
                var importPage = pageStack.push(Qt.resolvedUrl("ImportPage.qml"))
                importPage.imported.connect((fileUrl) => {
                    request.dialogAccept(fileUrl)
                    force_ui_on = false
                })
                importPage.rejected.connect(() => {
                    request.dialogReject()
                    force_ui_on = false
                })
            }  
        }
    }

    Connections {
        target: Qt.application
        onStateChanged: (state) => {
            if (!force_ui_on)
            {
                if (Qt.application.state !== Qt.ApplicationActive)
                    pageLoader.sourceComponent = null
                else
                    pageLoader.sourceComponent = ariangComponent
            }
        }
    }
}
