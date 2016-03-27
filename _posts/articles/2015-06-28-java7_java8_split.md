---
layout: post
title : Behavior Change in String.split for Java 8
excerpt: Java 8 now ignores 1st null element.
date: 2015-04-11 21:36
categories: articles
comments : true
share: true
tags: [java]
---

Recently on Stackoverflow a user posted a [question](http://stackoverflow.com/questions/31009769/java-string-split-gives-different-outputs-on-windows-and-linux/31011020#31011020) regarding Java's String.split() method, one that beginners are regularly exposed to in order to extract data within strings. 

The user stumbled upon this when trying to test code in another machine, which happened to be running a different version of Java. Java 8 has changed the implementation of `split()` from having an empty string being added into the string array on first null element, to not adding an empty string into the array.

Consider the following string:

	String myString = "helloworld";

In Java 7, calling `myString.split("")` would yield `|h|e|l|l|o|w|o|r|l|d|` with a length of 11 in the array.

<script src="http://ideone.com/e.js/lSTmQb" type="text/javascript" ></script>

Whereas if this exact source was executed in a Java 8 VM, `myString.split("")` would yield `h|e|l|l|o|w|o|r|l|d|` with a length of 10 in the string array. Also notice how there isn't a `|` character at the first part of the array?

<script src="http://ideone.com/e.js/KxVA7Z" type="text/javascript" ></script>

*Note that IDEOne runs `sun-jdk-1.7.0_10` for Java 7 and `sun-jdk-8u25` for Java 8 at time of writing.* 

Even though this change affects `String.split`, the implementation change is actually in `Pattern.split` as [this SO Answer](http://stackoverflow.com/a/27477312/4512948) has explored. The answer even dives into the source code of Java to find how the Pattern matching has changed. 

This is a subtle and important change as now you wouldn't have to remove the empty string in the array, or add even more code to handle the case of an empty string when a split occurs in the beginning or end of the string.

Notice the difference in the JavaDocs for the `split()` method [in Java 7](http://docs.oracle.com/javase/7/docs/api/java/lang/String.html#split(java.lang.String)) and in [Java 8](http://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html#split-java.lang.CharSequence-int-) for the `Pattern` class, and the string class ([Java 7](https://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html#split%28java.lang.CharSequence,%20int%29), [Java 8](http://docs.oracle.com/javase/8/docs/api/java/lang/String.html#split-java.lang.String-int-) respectively. The extra line to highlight this change is: 

> When there is a positive-width match at the beginning of this string then an empty leading substring is included at the beginning of the resulting array. **A zero-width match at the beginning however never produces such empty leading substring.**

The 'behavior change' however will not affect pattern matches at the end of the string. 

It's surprising how there was no mention of this change online other than [a few bug reports](https://bugs.openjdk.java.net/browse/JDK-8043324?page=com.atlassian.jira.plugin.system.issuetabpanels:all-tabpanel) wrongly filed about this change, considering how `String.split()` is so frequently used. In fact I suspect this will cause a lot of backward compatibility issues. 

Which is why I decided to write about this issue so that others won't have to click around and dig for questions on this behavior. I know of a lot of labs that still use Java 6 to teach students, and suddenly having `String.split()` change in Java 8 will likely cause some headache to some wondering why their code worked fine in Java 7 but broke in Java 8. 
