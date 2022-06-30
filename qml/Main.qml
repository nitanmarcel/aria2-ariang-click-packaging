import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtQuick.Controls.Suru 2.2
import Morph.Web 0.1

import QtWebEngine 1.7

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'ariang.nitanmarcel'
    automaticOrientation: true
    backgroundColor : "transparent"

    property bool force_ui_on: false

    Settings {
        id: appSettings
        category: "clickSettings"
        property int themeIndex: 0
    }

    PageStack {
        id: pageStack
        Page {
            id: mainPage
            anchors.fill: parent
        WebView {
            id: webView
            anchors.fill: parent
            url: "http://localhost:6888"

            enableSelectOverride: true
            settings.pluginsEnabled: true
            settings.javascriptCanAccessClipboard: true

            context: WebContext {
                storageName: "Storage"
                persistentStoragePath: "/home/phablet/.local/share/ariang.nitanmarcel/QWebEngine"

                userScripts: [
                    WebEngineScript {
                        id: themeInjection
                        injectionPoint: WebEngineScript.DocumentCreation
                        worldId: WebEngineScript.MainWorld
                        sourceUrl: Qt.resolvedUrl('userscripts/themechange.js')
                    }
                ]

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

            onJavaScriptConsoleMessage: (level, message, lineNumber) => {
                let themeChangedMatch = message.match(/^themeChangedMessage: (\d)/)
                if (themeChangedMatch) {
                    let index = parseInt(themeChangedMatch[1], 0)
                    appSettings.themeIndex = index;
                    root.setTheme(index)
                }
            }

            onLoadingChanged: {
                if (!loading)
                    switchTheme()
                root.themeChanged.connect(() => switchTheme())
        }

            function switchTheme() {
                if (root.theme.name.substring(theme.name.lastIndexOf(".")+1) === "SuruDark")
                    runJavaScript('document.body.classList.add("theme-dark")')
                else
                    runJavaScript('document.body.classList.remove("theme-dark")')
            }
        }
        }
    }

    function setTheme(index) {
        if (index === 0) // Light
            theme.name = "Ubuntu.Components.Themes.Ambiance"
        if (index === 1) // Dark 
            theme.name = "Ubuntu.Components.Themes.SuruDark"
        if (index === 2 ) // System
            theme.name = ""
    }

    Component.onCompleted: {
        setTheme(appSettings.themeIndex)
    }
}
