// ==UserScript==
// @name         See Goodbye to Tieba Ads
// @namespace    strayscript
// @version      0.1
// @description  Remove ads from the pages of Tieba. May add other ads later.
// @author       StrayWarrior
// @match        tieba.baidu.com/*
// @grant        unsafeWindow
// @require      https://cdn.bootcss.com/jquery/3.1.0/jquery.min.js
// ==/UserScript==

(function() {
    'use strict';

    // Remove long recommendations in the post content
    $("div.thread-recommend").each(function(){
        $(this).css("display", "none");
    });
})();
