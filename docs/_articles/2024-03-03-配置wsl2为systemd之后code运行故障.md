---
title: "配置wsl2为systemd之后code运行故障"
date: 2024-03-03 00:00:00 +0800
categories: [notes]
tags: []
description: ""
layout: article
csdn_id: 136429411
---

## 配置wsl2为systemd之后code运行故障

### 现象

前段时间忘记测试什么的时候将wsl2升了级，并添加了一个文件/etc/wsl.conf，文件内容如下：
[code] 
    [boot]
    systemd = true
    
[/code]

这段是启用systemd。关于systemd的知识请看[《使用 systemd 通过 WSL 管理 Linux 服务》](<https://learn.microsoft.com/zh-cn/windows/wsl/systemd>).

这几天一直从vscode 通过remote方式直接打开wsl里面的内容进行编辑，通常没有什么问题。但是今天在ubuntu里面尝试使用`code .` 命令打开一个新的文件夹时却出现了问题,提示：
[code] 
    /mnt/c/Users/watershade/AppData/Local/Programs/Microsoft VS Code/Code.exe: Exec format error
    
[/code]

### 解决

这个问题不难解决，因为我一搜索就找到了这篇[github的issue](<https://github.com/microsoft/vscode/issues/189694>)和[其中提到的另一个issue](<https://github.com/microsoft/WSL/issues/8952>).  
基本解决办法如下：
[code] 
    sudo sh -c 'echo :WSLInterop:M::MZ::/init:PF > /usr/lib/binfmt.d/WSLInterop.conf'
    sudo systemctl restart systemd-binfmt
    
[/code]

文中有人提到了更复杂的办法：
[code] 
    sudo sh -c 'echo :WSLInterop:M::MZ::/init:PF > /usr/lib/binfmt.d/WSLInterop.conf'
    sudo systemctl unmask systemd-binfmt.service
    sudo systemctl restart systemd-binfmt
    sudo systemctl mask systemd-binfmt.service
    
[/code]

其实后者时前者的扩充。我直接用前者就解决了问题。文中也介绍了原因：
[code] 
    The issue is that enabling systemd somehow alters /proc/sys/fs/binfmt_misc/
    The file (or filelike??) entry WSLInterop.conf goes missing.
    
    问题出现在使能systemd 之后，因为某种原因导致了WSLInterop.conf文件丢失。
    
[/code]

### 说明

这个问题的解决没什么复杂的地方。但是还是记录一下以供有类似问题的朋友检索。