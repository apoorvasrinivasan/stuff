---
title: Introduction to Javascript
date: 2017-08-05  20:10
author: apoorva
template: article.jade
intro:  What I know of javascript. How to begin and debug
---


## new to web##

* open file
* save with .html extention
* open the file from the browser

This is your first HTML page

###  how to start with javascript

Javascript is written inside `<script>` tag. Anything written inside the tag is executed. Script tag is inserted as
`<script type="text/javascript"></script>`  
A script tag can be inserted inside `<head>` or just before closing the `<body>` tag

The difference between the two is,:-
 - the script in the `<head>` runs *before* the DOM structure is constructed and the later is run after the DOM is contructed
 - the script in `<head>` is render blocking i.e. stops the page from loading and should be very light and minimal. 