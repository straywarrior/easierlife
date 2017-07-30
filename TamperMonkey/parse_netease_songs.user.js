// ==UserScript==
// @name         Follow Your Songs
// @namespace    strayscript
// @version      0.1
// @description  Parse song list of Netease Music. Maybe other music websites in the future.
// @author       StrayWarrior
// @match        music.163.com/*
// @grant        unsafeWindow
// @require      https://cdn.bootcss.com/jquery/3.1.0/jquery.min.js
// ==/UserScript==

(function() {
    'use strict';

    $("div.ttc").each(function(){
        console.log($(this).text())
    });
})();
