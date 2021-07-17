// ==UserScript==
// @name         KM Page Cleaner
// @namespace    strayscript
// @version      0.1
// @description  Remove useless modules from KM pages
// @author       StrayWarrior
// @grant        unsafeWindow
// @run-at       document-idle
// @match        *://km.sankuai.com/*
// ==/UserScript==

(function () {
  'use strict';

  var self_remove = function(e) { e.remove(); }
  var cleaner_function = function() {
    document.getElementsByClassName("feed-back-icon-container").forEach(self_remove);
    document.getElementsByClassName("ct-comment").forEach(self_remove);
    document.getElementsByClassName("ct-collapse").forEach(function(e) {
      if (e.getAttribute("class") == "ct-collapse") {
        e.setAttribute("class", "ct-collapse active");
      }
    });
    document.getElementById("clean-button-area").style.setProperty("display", "none");
  }
  var setup_function = function() {
    var cleanDiv = document.createElement("div");
    document.getElementsByClassName("secrecy")[0].insertAdjacentElement("afterend", cleanDiv);
    cleanDiv.id = "clean-button-area";
    cleanDiv.style.setProperty("text-align", "center");
    var cleanButton = document.createElement("button");
    cleanDiv.appendChild(cleanButton);
    cleanButton.style.setProperty("padding", "4px 12px");
    cleanButton.style.setProperty("border-radius", "4px");
    cleanButton.style.setProperty("border-width", "1px");
    cleanButton.style.setProperty("border-color", "rgb(200, 200, 200)");
    cleanButton.style.setProperty("background-color", "rgb(255, 255, 255)");
    cleanButton.style.setProperty("color", "rgb(131, 131, 131)");
    cleanButton.style.setProperty("margin", "4px");
    cleanButton.innerText = "cleanup";

    document.getElementsByClassName("page-like-data").forEach(self_remove);
    cleanButton.addEventListener("click", cleaner_function);
  }

  setInterval(function() {
    if (document.getElementsByClassName("page-like-data").length > 0) {
      setup_function();
    }
  }, 2000);
})();
