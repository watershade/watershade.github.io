---
title: "当Github启用PSA之后..."
date: 2024-03-06 00:00:00 +0800
categories: [ROS2]
tags: [ROS2, 日积月累计划, linux, Mentor Xpedition, mdk]
description: ""
layout: article
csdn_id: 136503685
---

## 当Github启用2FA之后…

因为github强制启用2FA（双因素二次认证），本来感觉只是网页登录的时候麻烦。因为大部分时候我们不需要每次都从网页登录。所以后面就设置了2FA，倒是问题不大。谁知道后面才发现还需要强制试用personal access token（个人登录令牌），操作似乎也不复杂，官方都有[详细的介绍](<https://docs.github.com/zh/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens>)。但是在这之后出现的问题却始料未及。

  1. vscode竟然不能push代码了。
  2. wsl或者linux里面也不能轻松的试用git命令push代码了。每次都需要输入用户名和密码。而且输入的还必须是你的personal access token.怎么办呐？

### 怎么办？

官方有这么一句：`使用 GitHub API 或命令行时，可使用 Personal access token 替代密码向 GitHub 进行身份验证。`. 你也许觉得不就是用一长串token代替了密码吗？搞那么复杂干嘛？其实并非这样。你不需要每次都输入personal access token。官方还有这样两个点的描述：

  * 若要从命令行访问 GitHub，可以使用 GitHub CLI 或 Git 凭据管理器，而不是创建 personal access token。
  * 在 GitHub Actions 工作流中使用 personal access token 时，请考虑是否可以改用内置 GITHUB_TOKEN。 有关详细信息，请参阅“自动令牌身份验证”。

官方也给出了[github CLI的链接](<https://docs.github.com/zh/github-cli/github-cli/about-github-cli>)和[Git 凭据管理器的链接](<https://github.com/git-ecosystem/git-credential-manager/blob/main/README.md>).

### Github CLI

程序员都直到CLI的意思：command line interface.翻译成中文就是命令行接口。官方对它的描述是：
[code] 
    GitHub CLI 是一个命令行工具，可将拉取请求、议题、GitHub Actions 和其他 GitHub 功能引入终端，使您可以在一个地方完成所有工作。
    
[/code]

安装并不复杂。我这里就说说wsl（debian）和windows里面怎么安装它。  
如果你的环境是debian系的，可以简单的通过`sudo apt install gh`来安装。当然它也是支持其它系统，比如windows，macos或其它版本的linux。欲了解详情，可查看[这里的详细描述](<https://github.com/cli/cli#installation>)。  
如果你想在windows里面安装，直接在终端（powershell）里面输入下面的命令`winget install --id GitHub.cli`即可完成安装。当然如果你用vscode打开本地项目，也可以在vscode的终端里面输入。本质是一样的。

### 方法1 （我自己是失败的）

安装完之后就可以直接操作了，官方也有[详细指导](<https://cli.github.com/manual/>).  
就是输入用户名:
[code] 
    gh auth login --hostname <hostname>
    
[/code]

然后会问你是试用https还是tts，默认https。（如果你的网络配置好了ssh，也可选择后者。）我直接选择https（点Enter）。  
接着第二个问题会问你git认证选择github认证？输入Y。  
第三个问题是你选择通过浏览器还是认证token认证？根据你的需要，前者比较简单。如果你试用过2FA认证流程即可。它会打开一个浏览器进行认证。后者是输入你的personal access token。根据需要即可。

但是如果你的网络有问题，会这样提示：
[code] 
    error connecting to <your username>
    check your internet connection or https://githubstatus.com
    
[/code]

我的github经常有这种问题，我不知道是该·诅+咒=谁。我打开`https://www.githubstatus.com/`测试也是正常的就是会提示这个错误。

你可以通过通过配置dns或者某种科学方式登录github之后，也要确保从命令行可以访问到github。

### 方法2 (我自己是成功的)

这次输入的命令稍微不同，试用的是：
[code] 
    gh auth login
    
[/code]

然后其它的路径相同。如果在wsl里面操作，不能选择浏览器打开（会失败，不过你可以试一下）。可以输入你的personal access token。 这次就成功了。成功的标志是：
[code] 
    ✓ Configured git protocol
    ✓ Logged in as <your username>
    
[/code]

### Git凭据管理器

我暂时没有试用这种方式。如果用到再来更新。