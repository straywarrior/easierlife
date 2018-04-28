// ==UserScript==
// @name         Remove Zhihu Inequality Clauses
// @namespace    strayscript
// @version      0.1
// @description  Let the inequality clauses about privacy go away!
// @author       StrayWarrior
// @match        http*://*.zhihu.com/*
// @grant        unsafeWindow
// @require      https://cdn.bootcss.com/jquery/3.1.0/jquery.min.js
// ==/UserScript==

(function() {
    'use strict';

    $("html").css("overflow", "visible");
    $("div.PrivacyConfirm-modal").parentNode.remove();

})();
