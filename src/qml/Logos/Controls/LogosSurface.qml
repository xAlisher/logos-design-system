import QtQuick
import QtQuick.Shapes

import Logos.Theme

// A filled, optionally rounded surface. If the active theme defines a
// gradient for `slot` (theme file `gradients.<slot>`), it draws that;
// otherwise it draws `color`, so themes without gradients (incl. Dark) look
// exactly as a plain Rectangle would.
//
//     background: LogosSurface {
//         slot: "sidebar"
//         color: Theme.palette.backgroundSecondary
//         radius: Theme.spacing.radiusXlarge
//     }
//
// Slots: workspace, sidebar, primary, accent, header.
Item {
    id: root

    property string slot: ""
    property color color: "transparent"
    property real radius: 0
    property color borderColor: "transparent"
    property real borderWidth: 0

    readonly property var gradientSpec:
        root.slot.length > 0 && Theme.gradients[root.slot] ? Theme.gradients[root.slot] : null
    readonly property bool hasGradient: gradientSpec !== null
    readonly property bool isRadial: hasGradient && gradientSpec.type === "radial"

    Rectangle {
        anchors.fill: parent
        visible: !root.hasGradient
        radius: root.radius
        color: root.color
        border.color: root.borderColor
        border.width: root.borderWidth
    }

    Shape {
        anchors.fill: parent
        visible: root.hasGradient
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: root.borderWidth > 0 ? root.borderWidth : -1
            strokeColor: root.borderColor
            fillGradient: root.isRadial ? d.radial : d.linear

            PathRectangle {
                x: 0
                y: 0
                width: root.width
                height: root.height
                radius: Math.min(root.radius, root.width / 2, root.height / 2)
            }
        }
    }

    QtObject {
        id: d

        // CSS-like angle: 0 = left to right, 90 = top to bottom. The line runs
        // through the centre and is long enough to reach the far corners.
        readonly property real rad: root.hasGradient && !root.isRadial
                                    ? root.gradientSpec.angle * Math.PI / 180 : 0
        readonly property real halfLength: (Math.abs(root.width * Math.cos(rad))
                                            + Math.abs(root.height * Math.sin(rad))) / 2

        property LinearGradient linear: LinearGradient {
            x1: root.width / 2 - Math.cos(d.rad) * d.halfLength
            y1: root.height / 2 - Math.sin(d.rad) * d.halfLength
            x2: root.width / 2 + Math.cos(d.rad) * d.halfLength
            y2: root.height / 2 + Math.sin(d.rad) * d.halfLength
        }

        property RadialGradient radial: RadialGradient {
            centerX: root.isRadial ? root.gradientSpec.center[0] * root.width : 0
            centerY: root.isRadial ? root.gradientSpec.center[1] * root.height : 0
            centerRadius: root.isRadial ? root.gradientSpec.radius * Math.max(root.width, root.height) : 0
            focalX: centerX
            focalY: centerY
        }

        property Component stop: Component { GradientStop {} }

        property var made: []

        function rebuild() {
            for (var j = 0; j < d.made.length; ++j)
                d.made[j].destroy()
            d.made = []
            if (!root.hasGradient)
                return
            var src = root.gradientSpec.stops
            var made = []
            for (var i = 0; i < src.length; ++i)
                made.push(d.stop.createObject(root, { position: src[i].position, color: src[i].color }))
            d.made = made
            ;(root.isRadial ? d.radial : d.linear).stops = made
        }
    }

    onGradientSpecChanged: d.rebuild()
    Component.onCompleted: d.rebuild()
}
