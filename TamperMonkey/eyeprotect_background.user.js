// ==UserScript==
// @name         EyeProtect-Background for Your Eyes
// @namespace    strayscript
// @version      0.2
// @description  Replace the background color of the websites
// @author       StrayWarrior
// @include      *
// @grant        unsafeWindow
// @require      https://cdn.bootcss.com/jquery/3.1.0/jquery.min.js
// ==/UserScript==

(function () {
    'use strict';

    const BACKGROUND_COLOR = "#fdf6e3";
    // 特殊的标签和类别需要跳过
    var skipNodes = ['SCRIPT', 'BR', 'CANVAS', 'IMG', 'svg', "INPUT"];
    Element.prototype.shouldBeIgnored = function () {
        if (skipNodes.indexOf(this.nodeName) > -1) {
            return true;
        }
        var ignoreClassList = ['highlight', 'syntax', 'code', 'player'];
        var len = ignoreClassList.length;
        var _class = this.getAttribute('class');
        var _id = this.id;
        for (var i = 0; i < len; i++) {
            if ((_class && _class.toLowerCase().indexOf(ignoreClassList[i]) > -1) ||
                (_id && _id.toLowerCase().indexOf(ignoreClassList[i]) > -1)) {
                return true;
            }
        }
        return false;
    }
    // 替换背景
    Element.prototype.replaceBackgroundColor = function () {
        var _key = "background-color"
        var _computed_color = window.getComputedStyle(this, null)[_key];
        if (_computed_color == "rgb(255, 255, 255)") {
            this.style[_key] = BACKGROUND_COLOR;
        }
        return 3;
    }
    // 递归处理节点
    Element.prototype.replaceColor = function (processOther = false) {
        // 包含highlight/player等特征的节点应当直接跳过，其子节点也不必再遍历
        if (this.shouldBeIgnored()) {
            return;
        }

        // 替换背景色
        var bgColorReplacReturn = this.replaceBackgroundColor();
        // 根据是否替换了背景色决定是否要处理边框、文字颜色等
        // 当返回值为2、3时说明当前节点是有背景色的，应当根据当前节点的情况修改processOther
        // 其他情况继续沿用父节点传下来的值
        if (bgColorReplacReturn == 3) {
            processOther = true;
        } else if (bgColorReplacReturn == 2) {
            processOther = false;
        }

        if (processOther) {
            // 替换边框色
            // this.replaceBorderColor();
            // 替换文本颜色
            // this.replaceTextColor();
        }

        // 递归
        var children = this.childNodes, i = 0, len = children.length;
        for (; i < len; i++) {
            if (children[i].nodeType == 1) {
                children[i].replaceColor(processOther);
            }
        }
    }

    var observer = new MutationObserver(function (mutations) {
        mutations.forEach(function (mutation) {
            var len = mutation.addedNodes.length;
            for (var i = 0; i < len; i++) {
                var node = mutation.addedNodes[i];
                // 先向上遍历一遍祖先，确认是否需要处理当前节点
                var ancestor = node, shouldIgnore = false;
                while ((ancestor = ancestor.parentNode) && ancestor.nodeName != 'BODY') {
                    if (ancestor.shouldBeIgnored()) {
                        shouldIgnore = true;
                        break;
                    }
                }
                // 文本节点内容改变也会触发mutation，而text并不是正经的node
                if (!shouldIgnore && node.nodeType == 1) {
                    node.replaceColor();
                }
            }
        });
    });

    var observerConfig = {
        childList: true,
        subtree: true
    };

    $("body").css("background-color", BACKGROUND_COLOR);
    Array.from(document.body.children).forEach((node) => {
        node.replaceColor();
    });
    observer.observe(document.body, observerConfig);
})();
