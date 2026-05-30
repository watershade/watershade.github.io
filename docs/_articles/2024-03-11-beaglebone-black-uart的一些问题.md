---
title: "Beaglebone Black UART的一些问题"
date: 2015-07-07 00:00:00 +0800
categories: [ROS2]
tags: [Beagelebone专栏收录该内容, ROS2, 日积月累计划, linux, Mentor Xpedition]
description: ""
layout: article
csdn_id: 46797315
---

说明：以上测试实在BB-Black vision C上进行的，系统是linux3.8的。用的是2015年发布的debian系统，装在8gde SD卡上面。我是用USB连连接BBB到我的window主机上。然后通过putty配置ssh来控制bbb,这种方式简单高效。

BB-Black的UART加载是十分简单的，UART0是调试口，除外板子上实际支持UART1-5五个接口，但是在板子的设备树上并没有UART3.

![BBBUART](https://i-blog.csdnimg.cn/blog_migrate/aeba71733f2ba8243bae73f498b2e5f4.png)

但是其余的一般情况下足够使用。

因为新版本的改动很大，好在我的板子emcc上本身安装有之前版本的系统。这样还是可以安装BB-UART#的设备树到slots中的。

不妨到/lib/firmware下面用ls *UART*搜索一下，会发现新的UART是adufruit的。不过在/目录下用find . -name *BB-UART* 还是可以搜索到相关的树在/media文件夹里面。

列举关键目录：

export SLOTS=/sys/devices/bonecapemgr.#/slots

通过echo BB-UART# > #SLOTS可以在/dev目录中添加ttyO#操作目录，进入这个操作目录，使用ls可以看到相关内容。

如果你没有在bbb上安装串口工具你只能使用echo发送一些指令，但是想查看串口收到的数据使用cat当然不行，不过你试试无妨。那么问题来了安装什么软件，如果安装串口工具。

上面别人都讲过了所以我讲的很粗略。下面是重点。

（1）安装minicom失败

最初我把BBB连上网可是使用apt-get不能安装软件，于是就更换方法。我从https://alioth.debian.org/projects/minicom/下载minicom 2.7，拷贝到SD上，再用复制命令拷贝到/home/App目录(这个目录是自建的)，接着解压命令解压到所在文件夹下，读reame文件，按照指令安装。但是安装不成功。

先使用./configure运行正常，可是到了make时就出现两个错误。make install这一步当然就不行了。

（2）安装Ncurses成功

最初以为版本问题更换2.6还是不行，就怀疑是缺少依赖项。然后了解需要Ncurses软件，就从http://directory.fsf.org/wiki/Ncurses上下载最新的软件。将下载文件移动到SD卡里面(在windows里面插上BBB之后自动挂载的SD磁盘)。这时我通过终端找到/media/BEAGLEBONE/App就看到我拷贝进去的ncurses-5.9.tar.gz和minicom-2.7.tar.gz。

cd /media/BEAGLEBONE/App

ls 

就可以看到拷贝完成的文件。

然后拷贝文件，你也可以直接解压(使用tat zxvf -C命令)：

cp -p ncurses-5.9.tar.gz /opt

cp -p minicom-2.7.tar.gz/ /opt

接着解压，因为这两个文件各自有文件夹，就不需要事先建立新文件夹了。

tar xvf ncurses-5.9.tar.gz

tat xvf minicom-2.7.tar.gz

然后查看，ls

就可以查看到两个文件夹了，分别是ncurses-5.9和minicom-2.7。文件夹的后面的数字和版本号有关，不要认死理。

进入ncurses-5.9文件夹，cd ncurses-5.9

下面就使用 ./configure 指令来生成与系统有关的makefile文件，接着使用make，最后make install就ok了。

这个过程差不多十五到二十分钟。

（3）安装minicom成功

进入minicom-2.7文件夹： cd ../minicom-2.7

这时按照上面相同的三个步骤:(1) ./configure (2) make (3) make install

如果不明白可以cat README就会卡看到指导。

这次成功了

(4) minicom -s 启动minicom

注意minicom的操作很变态的，需要先按ctrl+A松开之后按Z就会有指令提示。具体的你还是看教程吧

(5)如果对putty熟悉的你也可以使用putty，网站是http://www.putty.nl/download.html，然后搜索unix就可以看到适合unix和linux的软件了。不过这个我还没有试过。因为时间太晚了。如果有机会我会试试再写在这里。

（记录于2015-07.08凌晨0:50）