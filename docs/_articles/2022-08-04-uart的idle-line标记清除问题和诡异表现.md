---
title: "UART的IDLE LINE标记清除问题和诡异表现"
date: 2022-08-04 00:00:00 +0800
categories: [tools]
tags: [单片机同时被 3 个专栏收录, mdk, uart, ROS2, 日积月累计划]
description: ""
layout: article
csdn_id: 126157522
---

**一、概述**

最近在使用某国产MCU，需要用到USART2的idle line功能。

具体操作是在检测到idle line中断的时候，首先清除此中断。它清除中断的操作一般做法是操作此函数：
[code] 
    void USART_ClrIntPendingBit(USART_Module* USARTx, uint16_t USART_INT)
[/code]

因为对方的库封装的不太好，实际上USART_INT传入的参数只有USART_INT_CTSF、USART_INT_LINBD、USART_INT_TXC和USART_INT_RXDNE。如果错误的传入IDLEF标记USART_INT_IDLEF尽管会被assert，但是因为默认assert又是禁用的，所以就不能看到传入参数的问题。而且此公司也没有为USART_INT_IDLEF的清除提供其它函数，这就造成了以下诡异的现象：

1.在全速debug模式下（我一般会打开USART2的外设去观察变量变化），程序按照预期运行。

2\. 在正常运行的时候，程序在接收到指令之后会出现卡顿。因为调试模式没有问题，所以不知道卡顿出现在哪里？

尽管有种预感是某个中断标记未清除。但是在debug阶段明明看到IDLEF被清除了。

**二、端倪**

在经历了一整天修改代码之后，失望回家。第二天早上，又重新调试代码。今天其实还邀请了原厂人员前来。这时候我无意间关掉了调试用的USART2观察窗口，打开成了USART3.这时候调试也出现了卡顿。然后我重新打开USART2观察窗口，代码又能顺利运转。在关闭了USART2观察窗口之后，我意识到中断退出之后在新一轮打开之后又立刻进入了IDLE中断的原因就是此标记未能真正清除。进原厂函数查看了以下才发现原因。后面自己重新封装了清除中断标记的函数之后，就解开了这个问题。

**三、思考**

这次掉坑的经历尽管在于国产的库没有做好封装。但真正有意思的部分是全速debug模式下和正常运行模式的差异。注意是全速debug。

现在了解到在打开USART2窗口的时候，不知道为何其实keil帮忙清除了IDLEF位。