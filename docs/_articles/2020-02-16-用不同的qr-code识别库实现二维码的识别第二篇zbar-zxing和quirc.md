---
title: "用不同的QR Code识别库实现二维码的识别（第二篇：zbar 、zxing和quirc）"
date: 2020-02-16 00:00:00 +0800
categories: [ROS2]
tags: [ROS2, 日积月累计划, linux, Mentor Xpedition, mdk]
description: ""
layout: article
csdn_id: 104301732
---

上一篇介绍了使用opencv和boofcv再嵌入式平台上的识别效果。这一篇继续使用上面的方法，依然使用python编写代码测试zbar和zxing的效果。

1、zbar测试

首先按照[pyzbar](https://pypi.org/project/pyzbar/)的教程安装完zbar。测试代码依然延续前面的。使用opencv读取视频流，使用zbar解码图片。操作比较简单。zbar除了qrcode还可以识别其它类型的条形码和其它类型二维码。我这里只测试qrcode的。代码如下：
[code] 
    import numpy as np
    from  pyzbar.pyzbar import decode
    from  pyzbar.pyzbar import ZBarSymbol
    import cv2
    import os
    import time
    
    
    video_path = '~/Downloads/'
    
    # VideoCapture
    cap = cv2.VideoCapture(0, cv2.CAP_V4L2)
    cap.set(3, 1280)
    cap.set(4, 720)
    cap.set(5, 30)
    
    # VideoWriter
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    outVideo = cv2.VideoWriter()
    outVideo.open('output.mp4',fourcc,10.0,(1280,720), True )
    
    # QRCodeDetector
    findQR = False
    qrResult = ''
    
    
    
    print('Demo will work')
    cnt = 0
    
    while(cap.isOpened()):
        ret, frame = cap.read()
        if ret==True:
            #frame = cv2.flip(frame,-1)
            outVideo.write(frame)
            
            # QR Code Detector
            if not fin
[/code]