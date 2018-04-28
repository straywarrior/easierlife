// ==UserScript==
// @name         Remove Zhihu Inequality Clauses
// @namespace    strayscript
// @version      0.2
// @description  Let the inequality clauses about privacy go away!
// @author       StrayWarrior
// @match        http*://*.zhihu.com/*
// @grant        unsafeWindow
// @require      https://cdn.bootcss.com/jquery/3.1.0/jquery.min.js
// ==/UserScript==

(function() {
    'use strict';

    var cleaner = function() {
        $("html").css("overflow", "visible");
        $("div.PrivacyConfirm-modal").each(function() {
          this.parentNode.remove();
        });
    };
    var MAGIC_CODE = ['f', 'k'];
    var current = 0;
    document.addEventListener("keypress", function(e){
        var code = e.keyCode || e.which;
        var ch = String.fromCharCode(code);
        if (ch == MAGIC_CODE[current]) {
            current++;
        } else {
            current = 0;
        }
        if (current == MAGIC_CODE.length) {
            cleaner();
            console.log("You should have thrown away the disgusting inequality clauses!");
        }
    });
    setTimeout(cleaner, 2000);
})();
