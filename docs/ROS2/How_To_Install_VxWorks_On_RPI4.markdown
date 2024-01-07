---
title: Rapberry Pi 4 安装VxWorks笔记
permalink: /ROS2/How_To_Install_Vxworks_On_PRI4/
---

# Rapberry Pi 4 安装VxWorks笔记

## 一、概述
ROS2推荐的操作系统是ubuntu,众所周知，linux并不是实时操作系统。即便是RTLinux,它的实时性在各种报道中似乎也不正面（我没有用过RTLinux,所以不具备发言权）。刚好在某个新闻中看到VxWorks提供了对Rapberry Pi的免费支持。这对我这种穷苦码农来说确实是正规接触VxWorks的一个机会。另一方面VxWorks对ROS2也有一定的支持，这也给我尝试在RPI4（Rapberry Pi 4 后面简写为RPI4）上安装VX（VxWorks后面简写做VX）很大的动力。当然后面如果可能我们尝试Micro-ROS on ThreadX也不是不可以。只是还要一直ThreadX,然后安装Micro-ROS,想想都觉得有难度。

## 二、跟着官方教程按图索骥
官方提供了几个[BSP](https://bsp.windriver.com/bsps/3329)，号称是Open Source的。后来终于在Vx的[官网某处](https://forums.windriver.com/t/vxworks-software-development-kit-sdk/43)搜到了详细的安装资源。
### 2.1 安装官方提到的依赖项目
我当前使用的是ubuntu22.04 amd64版本，官方提到的依赖其实已经默认安装了。不过这里还是转述一下：
```shell
sudo apt install build-essential libc6:i386
```
因为当前版本安装的是python3，如果只是需要一个ftp不需要安装python2版本的pip。我的操作如下：
```shell
sudo apt install python3-pip
sudo pip install pyftpdlib
```
### 2.2 下载RPI4的firmware
这个firmware托管在github，网址是https://github.com/raspberrypi/firmware/。。官方没有做成release版本的，所以直接点击tags就可以找到最近的你想下载的那个版本的firmware。我下载的是最新的1.20230405。
下载完成之后解压，然后copy或者剪切整个boot目录到sd卡即可。这里用{sd根目录}表示我的sd卡挂载的位置。
```shell
tar -xzf firmware-1.20230405.tar.gz
cd firmware-1.20230405
cp -rL boot/*  {sd根目录}
#剪切完成之后，确认一下
ls {sd根目录}
```
解压会比较快，但是剪切过程会需要一定的时间。

### 2.3 编译u-boot
U-Boot的托管仓库有两个一个是[denx](https://source.denx.de/u-boot/u-boot)一个是github。你根据需要下载。具体的教程可以查看[u-boot docs](https://docs.u-boot.org/en/latest/).
我这里没有将整个仓库克隆下载，而是直接下载2023年10月份的版本。下载完之后解压：
```shell
tar -xzf u-boot-2023.10.tar.gz 
cd u-boot-2023.10
```
使用u-boot需要安装交叉编译环境，安装一下：
```shell
sudo apt install gcc-aarch64-linux-gn

## 官方文档提供的额外包安装，我暂时没有全部安装
sudo apt-get install bc bison build-essential coccinelle \
  device-tree-compiler dfu-util efitools flex gdisk graphviz imagemagick \
  liblz4-tool libgnutls28-dev libguestfs-tools libncurses-dev \
  libpython3-dev libsdl2-dev libssl-dev lz4 lzma lzma-alone openssl \
  pkg-config python3 python3-asteval python3-coverage python3-filelock \
  python3-pkg-resources python3-pycryptodome python3-pyelftools \
  python3-pytest python3-pytest-xdist python3-sphinxcontrib.apidoc \
  python3-sphinx-rtd-theme python3-subunit python3-testtools \
  python3-virtualenv swig uuid-dev

# 上面的包我没有都安装，根据后面的错误提示我额外安装了bison和flex
sudo apt-get install bison flex

```
接着配置u-boot，可参照官方针对rpi的[配置说明](https://docs.u-boot.org/en/latest/board/broadcom/raspberrypi.html)和[build 说明](git clone https://source.denx.de/u-boot/u-boot.git)。其实命令很简单，但是我的出现了错误提示。之后我又重新clone了一下u-boot仓库，接着配置：
```shell
# 下载很慢
git clone https://source.denx.de/u-boot/u-boot.git
# 改用github
git clone https://github.com/u-boot/u-boot.git

cd u-boot
# 选择版本
git checkout v2023.10

# config/配置
CROSS_COMPILE=aarch64-linux-gnu- make rpi_4_defconfig

# build/编译
CROSS_COMPILE=aarch64-linux-gnu- make

# copy or move/复制到sd卡中,并更名为u-boot-64.bin
cp u-boot.bin {sd根目录}/u-boot-64.bin

#检查文件是否存在
ls {sd根目录}
```
### 2.4 拷贝
在第二章的开头提到了那个官方的raspberry pi相关的VX7 sdk资源。我选择了下载[VxWorks SDK for Raspberry Pi 4 v1.5.1](https://d13321s3lxgewa.cloudfront.net/wrsdk-vxworks7-raspberrypi4b-1.5.1.tar.bz2)。[注：点击前面的链接就可跳转到下载资源]

这个版本是VX 23.03，如图所示.
![VX7 SDK for RPI](img/vx7sdk_rpi.png)
<p style="text-align:center; color:orange">图1：VX7 SDK for RPI </p>
然后我们解压文件，并拷贝必要目录到SD卡。

```shell
## 解压时间也较长，毕竟压缩包都八百多兆。
tar -xjf wrsdk-vxworks7-raspberrypi4b-1.5.1.tar.bz2
cd wrsdk-vxworks7-raspberrypi4b
ls -al
# 可以看到有一个vxsdk的目录，进入
cd vxsdk
ls -al
## 这里面有4个文件夹，其中的sdcard和bsps就是我们待会要用到的目录。
## 拷贝的时间会稍长，需要耐心等待
cp -rL sdcard/*  {sd根目录}

## 官方的readme说法是只复制uVxWorks
cp bsps/rpi_4_0_1_3_0/uVxWorks {sd根目录}

## 我的做法是将整个rpi_4_0_1_3_0目录复制过去
cp -rL bsps/rpi_4_0_1_3_0/* {sd根目录}
```
需要说明的是，拷贝的时候不要将sdcard和rpi_4_0_1_3_0目录拷贝进去，而是将这两个目录的内容拷贝到sd卡的根目录下。

### 2.5 启动
连接RPI4的8，9，10三个引脚到USB串口（TTL电平）上。具体请查看下图：
![RPI4 signal](img/树莓派引脚信号图.png)
<p style="text-align:center; color:orange">图2：树莓派引脚信号图 </p>

* 8:GPIO14(TXD) 连接串口的RXD
* 9:GND 连接串口的GND
* 10:GPIO15(RXD) 连接串口的TXD
你会发现输出如下所示：
```shell
U-Boot 2023.10 (Jan 06 2024 - 19:32:58 +0800)

DRAM:  948 MiB (effective 1.9 GiB)
RPI 4 Model B (0xb03112)
Core:  209 devices, 15 uclasses, devicetree: board
MMC:   mmcnr@7e300000: 1, mmc@7e340000: 0
Loading Environment from FAT... OK
In:    serial,usbkbd
Out:   serial,vidconsole
Err:   serial,vidconsole
Net:   
Warning: ethernet@7d580000 MAC addresses don`t match:
Address in DT is                dc:a6:32:c8:21:09
Address in environment is       dc:a6:32:07:b3:a4
eth0: ethernet@7d580000
Hit any key to stop autoboot:  0 
15767528 bytes read in 677 ms (22.2 MiB/s)
## Booting kernel from Legacy Image at 00100000 ...
   Image Name:   vxworks
   Image Type:   AArch64 VxWorks Kernel Image (uncompressed)
   Data Size:    15767464 Bytes = 15 MiB
   Load Address: 00100000
   Entry Point:  00100000
   Verifying Checksum ... OK
Working FDT set to 0
   Loading Kernel Image
   !!! WARNING !!! Using legacy DTB
## Starting vxWorks at 0x00100000, device tree at 0x00000000 ...
Instantiating /ram0 as rawFs,  device = 0x1
Formatting /ram0 for HRFS v1.2
Instantiating /ram0 as rawFs, device = 0x1
Formatting...OK.
Target Name: vxTarget 
Instantiating /tmp as rawFs,  device = 0x10001
Formatting /tmp for HRFS v1.2
Instantiating /tmp as rawFs, device = 0x10001
Formatting...OK.
 
 _________            _________
 \........\          /......../
  \........\        /......../
   \........\      /......../
    \........\    /......../
     \........\   \......./
      \........\   \...../              VxWorks SMP 64-bit
       \........\   \.../
        \........\   \./     Release version: 23.09
         \........\   -      Build date: Sep 19 2023 16:16:34
          \........\
           \......./         Copyright Wind River Systems, Inc.
            \...../   -                 1984-2023
             \.../   /.\
              \./   /...\
               -   -------

                   Board: Raspberry Pi 4 Model B - ARMv8
               CPU Count: 4
          OS Memory Size: ~883MB
        ED&R Policy Mode: Deployed
     Debug Agent: Started (always)
         Stop Mode Agent: Not started
              BSP Status: *** UNSUPPORTED ***

Instantiating /ram as rawFs,  device = 0x50001
Formatting /ram for DOSFS
Instantiating /ram as rawFs, device = 0x50001
Formatting...Retrieved old volume params with %38 confidence:
Volume Parameters: FAT type: FAT32, sectors per cluster 0
  0 FAT copies, 0 clusters, 0 sectors per FAT
  Sectors reserved 0, hidden 0, FAT sectors 0
  Root dir entries 0, sysId (null)  , serial number 5b0000
  Label:"           " ...
Disk with 64 sectors of 512 bytes will be formatted with:
Volume Parameters: FAT type: FAT12, sectors per cluster 1
  2 FAT copies, 54 clusters, 1 sectors per FAT
  Sectors reserved 1, hidden 0, FAT sectors 2
  Root dir entries 112, sysId VXDOS12 , serial number 5b0000
  Label:"           " ...
OK.
Thu Jan  1 00:00:01 1970: ipnet[44a0f0]: Error: ipcom_getsockaddrbyaddr failed gw: dhcp

 Adding 22707 symbols for standalone.

-> 
```



### 2.6 启动
如果你连接HDMI到屏幕上，屏幕会显示如下信息：
![Vx for RPI4 on HDMI](img/VxWorks_RPI4_HDMI.jpeg)
<p style="text-align:center; color:orange">图3：通过HDMI显示 </p>
可以看到通过HDMI并没有显示完整的信息。

在这一个步骤我以为折腾了很久，发现如果更改为串口连接就可以。（串口连接之前也出错了，所以没排查出来问题。）

### 3.0 资源
为了后面方便浮现和烧写，我将整个镜像放置在github上。你可以尽情享用。
仓库链接


## 附件
* [官方下载链接](https://forums.windriver.com/t/vxworks-software-development-kit-sdk/43)
* [VxWorks 7 SDK for Raspberry Pi 4](https://labs.windriver.com/downloads/wrsdk-vxworks7-docs/2309/README_raspberrypi4b.html)
* [micro-ROS](https://micro.ros.org/docs/overview/rtos/)
* [ROS 2 for VxWorks Developer Brief](https://www.windriver.com/resource/ros-2-for-vxworks-developer-brief)
* [vxworks7-ros2-build github repository](https://github.com/Wind-River/vxworks7-ros2-build)
* [vxworks7-layer-for-ros2 github repository](https://github.com/Wind-River/vxworks7-layer-for-ros2)
* [ROS 2 ON VXWORKS present](https://roscon.ros.org/2019/talks/roscon2019_ros2onvxworks.pdf)
* [ROS2 on VxWroks Discuss](https://discourse.ros.org/t/ros2-on-vxworks-rtos/9806/2)