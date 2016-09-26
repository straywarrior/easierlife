// ==UserScript==
// @name         Green-Background for Your Eyes
// @namespace    strayscript
// @version      0.1
// @description  Replace the background color of the websites
// @author       StrayWarrior
// @include      *
// @grant        unsafeWindow
// @require      https://cdn.bootcss.com/jquery/3.1.0/jquery.min.js
// ==/UserScript==

(function() {
    'use strict';

    $("body").css("background-color", "#c7edcc");
    $("div").each(function(){
        if ($(this).css("background-color") == "rgb(255, 255, 255)")
            $(this).css("background-color", "#c7edcc");
    });
})();
