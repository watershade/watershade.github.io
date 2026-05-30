---
title: "Raspberry Pi 4B入手教程和注意事项"
date: 2020-09-20 00:00:00 +0800
categories: [Embedded Linux]
tags: [ROS2, 日积月累计划, linux, Mentor Xpedition, mdk]
description: ""
layout: article
csdn_id: 108023317
---

本文章随机更新，主要用来记录rpi4b遇到的问题和解决方案。

### Raspberry 4b的SD卡槽问题

Raspberry pi 4b的卡槽不带自动弹出功能。你也许觉得手动拔出也好，但问题其实出现再插入上。  
当你用了稍大的力气将sd卡塞进卡槽，发现怎么也调不准方向。这时忽然可以插进卡槽，你以为这下好了。结果一下SD到底，用力过猛。SD卡断了。别以为我是胡说，因为我曾再另一款类似设计的SD卡上遭遇过。

### Raspberry 4b支持64bit os

也就是说，你可以选用64-bit的。现在已经不是数年前，64位才是主流。很多release出来的软件都在linux 64bits上测试过。而且以后会逐步淘汰32 bits

### 安装之后怎么查看版本

当然你也可以用uname -a，但是这个命令看不出debian的版本。  
建议使用
[code] 
    cat /etc/os-release
    
[/code]

不过这个命令看不到os版本

### Raspberry pi os 64-bits更换清华源

参考[此文档](https://mirror.tuna.tsinghua.edu.cn/help/raspbian/),根据正确版本执行换源操作
[code] 
    # 编辑 `/etc/apt/sources.list` 文件，删除原文件所有内容，用以下内容取代：
    deb http://mirrors.tuna.tsinghua.edu.cn/raspberry-pi-os/raspbian/ buster main non-free contrib rpi
    deb-src http://mirrors.tuna.tsinghua.edu.cn/raspberry-pi-os/raspbian/ buster main non-free contrib rpi
    
    # 编辑 `/etc/apt/sources.list.d/raspi.list` 文件，删除原文件所有内容，用以下内容取代：
    deb http://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ buster main ui
    
[/code]

### SSH连接时的密码和账户

在使用ssh连接raspberry pi时，需要知道ip地址。
[code] 
    ssh pi@192.168.xxx.xxx
    
[/code]

但是如果你没有屏幕要怎么查找呐？  
如果你们访问路由器，可以在连接列表里面直接查看。但是如果比没有路由器的访问权限呐？  
可以使用局域网扫描工具来完成。  
此外还需要设法在制作的raspberry pi镜像根目录下建立一个名为"SSH"的文件。这样就开启了SSH服务

### 静态IP设置

当你没有屏幕的时候，可能需要ssh连接。但是此时的ip地址是自动分配的。你可以通过查看连接的路由器找到树莓派的ip，但是这样优惠重新建立一个新的ssh连接配置。不是特别好。  
所以需要设置静态IP。  
可以通过修改/etc/network/interfaces。但是如果你打开这个文件之后。会告诉你可以用"man dhcpcd.conf"来查看怎么设置静态IP。其实就是修改/etc/dhcpcd.conf。里面有个示例:
[code] 
     # wlan0 for wifi
    interface eth0                       
    # your expect static ip                                                                                                                                                                                                  
    static ip_address=192.168.1.121/24                                                                                                                                                                                                                                                                                                                                                                                                        static ip6_address=fd51:42f8:caae:d92e::ff/64                                                                                                                                                                                                                                                                                                                                                                              # your expect route                                                                                                                                                                                                                  
[/code]