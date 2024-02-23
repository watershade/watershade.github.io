---
title: 写在Ubuntu输入法卡死之后
category: Collection
date: 2024-01-26
permalink: /Collection/when_ibus_is_stuck/
---

# 写在Ubuntu输入法卡死之后
## 前言
Ubuntu自带的输入法一直很糟糕，早期版本甚至没有中文输入法，这是众所周知的。用上Ubuntu22.04之后发现自带有中文输入法，用着也能满足日常需求。
然而有一次我正在输入命令的时候，忽然输入法卡顿了。而我并不知道是输入法卡顿，还以为是自己的无线键盘出现的问题。在一番更换电池之后，频繁开关之后。似乎不那么卡了。
所以还以为确实是无线键盘的问题。我就像那些被做实验的猴子一样，把按按钮和吃到食物建立了强连接。知道我一段时间之后意识到了问题，因为我的电池是刚换的，不可能是电量的问题。
我忽然意识到这就是我输入法的问题，又一个线程卡顿了输入法线程导致过了很久输入法才将收到的字符慢吞吞的吐出来，这时候我的鼠标可能早就将指针指示到了某个位置了。

## 决定解决问题
### 1. 尝试使用fcitx5框架
今天实在受不了决定解决这个问题。网上建议我用fcitx来代替ibus。其实这一步没什么难度。
```bash
sudo apt update && sudo apt -y upgrade
sudo apt remove ibus
sudo apt autoremove
sudo apt install fcitx
sudo apt autoclean
```
但是如果使用fcitx安装的其实是fcitx4版本，其实有更新的版本fctix5.
其实fcitx下有很多输入法，有rime，pinyin，新酷音之类的。你需要选择一款安装：
```bash
# fcitx5-chewing包 是流行的繁体中文注音输入引擎，它基于 libchewing包。
# fcitx5-chinese-addons包 包含与中文相关的 addon，例如拼音、双拼和五笔。
# fcitx5-rime包 使用 Rime 引擎。
# fcitx5-mcbopomofo-gitAUR McBopomofo 支持。
# rime-flypyAUR 小鹤音形支持。

# 如果你想要安装rime输入法
sudo apt install fctix5-rime

# 如果你要安装拼音输入法
sudo apt install fcitx5-pinyin

# 如果你要安装新酷音，但好像是繁体，我没有安装
sudo apt install fcitx5-chewing

# 还有一个中文相关的包
sudo apt install fcitx5-chinese-addons

```
然后重启。
之后在shell里面输入`im-config`后逐步选择fcitx5就可以了。

### 2. rime的问题
我安装的是rime，安装完之后使用fcitx5 Configuration工具进行配置。
![fcitx5 config toll](img/fcitx5_cfg.png)
具体的方法我就不在赘述，因为UI比较简单。总之将RIME输入法加进去就可以了。

但是在实际使用的时候，还遇到每次切换输入法都自动进入到繁体中文的问题。
所以又一番搜索，在[这里](https://gist.github.com/yagehu/7bec7492afd5ba846f99abb00c850d01)找到了解决办法。

这里转述如下：
* 先进入~/.local/share/fcitx5/rime/文件夹
* 然后创建名称为“default.custom.yaml”的文件
* 接着添加如下内容：
```txt
patch:
  schema_list:
    - schema: luna_pinyin_simp
    - schema: luna_pinyin
    - schema: luna_pinyin_fluency
    - schema: bopomofo
    - schema: bopomofo_tw
    - schema: cangjie5
    - schema: stroke
    - schema: terra_pinyin
  menu:
    page_size: 10
```
* 最后重启一下系统（有人说重启fcitx5），但是我的好像有些配置不生效。


（全文完）