---
title: logitech k380键盘在ubuntu上的问题和解决方案
permalink: /Collection/logitech_k380_on_ubuntu_issues/
---

# logitech k380键盘在ubuntu上的问题和解决方案
k380是一款外观比较精致的小键盘，同时支持蓝牙和2.4G.而且支持多按键切换，这样相当于一个简易的kvm。但是这个按键在ubuntu上有很多体验问题。这里说的问题不是指键盘本身的手感、反应等问题。而更多是软件体验的问题。

本文持续记录ubuntu上使用k380按键的种种问题。有一些有解决办法，另一些则可能永远没有答案。

## K380上的fn key问题
k380上的fn按键默认是关闭的。在windows、macos上有专门的工具负责（好像叫option+）。但是在ubuntu上并没有。网上有一个很热门的软件Solaar，但是这个软件有这样的说明：`Solaar only supports Logitech receivers and devices that use the Logitech proprietary HID++ protocol.`。支持列表里并没有k380.

还在github上有大神提供了一个软件可以解决ubuntu上的按键体验。软件名字叫[k380-function-keys-conf](https://github.com/jergusg/k380-function-keys-conf)，这个软件可以解决k38的键盘问题。点击前面的链接就可以跳转到github项目主页。我在ubuntu上实际体验了，确实解决了我的问题。

具体步骤也比较简单：
1. 安装必备的依赖项。主要是build-essential的一些软件。
2. make和install
3. 使用软件。
具体步骤我就不引用了，用户可以跳转到仓库里查看。

## 双系统按键问题
我的电脑装的是双系统。k380如果之前和我的一个系统配过对，如果下一次重启切换到另一个系统按键很神奇的处于连接但是不配对状态。需要在系统里删除这个蓝牙键盘，然后重新识别。如果使用2.4G就没有这个问题。


