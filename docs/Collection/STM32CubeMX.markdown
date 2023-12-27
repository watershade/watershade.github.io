---
title: STM32CubeMX的Ubuntu桌面图标生成脚本
permalink: /Collection/CUbeMX_Icon_In_Ubuntu/
---

# STM32CubeMX的Ubuntu桌面图标生成脚本
## 一、概述
每一次在Ubuntu上安装STM32CubeMX都会遇到桌面图标的问题。每次都要跑到相应目录下运行，十分繁琐。
如果每次都要编写desktop文件倒也不难，但是有时候总是记错要CUbeMX_Icon_In_Ubuntu将放入的路径。有时候也忘记icon文件的位置。
要解决这个问题其实也不是很难，那就固化成一个固定的脚本。

## 二、制作脚本前要确认的几个问题
目前我的脚本针对的是CubeMX6.10.0，但是理论上在其它版本也可以。为了确保其它版本可以正常运行，而且各种依赖也都是完善的（主要是java），我们需要按照下面的几个问题一一确认清楚。

### 2.1 需要先确认一下CubeMX能否正常运行
其实最简单的方法是双击CubeMX，如果不能执行的话首先检查一下文件权限。可以使用命令`chmod u+x STM32CubeMX`即可。你也可以通过鼠标右键更改属性。这里就不再截图了。

### 2.2 可能会遇到java问题
cubemx会优先检查一下系统安装的jre版本满不满足要求，如果不满足就会使用自带的jre工具。但是我遇到过一个问题：当我试图从其它路径下运行CubeMX的时候，提示了路径错误的问题。大概意思就是找不到STM32CubeMX/./jre路径之类的。
这个问题其实也不难解决，就是看一下cubemx的安装目录下的jre文件夹的version文件里面包含的jre版本即可。这时候安装一下相应的jre版本就行。（复杂的是可能你的系统不同的软件需要不同的jre版本这就挺难解决的）
尽管不建议单独安装jre，但是我还是提供一下jre的安装方法：`sudo apt install openjdk-17-jre`. 这个17版本是针对CubeMX 6.10.0版本的。其它版本需要安装对应的。可以用`sudo apt search openjdk`去搜索一下目前的ubuntu是否支持直接安装你需要的jdk版本。

### 2.3 icon图标的位置
现在版本的icon图标在help里面，建议手动检查一下。

### 2.4 检查一下目前的桌面路径下是否有desktop文件
这个的目的其实是为了后面检查准备的。因为Ubuntu22.04的个人桌面文件所存放的路径在`~/.local/share/applications/`下面。


## 三、脚本文件
我这里直接提供[脚本文件](./appendix/create_icon.sh),但有可能下载不了。所以我这里也提供脚本代码：
```bash
#!/bin/bash

## Try to install jdk please check the needn't version
# sudo apt install openjdk-17-jre

WKDIR=$(cd $(dirname $0); pwd) 

## Start to add desktop file
#echo '[Desktop Entry' > STM32CubeMX.desktop
#echo 'Name=STM32CubeMX' > STM32CubeMX.desktop
#echo 'GenericName=STM32 Config Tool' > STM32CubeMX.desktop
cat>STM32CubeMX.desktop<<EOF
[Desktop Entry]
Name=STM32CubeMX
GenericName=STM32 Config Tool
Categories=Development
Comment=STM32CubeMX
Exec=java -jar $WKDIR/STM32CubeMX
Icon=$WKDIR/help/STM32CubeMX.ico
Path=$WKDIR
Terminal=true
Type=Application
StartupNotify=true
EOF

# copy desktop to target folder
cp STM32CubeMX.desktop $HOME/.local/share/applications/
```

## 四、注意事项
为了防止你对linux不熟悉，这里还是说一下注意事项。
请将下载的脚本放到STM32CubeMX的顶级目录下（就是可执行文件所在的目录）。
比如我的脚本放入之后的目录情况如下：
```txt
.
├── auto-install.xml
├── create_icon.sh
├── db
├── help
├── jre
├── olddb
├── plugins
├── STM32CubeMX
├── third_parties_plugins
├── Uninstaller
└── utilities
```
其中create_icon.sh就是脚本文件。如果不能下载你可以新建一个以sh为后缀的脚本文件，并将上面的内容粘贴到脚本里面。

然后你需要让这个脚本有执行权限，你可以执行`chmod u+x create_icon.sh`即可。当然你也可以右键更改属性。

最后在终端里执行脚本即可"./create_icon.sh"

(全文完)