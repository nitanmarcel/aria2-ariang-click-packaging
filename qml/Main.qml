import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtQuick.Controls.Suru 2.2
import Morph.Web 0.1

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
        pageStack.push(Qt.resolvedUrl("AriaNgPage.qml"))
        setTheme(appSettings.themeIndex)
    }
}
