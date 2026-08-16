import QtQuick

// NOTE: Hyprview.qml側で visible: false として使われている前提のため、
// 見た目は何も作り込んでいません。検索バーとして表示したくなったら
// 背景・枠線などを追加してください。
Item {
    id: root

    property alias text: input.text

    implicitWidth: 400
    implicitHeight: 48

    function reset() {
        input.text = "";
        input.forceActiveFocus();
    }

    TextInput {
        id: input

        anchors.fill: parent
        font.pixelSize: 18
        color: "white"
        focus: true
    }

}
