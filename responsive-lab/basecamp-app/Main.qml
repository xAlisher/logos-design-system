import QtQuick
import QtQuick.Controls

import Logos.Theme
import Logos.Controls
import Logos.Icons

// Responsive Lab as a Basecamp app (QML-only): the DS fork's lab screens inside
// one LogosAppScaffold. Resize the window: sidebar ≥ 840, rail ≥ 600, ☰ below.
Item {
    id: root
    anchors.fill: parent

    readonly property var pages: [
        { id: "mail",      label: "Mail",       icon: LogosIcons.list,  badge: 3, file: "MailPage.qml" },
        { id: "settings",  label: "Settings",   icon: LogosIcons.more,  file: "SettingsPage.qml" },
        { id: "form",      label: "Form",       icon: LogosIcons.pages, file: "FormPage.qml" },
        { id: "dashboard", label: "Dashboard",  icon: LogosIcons.grid,  file: "DashboardPage.qml" },
        { id: "table",     label: "Table",      icon: LogosIcons.list,  file: "TablePage.qml" },
        { id: "gallery",   label: "Components", icon: LogosIcons.check, file: "GalleryPage.qml" },
    ]
    property string current: "mail"
    readonly property var currentPage: pages.find(p => p.id === current) || pages[0]

    // A compact window means touch-size targets (ADR-060), per engine.
    Binding { target: Theme; property: "compactWindow"; value: root.visible && root.width > 0 && Theme.windowClass(root.width) === "compact" }
    Component.onDestruction: Theme.compactWindow = false

    Rectangle { anchors.fill: parent; color: Theme.palette.background }

    LogosAppScaffold {
        id: scaffold
        objectName: "lab.scaffold"
        anchors.fill: parent
        title: "Responsive Lab"
        pageTitle: loader.item && loader.item.title ? loader.item.title : root.currentPage.label
        navModel: root.pages
        currentNav: root.currentPage.id
        canGoBack: loader.item ? !!loader.item.canGoBack : false
        searchEnabled: loader.item ? !!loader.item.searchable : false
        searchPlaceholder: loader.item && loader.item.searchPlaceholder ? loader.item.searchPlaceholder : "Search"
        onNavActivated: id => root.current = id
        onBackRequested: if (loader.item && loader.item.goBack) loader.item.goBack()

        Loader {
            id: loader
            anchors.fill: parent
            source: "pages/" + root.currentPage.file
            property string windowClass: scaffold.windowClass
            property var labState: ({})
            property string searchText: scaffold.searchText
        }
    }
}
