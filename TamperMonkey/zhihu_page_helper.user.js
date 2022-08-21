// ==UserScript==
// @name         Zhihu Page Helper
// @namespace    strayscript
// @version      0.4.0
// @description  Make Zhihu easier to use for me.
// @author       StrayWarrior
// @match        http*://*.zhihu.com/*
// @grant        unsafeWindow
// ==/UserScript==

(function() {
  'use strict';

  var self_remove = function(e) { e.remove(); }

  const MARK_ID = "page-helper-mark";
  var after_setup = function() {
    var mark = document.createElement("div");
    mark.id = MARK_ID;
    document.body.insertAdjacentElement("afterend", mark);
  }

  HTMLCollection.prototype.forEach = function(callback) {
    for (var i = 0; i < this.length; ++i) {
      callback(this[i]);
    }
  }

  var removeElementsByClassName = function(name) {
    document.getElementsByClassName(name).forEach(self_remove);
  }

  var zhuanlan_clean_function = function() {
    removeElementsByClassName("RichContent-actions");
    removeElementsByClassName("CornerButtons");
    document.getElementById("clean-button").remove();
  }

  var zhuanlan_setup_function = function() {
    if (document.getElementsByClassName("ColumnPageHeader-Button").length == 0) {
      return;
    }

    var cleanButton = document.createElement("button");
    var header = document.getElementsByClassName("ColumnPageHeader-Button")[0];
    header.insertAdjacentElement("afterbegin", cleanButton);
    cleanButton.id = "clean-button";
    cleanButton.setAttribute("class", "Button ColumnPageHeader-WriteButton Button--blue");
    cleanButton.style.setProperty("margin-right", "16px");
    cleanButton.innerText = "cleanup";
    cleanButton.addEventListener("click", zhuanlan_clean_function);

    after_setup();
  }

  var answer_clean_function = function() {
    removeElementsByClassName("Sticky AppHeader");
    removeElementsByClassName("Question-sideColumn Question-sideColumn--sticky");
    // removeElementsByClassName("Card MoreAnswers");
    // removeElementsByClassName("Card ViewAll");
    removeElementsByClassName("CornerButtons");
    removeElementsByClassName("ContentItem-actions RichContent-actions");
    document.querySelector(".Question-mainColumn").style["width"] = "revert";
    document.getElementById("clean-button").remove();
  }

  var answer_setup_function = function() {
    var pageHeader = document.querySelector(".PageHeader");
    if (!pageHeader) {
      return;
    }

    var cleanButton = document.createElement("button");
    var buttonGroup = pageHeader.querySelector(".QuestionButtonGroup")
    buttonGroup.insertAdjacentElement("afterbegin", cleanButton);
    cleanButton.id = "clean-button";
    cleanButton.setAttribute("class", "Button Button--blue");
    cleanButton.innerText = "清理";
    cleanButton.addEventListener("click", answer_clean_function);
    // set other div styles
    pageHeader.querySelector(".QuestionHeader-main").style["width"] = "revert";
    pageHeader.querySelector(".QuestionHeader-side").style["max-width"] = "revert";

    after_setup();
  }

  setInterval(function() {
    if (document.getElementById(MARK_ID) != null) {
      return;
    }
    var hostname = location.hostname;
    if (hostname.includes("zhuanlan.zhihu.com")) {
      zhuanlan_setup_function();
    }
    if (hostname.includes("zhihu.com") && location.href.includes("answer")) {
      answer_setup_function();
    }
  }, 2000);
})();
