---
title: "用不同的QR Code识别库实现二维码的识别（第一篇：opencv 和BoofCV）"
date: 2020-02-14 00:00:00 +0800
categories: [ROS2]
tags: [ROS2, 日积月累计划, linux, Mentor Xpedition, mdk]
description: ""
layout: article
csdn_id: 104292102
---

最近有个项目需要实现二维码的识别和摄像头的数据采集。在开始正式项目之前，我决定用python写几行简单的代码来测试每个库的识别效果。这次没有连续测量，也没有使用多线程识别。只是简单的测试了每个二维码的测试效果。这次测试的有opencv 4.2的QRCodeDetector库，BoofCV的库，Quirc，Zbar和ZXing。视频的采集统一使用cv的VideoCapture，视频的存储统一使用cv的VideoWriter。我的硬件环境是orange pi 3 的2G内存版，系统是armbian的Debian GNU/Linux 10 (buster)。事先已经配置好了opencv、java和PyBoof等必备条件。

1、首先测试的是opencv

代码如下（附件test_qr.py）：
[code] 
    import numpy as np
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
    outVideo.open('output.mp4',fourcc,30.0,(1280,720), True )
    
    # QRCodeDetector
    findQR = False
    qrResult = ''
    qrDetector = cv2.QRCodeDetector()
    
    
    
    
    print('Demo will work')
    cnt = 0
    
    while(cap.isOpened()):
        ret, frame = cap.read()
        if ret==True:
            #frame = cv2.flip(frame,-1)
            outVideo.write(frame)
     
[/code]