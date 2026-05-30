---
title: "ubuntu22.04安装swagboot遇到的问题"
date: 2023-11-26 00:00:00 +0800
categories: [ROS2]
tags: [ROS2, 日积月累计划, linux, Mentor Xpedition, mdk]
description: ""
layout: article
csdn_id: 134635050
---

### 一、基本情况

系统：u 22.04

python： 3.10

### 二、问题描述

swagboot官方提供的安装路径言简意赅:`python3 -m pip install --user snagboot`  
当然安装python3和pip是基本常识，这里就不再赘述。  
可是在安装的时候出现如下提示说 Failed building wheel for pylibfdt”  
我尝试单独安装pylibfdt也提示类似信息。那怎么办呐？网上一时也没看到解决办法。

### 三、解决问题

去了[pypi去查看pylibfdt](<https://pypi.org/project/pylibfdt/>)的描述.发现这个库依赖一些文件：
[code] 
    This tree contains a copy of libfdt from the upstream dtc project for the
    purposes of pypi.org packaging. Other than changes to the packaging files,
    changes should be made upstream. The upstream sources are here:
    
    git://git.kernel.org/pub/scm/utils/dtc/dtc.git
    
    
    To install this you will need to install swig and Python development files.
    
    On Debian distributions:
    
       sudo apt-get install swig python3-dev
    
    
    The module can be installed with pip:
    
       pip install libfdt
    
    or 
[/code]