---
title: "raspberry pi 4b安装quirc"
date: 2020-11-01 00:00:00 +0800
categories: [Embedded Linux]
tags: [ROS2, 日积月累计划, linux, Mentor Xpedition, mdk]
description: ""
layout: article
csdn_id: 108235333
---

1、安装quirc需要sdl，所以首先安装sdl库

sdl的[安装指导](http://wiki.libsdl.org/Installation)中，有关于raspberry pi安装sdl的方法。你可以按照unix mode安装依赖项，编译然后安装。最简单的是使用[预编译库](https://buildbot.libsdl.org/sdl-builds/sdl-raspberrypi/?C=M;O=D)安装。在预编译库中已经数字大的表示最近的预编译库。但是对于rpi 4b 64位，我担心不适配。所以还是决定自己编译。

可以参考编译安装指导的教程。这里不再赘述。

也可以尝试使用下面命令安装。（但安装的时候除了一些错误，所以最终还是选择编译）
[code] 
    sudo apt-get install libsdl2-2.0 libsdl2-dev 
[/code]

【其实make quirc的时候不需要这个，只是测试的时候需要。所以也可以选择绕过】

2、修改makefile文件

原来的makefile文件会捎带上测试程序一起。如果单纯的只是像使用quirc的化，其实可以不用编译这些文件。这样就不用安装那么多依赖项。否则也可以参考makefile里面的需求，一个一个安装。

3、mkdir build ; make -j# ..; sudo make install

4、制作一个quirc.pc文件，将其放在/usr/local/libs/pkgconfig/下。文件可以简单写为下面的形式：
[code] 
    # sdl pkg-config source file                                                                                                                                                                                                                                                                                                                                                                                                                                                              prefix=/usr/local                                                                                                                                                                                                                            exec_prefix=${prefix}                                                                                                                                                                                                                        libdir=${exec_prefix}/lib                                                                                                                                                                                                                    includedir=${prefix}/include                                                                                                                                                                                                                                                                                                                                                                                                                                                              Name: quirc                                                                                                                                                                                                                                  Description: QR codes are a type of high-density matrix barcodes, and quirc is a library for extracting and decoding them from images.                                                                                                       Version: 1.0                                                                                                                                                                                                                                 Requires:                                                                                                                                                                                                                                    Conflicts:                                                                                                                                                                                                                                   Libs: -L${libdir} -lquirc                                                                                                                                                                                                                    Cflags: -I${includedir}
[/code]

当然你要先安装pkg-config才可以。否则，你需要ldconfig等别的方式来添加库和路径。

5、在自己的工程中添加形如下面这样的形式
[code] 
    CXXFLAGS += -c -Wall -std=c++11 $(shell pkg-config --cflags quirc)                                                                                                                                                                   LDFLAGS += $(shell pkg-config --libs --static quirc)                                                                                                                                                                                                                                                                 
[/code]