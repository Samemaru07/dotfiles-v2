pragma Singleton
import Quickshell

Singleton {
    id: root

    function doLayout(windowList, outerWidth, outerHeight) {
        var N = windowList.length;
        if (N === 0)
            return [];

        var gap = Math.max(8, outerWidth * 0.005);
        var groupGap = outerWidth * 0.1;
        var useW = outerWidth * 0.95;
        var useH = outerHeight * 0.9;
        var offX = (outerWidth - useW) / 2;
        var offY = (outerHeight - useH) / 2;
        // ワークスペースごとにグループ化
        var groups = {
        };
        for (var i = 0; i < N; i++) {
            var wsId = windowList[i].workspaceId;
            if (!groups[wsId])
                groups[wsId] = [];

            groups[wsId].push(windowList[i]);
        }
        var wsKeys = Object.keys(groups).sort();
        var totalCols = N;
        var totalGapW = (N - 1) * gap + (wsKeys.length - 1) * groupGap;
        var colW = (useW - totalGapW) / totalCols;
        var minColW = 200;
        if (colW < minColW)
            colW = minColW;

        var result = [];
        var currentX = offX;
        for (var g = 0; g < wsKeys.length; g++) {
            var wsId = wsKeys[g];
            var items = groups[wsId];
            for (var j = 0; j < items.length; j++) {
                var item = items[j];
                var w0 = (item.width > 0) ? item.width : 100;
                var h0 = (item.height > 0) ? item.height : 100;
                var sc = Math.min(colW / w0, useH / h0);
                var thumbW = w0 * sc;
                var thumbH = h0 * sc;
                var xCentered = currentX + (colW - thumbW) / 2;
                var yCentered = offY + (useH - thumbH) / 2;
                result.push({
                    "win": item.win,
                    "x": xCentered,
                    "y": yCentered,
                    "width": thumbW,
                    "height": thumbH,
                    "workspaceId": item.workspaceId
                });
                currentX += colW + gap;
            }
            // グループ間にスペースを追加
            if (g < wsKeys.length - 1) {
                var lastItemRight = currentX - gap;
                var nextGroupStart = currentX + groupGap - gap;
                var dividerX = lastItemRight + (nextGroupStart - lastItemRight) / 2;
                result.push({
                    "isDivider": true,
                    "x": dividerX,
                    "y": offY + useH * 0.1,
                    "width": 2,
                    "height": useH * 0.8,
                    "workspaceId": 0,
                    "win": null
                });
                currentX += groupGap - gap;
            }
        }
        return result;
    }

}
