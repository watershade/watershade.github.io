---
title: "implicit declaration of function ‘settimeofday’ 解决办法"
date: 2020-07-08 00:00:00 +0800
categories: [notes]
tags: [C语言同时被 2 个专栏收录, 问题与答案, ROS2, 日积月累计划, linux]
description: ""
layout: article
csdn_id: 107069143
---

### 问题描述

在编写一个改变linux系统时钟的函数中用到了settimeofday这个函数。但是再make的时候出现了以下错误：
[code] 
     warning: implicit declaration of function ‘settimeofday’; did you mean ‘gettimeofday’? [-Wimplicit-function-declaration]
    
[/code]

什么原因呐？搜了好久，都没有正确的解决方法。  
无意间，在函数的说明中查到了以下说明：
[code] 
    NOTE
    
          The  prototype  for settimeofday and the defines for timercmp, timeris-
          set, timerclear, timeradd, timersub are (since glibc2.2.2) only	avail-
          able  if	 _BSD_SOURCE  is defined (either explicitly, or implicitly, by
          not defining _POSIX_SOURCE or compiling with the -ansi flag).
    
    
[/code]

就是说要么显式定义或者隐式定义_BSD_SOURCE,或者在写makefile的时候在CFLAGS添加上-ansi语句。  
但是不能直接在c文件中这么做，可以在makefile中添加-D_BSD_SOURCE，但是回提示别的警告。告诉你_BSD_SOURCE已经废弃之类的。

在看了以下文章之后，我改成了-D_GNU_SOURCE就OK了。

### 原因追踪

为什么要定义_BSD_SOURCE？这些文件应该涉及到一些关于BSD系统保留下函数、类型等定义。