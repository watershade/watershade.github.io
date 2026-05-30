---
title: "烧写Armbian image的NanoPi NEO Core和WiringNP库 【日积月累计划】"
date: 2021-03-23 00:00:00 +0800
categories: [ROS2]
tags: [ROS2, 日积月累计划, linux, Mentor Xpedition, mdk]
description: ""
layout: article
csdn_id: 115118189
---

### 背景介绍

基本不用官方镜像，通常给NanoPi 烧写Armbian镜像。本次使用的NanoPi Neo Core也是烧写的此固件。  
NanoPi基于WiringPi这个开源库自己做了一个WiringNP库，可用来操作GPIO接口。从https://github.com/friendlyarm/WiringNP/blob/master上copy，编译安装之后。运行`bash gpio readall`之后。提示一下错误：
[code] 
    piBoardRev: Unable to determine board revision from /proc/cpuinfo
     -> Is not NanoPi based board.
     ->  You may want to check:
     ->  http://www.lemaker.org/
    open /sys/class/sunxi_info/sys_info failed
    
[/code]

### 分析

其实这个问题已经很清晰了。尝试查找/sys/class/sunxi_info/sys_info文件失败。因此识别不了板子的型号。  
最初的想法是将讲官方镜像的/sys/class/sunxi_info/sys_info拷贝过来。但是暂时手边没有安装这个文件的板子。就想着能不能找来替换一下。但是在搜索的过程中却找到了另一种方法。

### 解决方法

这个解决方法我的思路类似。不过这里的方法是新创建了一个新文件/etc/sys_info（我想是为了防止冲突吧）。将本该填入/sys/class/sunxi_info/sys_info的内容填写到/etc/sys_info中。

#### 1、 添加/etc/sys_info文件

比方说Nanopi Neo应该添入的文件如下：
[code] 
    sunxi_platform    : Sun8iw7p1
    sunxi_secure      : normal
    sunxi_chipid      : 2c21020e786746240000540000000000
    sunxi_chiptype    : 00000042
    sunxi_batchno     : 1
    sunxi_board_id    : 1(0)
    
[/code]

#### 2、修改boardtype_friendlyelec.c文件

然后修改WiringNP目录下的wiringPi/boardtype_friendlyelec.c文件。  
搜索/sys/class/sunxi_info/sys_info会发现如下命令
[code] 
    if (!(f = fopen("/sys/class/sunxi_info/sys_info", "r"))) {
       
       
            LOGE("open /sys/class/sunxi_info/sys_info failed.");
            return -1;
        }
    
[/code]

这行命令就是导致出错的原因。  
现在的做法就是如果读不到/sys/class/sunxi_info/sys_info在让其尝试读取我们新添加的文件/etc/sys_info。  
命令如下：
[code] 
    if (!(f = fopen("/sys/class/sunxi_info/sys_info", "r"))) {
       
       
       if (!(f = fopen("/etc/sys_info", "r"))) {
       
       
           LOGE("open /sys/class/sunxi_info/sys_info failed.");
           return -1;
       }
    }
    
[/code]

#### 3、针对性修改

而不同板子的添加/etc/sys_info文件的信息是不同的。上面的信息会被读取到一个结构体中：
[code] 
    typedef struct {
       
       
    	char kernelHardware[255];
    	int kernelRevision;
    	int boardTypeId;
    	char boardDisplayName[255];
    	char allwinnerBoardID[255];
    } BoardHardwareInfo;
    
[/code]

其中boardTypeId和allwinnerBoardID很重要。不同板子是不同的。  
可以通过查看wiringPi/boardtype_friendlyelec.c找到。
[code] 
    BoardHardwareInfo gAllBoardHardwareInfo[] = {
       
       
        {
       
       "MINI6410", -1, S3C6410_COMMON, "S3C6410_Board", ""},
        {
       
       "MINI210",  -1, S5PV210_COMMON, "S5PV210_Board", ""},
        {
       
       "TINY4412",
[/code]