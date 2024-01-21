---
title: ROS2 Humble学习笔记 (2)
permalink: /ROS2/ROS2_Humble_Learning_Note_2/
---

# ROS2 Humble学习笔记 (2)

## 一、前言
在[上一篇学习笔记](https://watershade.github.io/ROS2/ROS2_Humble_Learning_Note_1/)中，我们学习ROS2的一些基本概念，主要是官方入门教程中的[Beginner: CLI tools](https://docs.ros.org/en/humble/Tutorials/Beginner-CLI-Tools.html)部分。现在我们继续学习[Beginner: Client libraries](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries.html).这部分将设计到ROS2的编程和代码等部分。通过这一部分学习，也能够对于ROS2的一些基本概念有更深入的理解。

## 二、ROS2编程基础
这篇笔记将记录在学习官方入门教程[Beginner: Client libraries](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries.html)部分的具体内容和尝试遇到的问题，以及一些额外的思考。

### 2.1 Colcon入门
本小节内容主要参考[Colcon Tutorial](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Colcon-Tutorial.html)和[A universal build tool](https://design.ros2.org/articles/build_tool.html)。


#### 2.1.1 Colcon的设计原则
在 ROS 生态系统中，软件被分成许多软件包。开发人员同时开发多个软件包的情况非常普遍。这与工作流程形成了鲜明对比，在工作流程中，开发人员一次只开发一个软件包，所有依赖关系都是一次性提供的，而不是不断迭代。

"手动"构建软件包的方法包括按照拓扑顺序逐个构建所有软件包。对于每个软件包，文档通常都会说明依赖关系是什么、如何设置环境来构建软件包，以及之后如何设置环境来使用软件包。如果没有一个能自动完成这一过程的工具，这样的工作流程在大规模的情况下是不可行的。

因此，ROS2的设计者就希望设计一个统一构建（build）工具，通过一次调用完成一组软件包的构建。它应当同时支持ROS1（向后兼容）和ROS2的软件包的构建。如果必要的元信息可以通过推断和/或外部提供的方式获得，那么它还能与那些本身不提供清单文件的软件包协同工作。这样，构建工具就能用于非 ROS 软件包（如 Gazebo，包括其点火依赖项、sdformat 等）。

尽管在ROS的生态系统中，有几种工具满足上述要求。大多都大同小异，因为是单独开发的，很多时候某些必要功能只存在与某个构建工具中。这就是为什么ROS2的设计者希望一个功能完善的统一构建工具的原因。想一想Python中数量繁多的包管理和依赖解决工具带来的后果。另外作者也提到了这样一个问题，这确实更能说明他们希望的构建工具到底是什么：
```txt
由于本文的重点是构建工具，因此需要澄清与构建系统的区别。

编译工具（Build Tool）对一组软件包进行操作。它确定依赖关系图，并按拓扑顺序为每个软件包调用特定的构建系统。构建工具本身应尽可能少地了解特定软件包所使用的构建系统。只需知道如何为其设置环境、调用构建和设置环境以使用构建的软件包即可。现有的 ROS 构建工具包括：catkin_make、catkin_make_isolated、catkin_tools 和 ament_tools。

另一方面，编译系统（Build System）是在单个软件包上运行的。例如 Make、CMake、Python setuptools 或 Autotools（ROS 目前没有使用）。例如，CMake 软件包可以通过调用以下步骤来构建：cmake、make、make install。
```

另外作者强调了Colcon应当功能单一，总之尽可能符合软件开发原则：
* 关注点分离
* 单一职责原则
* 最少知识原则
* 不要重复自己
* 保持愚蠢简单
* “不为不使用的东西付费”

作者提到了ROS2上已经有专门的获取构建工具所需源码的工具（例如rosinstall 或 wstool（对于 .rosinstall 文件）或 vcstool（对于 .repos 文件）），也有专门的依赖项安装工具（rosdep），二进制包生成工具（如bloom等）。


#### 2.1.2 Colcon介绍
Colcon是一个构建工具，可以用来构建ROS2项目。它可以帮助我们更加方便地管理ROS2项目，包括编译、测试、安装等

#### 2.1.3 安装Colcon
通常ros2-desktop中已经安装好了colcon.但是如果你要单独安装（这里只关注我目前使用的Ubuntu22.04），则可以使用apt安装：
```bash
sudo apt install python3-colcon-common-extensions
```

另外，我也看到有些包，比如`MoveIt 2`使用了colcon的mixin扩展。（colcon-mixin是colcon-core 的扩展，用于从存储库获取和管理 CLI mixins。）
```bash
$ sudo apt install python3-colcon-mixin
$ colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml
$ colcon mixin update default
```
<font color=orange>（注：请注意当需要显示终端回应的内容时，我会在用户输入的命令前添加`$`符号，以表示命令提示符。以下不再赘述。）</font>


#### 2.1.4 Colcon的目录结构
当新创建一个colcon软件包时，先要在其内部创建一个名为src的子文件夹用以存放代码。
这里假定我们创建一个软件包的工作空间叫做demo_ws.我们可以这样做：
```bash
mkdir -p demo_ws/src
cd demo_ws
```
这样我们就创建一个名字叫demo_ws的工作空间，并在其内部创建一个名为src的子文件夹。
因为本节的目的是学习colcon的使用，所以我们可以先从官方提供的[examples](https://github.com/ros2/examples)中clone代码。这个仓库里面有针对不同ROS2版本的example,
所以用户可以选择针对自己的ROS2版本进行clone。当然记得将clone的代码放在src文件夹中。

```bash
git clone https://github.com/ros2/examples src/examples -b humble
```
然后我们不妨熟悉一下examples的目录结构：
```bash
$ ls src/examples/
CONTRIBUTING.md  launch_testing  LICENSE  rclcpp  rclpy  README.md

## 当然也可以用目录树的结构展示
$ tree . -L 3
.
└── src
    └── examples
        ├── CONTRIBUTING.md
        ├── launch_testing
        ├── LICENSE
        ├── rclcpp
        ├── rclpy
        └── README.md

5 directories, 3 files
```
相比于入门教程多了一个文件夹：launch_testing。这个文件夹包含launch和launch_testing 包的简单用例。这些旨在帮助初学者开始使用这些软件包并帮助他们理解这些概念。
而rclcpp和rclpy分别是C++和python相关的示例代码。

当colcon完全编译之后，它内部的文件夹结构如下：
```txt
.
├── build
├── install
├── log
└── src
```
src就是我们刚才将源码放入的目录;build是编译空间;install是安装空间;log是调试或者编译的记录。

#### 2.1.5 underlay和overlay
还记得在Beginner:CLI中，每次启动turtlesim的时候都要source一下`/opt/ros/humble/setup.bash`了吗？那里会配置我们启动turtlesim所需的各种依赖和环境变量。

在使用colcon编译的时候同样需要我们借助setup script（设置脚本）来创建一个包含示例软件包所需的构建依赖项的工作区。我们称这种环境为 `underlay`（底层环境）。因为`underlay`似乎没有好的翻译，但大概可以翻译叫做基础环境或者底层环境。表示上层或中层的代码编译、执行、测试都有需要依赖于它。后面的描述中我们就直接叫做`underlay`.

现在我们的工作区demo_ws将是现有ROS2安装的`overlay`（覆盖层）。`overlay`这个概念如果生硬的翻译就是“覆盖环境”。这是相对于`underlay`这个概念而言的。通常来说，当你迭代少量的packages时，建议使用一个独立的`overlay`，而不是将所有的packages放在同一个工作区中。

#### 2.1.6 Build the Worksapce/工作区编译
catkin中除了代码空间/src（source space）、编译空间/build（build space）、安装空间/install（install space）。还有专门的devel（development space）用来存放编译生成的可执行文件等。但是新的ament_cmake不支持devel,需要安装包。这时候可以在build的时候`--symlink-install`选项，这样可以要求编译器尽可能使用符号链接而不是复制文件。这样就可以更改源代码中的配置文件来更改已安装的文件，从而加速项目的迭代。<font color=red>（这一部分解释还不是很理解）</font>

终于来到激动人心的编译环节了：
```bash
## 请确保当前正位于demo_ws目录下
colcon build --symlink-install
```
编译完成会有形如“Summary: {x} packages finished [{n}s]”这样的字样。信息比较直观，不再赘述。我们可以查看现在的文件目录：
```bash
$ tree -L 1
.
├── build
├── install
├── log
└── src

4 directories, 0 files
```
这个目录结构在前面已经简单介绍过了。我们可以深入的浏览一下每个目录的文件，以加深印象。

另外，如果您不想构建特定的软件包，将一个名为`COLCON_IGNORE`的空文件放在目录中，则不会索引。你还可以在build,install,log的目录中发现这个文件。我推测这个文件相当于一个标签，编译器会忽略索引这个文件所在的目录。

#### 2.1.7 test/测试
colcon的功能十分强大，因此命令也就异常复杂。慢慢了解吧。我们先来看看如果使用colcon来测试。
```bash
colcon test
```
测试完成之后也会有类似的提示：“Summary: {x} packages finished [{n}s]”。
中间还可能有一些警告，比如下图：
![colcon test demo](img/colcon_test_result_demo1.png)
<p style="text-align:center; color:orange">图1：colcon test结果示例图</p>

如果要避免在CMAKE软件包中配置和建造测试，则可以通过：-CMAKE -ARGS -DBUILD_TESTING = 0。

如果你想运行特定的测试，可以使用如下命令：
```bash
colcon test --packages-select <package_name> --ctest-args -R <YOUR_TEST_IN_PKG>
```

#### 2.1.8 setup/设置
在进一步测试之前，需要source一下生成的setup脚本，才能为新生成的package执行包创建包含必须依赖的工作空间。做法和之前创建underlay的工作空间一样。因为ubuntu的terminal是bash,以后就不强调这一点。如果你的是其它的terminal,你还可以选择使用ps1,sh,zsh等。

```bash
source install/setup.bash
```

#### 2.1.9 try/尝试
现在我们来尝试一下example里面的demo.入门教程里面演示的是examples_rclcpp_minimal_subscriber和examples_rclcpp_minimal_publisher这一组examples.打开两个终端窗口，一个担任subscriber一个担任publisher.
![rclcpp minimal demo](img/examples_rclcpp_minimal.gif)
<p style="text-align:center; color:orange">图2：rclcpp minimal demo</p>

#### 2.1.10 create an package/新包
colcon每个包都有一个`package.xml`文件，此文件定义了作者、版本、依赖等信息。我们不妨打开一个examples_rclcpp_minimal_publisher的package.xml文件，并使用[xmltool](https://github.com/cmiles74/xmltool/)工具解析一下它的构成。
![package_xml_parse](img/package_xml_parse.png)
<p style="text-align:center; color:orange">图3：package.xml解析结果</p>

上图很清晰的展示了xml的主要节点。我们可以看到此包的build、execute和test都依赖rclcpp和std_msgs。也可以看到编译类型是`ament_cmake`。

colcon支持多种构建类型。推荐的类型是ament_cmake和ament_python。也支持纯cmake包。
ament_cmake是C/c++的构建类型。ament_python则是python的构建类型。

我们可以使用`ros2 pkg create`去创建基于模板的新包。现在来尝试一下：
```bash
$ cd src/examples/rclcpp

$ ros2 pkg create --build-type ament_cmake --dependencies rclcpp std_msgs --description "It is an demo package"  --license MIT  demo_pkg
going to create a new package
package name: demo_pkg
destination directory: /home/galileo/Workspaces/ROS2/execises/demo_ws/src/examples/rclcpp
package format: 3
version: 0.0.0
description: It is an demo package
maintainer: ['galileo <zjh.2008.09@gmail.com>']
licenses: ['MIT']
build type: ament_cmake
dependencies: ['rclcpp', 'std_msgs']
creating folder ./demo_pkg
creating ./demo_pkg/package.xml
creating source and include folder
creating folder ./demo_pkg/src
creating folder ./demo_pkg/include/demo_pkg
creating ./demo_pkg/CMakeLists.txt

$ tree demo_pkg/
demo_pkg/
├── CMakeLists.txt
├── include
│   └── demo_pkg
├── LICENSE
├── package.xml
└── src

3 directories, 3 files

```
这样我们就新建了一个包，只是里面暂时没有代码。关于`ros2 pkg create`的详细用法，你可以使用`ros2 pkg create -h`去仔细查看。请尽量选择设置一个license,否则里面可能会产生警告提示。

#### 2.1.11 colcon_cd
ROS2还提供一个快速跳转的工具，但是默认是没有生效的。所以需要提前设置一下：
```bash
echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc
echo "export _colcon_cd_root=/opt/ros/humble/" >> ~/.bashrc

## 如果有必要可以查看一下添加是否成功
cat ~/.bashrc | grep colcon_cd

```
为了让新添加的生效，我们可以重新打开一下shell.我们可以检验一下是否成功。
```bash
$ colcon_cd rclcpp
$ pwd
/opt/ros/humble/share/rclcpp
$ colcon_cd std_msgs
$ pwd
/opt/ros/humble/share/std_msgs
$ colcon_cd examples_rclcpp_minimal_publisher
$ pwd
/opt/ros/humble/share/examples_rclcpp_minimal_publisher
```
可以看出这个工具确实挺方便的，但是前提是你需要知道包的正确名称。另外如果没有source过的包，这个工具也无法跳转。比如，我们尝试寻找刚才的`demo_pkg`：
```bash
$ colcon_cd demo_pkg
Could neither find package 'demo_pkg' from '/opt/ros/humble/' nor from the current working directory
```
#### 2.1.12 colcon命令自动补全
colcon支持命令自动补全，但是默认是没有开启的。如果需要开启，需要在bashrc中添加一行：
```bash
echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc
## 如果有必要可以查看一下添加是否成功
cat ~/.bashrc | grep argcomplete
```
然后重新打开shell，就可以使用命令自动补全了。


### 2.2 Workspace/工作区
本小节内容主要参考[creating a workspace tutorial](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Creating-A-Workspace/Creating-A-Workspace.html)和[A universal build tool](https://design.ros2.org/articles/build_tool.html)。

我们在上一小节介绍了underlay和overlay的概念。工作区（Workspace）就是一个包含ROS包的目录。我们每次在启动ROS2的时候都要Source一下(如果你将source的代码放在.bashrc中，则不需要每次都手动source)，这个过程实际就是在配置必要软件包的工作区。

#### 2.2.1 Creating a workspace/创建工作区
按照官方教程创建名字工作区。这部分的概念和步骤和上一小节一致。不再赘述。这一节的不同点在于我们创建的工作区名称叫做demo2_ws.(原文叫做ros2_ws,我这里改为demo2_ws是为了和上一小节做区分。)
另外这一节的样例代码变成了[ros tutories](https://github.com/ros2/ros2_tutorials)。首先用cd指令跳转到你的目标目录。然后执行以下命令：

```bash
mkdir -p demo2_ws/src
cd demo2_ws/src
git clone https://github.com/ros/ros_tutorials.git -b humble
```
如果成功clone,我们照例使用tree命令查看一下：
```bash
$ tree -L 2
.
└── ros_tutorials
    ├── roscpp_tutorials
    ├── rospy_tutorials
    ├── ros_tutorials
    └── turtlesim
```
#### 2.2.2 Resolve dependencies/依赖关系
这一节主要关注ROS2包的依赖关系。在我们编写好代码或者copy示例程序之后，在编译之前，我们最好先解决依赖关系。不然当你花费和很久时间才发现缺少必要的依赖项，这将非常的不划算。

我们可以用rosdep命令来解决依赖关系。当然我们首先要回到我们的工作区目录，然后使用rosdep来执行依赖检查。如下：
```bash
## 因为我们刚才在src目录，现在需要回到工作区根目录
$ cd ../
$ rosdep install -i --from-path src --rosdistro humble -y
#All required rosdeps installed successfully
```
上面的命令稍微有些复杂，我们可以先学习一下`rosdep`命令和`rosdep install`。如下：
```bash
$ rosdep 
Usage: rosdep [options] <command> <args>

Commands:

rosdep check <stacks-and-packages>...
  check if the dependencies of package(s) have been met.
## rosdep check检查依赖项是否都满足，我的理解是应该使用这个命令检查依赖关系。

rosdep install <stacks-and-packages>...
  download and install the dependencies of a given package or packages.
## rosdep install应该是用来下载依赖项。但是入门教程使用这个去检查并自动下载依赖。

rosdep db
  generate the dependency database and print it to the console.
## rosdep db命令生成依赖数据库，并打印到控制台。

rosdep init
  initialize rosdep sources in /etc/ros/rosdep.  May require sudo.
## rosdep init命令初始化rosdep源。可能需要以root权限运行。

rosdep keys <stacks-and-packages>...
  list the rosdep keys that the packages depend on.

rosdep resolve <rosdeps>
  resolve <rosdeps> to system dependencies

rosdep update
  update the local rosdep database based on the rosdep sources.

rosdep what-needs <rosdeps>...
  print a list of packages that declare a rosdep on (at least
  one of) <rosdeps>

rosdep where-defined <rosdeps>...
  print a list of yaml files that declare a rosdep on (at least
  one of) <rosdeps>

rosdep fix-permissions
  Recursively change the permissions of the user's ros home directory.
  May require sudo.  Can be useful to fix permissions after calling
  "rosdep update" with sudo accidentally.


rosdep: error: Please enter a command
```

我按照自己的理解尝试使用`rosdep check`来检查，也成功了：
```bash
$ rosdep check --from-paths src --rosdistro humble
All system dependencies have been satisfied
```

要想查看`rosdep check`和`rosdep install`的详细信息，可以使用`-h`选项。因为命令较多，就不一一解释。这里只关注这次使用的这几个选项的含义：
```bash
$ rosdep install -h
## 只摘录部分内容
--os=OS_NAME:OS_VERSION
                        Override OS name and version (colon-separated), e.g.
                        ubuntu:lucid
-c SOURCES_CACHE_DIR, --sources-cache-dir=SOURCES_CACHE_DIR
                    Override /home/galileo/.ros/rosdep/sources.cache
-y, --default-yes     Tell the package manager to default to y or fail when
-i, --ignore-packages-from-source, --ignore-src
                        Affects the 'check', 'install', and 'keys' verbs. If
                        specified then rosdep will ignore keys that are found
                        to be catkin or ament packages anywhere in the
                        ROS_PACKAGE_PATH, AMENT_PREFIX_PATH or in any of the
                        directories given by the --from-paths option.

--from-paths          Affects the 'check', 'keys', and 'install' verbs. If
                    specified the arguments to those verbs will be
                    considered paths to be searched, acting on all catkin
                    packages found there in.
--rosdistro=ROS_DISTRO
                        Explicitly sets the ROS distro to use, overriding the
                        normal method of detecting the ROS distro using the
                        ROS_DISTRO environment variable. When used with the
                        'update' verb, only the specified distro will be
                        updated.
```
`-i`选项将会忽略在 ROS_PACKAGE_PATH、AMENT_PREFIX_PATH 或 --from-paths 选项指定的任何目录中的任意位置发现的 catkin 或 ament 包的键。

`--from-paths`用来搜索这个路径下所有的catkin软件包。

`--rosdistro`用来制定ROS的版本，比如我们用的humble.

`-y`告诉软件管理器默认为yes.

入门教程和介绍了从source或者fat archive的安装。参数更加复杂。这里不再赘述。（因为我也没有尝试）

总之如果依赖全部already,会提示`#All required rosdeps installed successfully`。

包是通过`package.xml`文件来声明依赖项的。后面会详细介绍。在2.1.10其实也简单提到过。所以清晰的文档结构也帮助rosdep来快速的检查依赖关系。

#### 2.2.3 编译
这一章和2.1中的步骤没有什么特殊。不再赘述：
```bash
$ colcon build
## 省略输出内容
Summary: 1 package finished [14.8s]

$ tree -L 2
.
├── build
│   ├── COLCON_IGNORE
│   └── turtlesim
├── install
│   ├── COLCON_IGNORE
│   ├── local_setup.bash
│   ├── local_setup.ps1
│   ├── local_setup.sh
│   ├── _local_setup_util_ps1.py
│   ├── _local_setup_util_sh.py
│   ├── local_setup.zsh
│   ├── setup.bash
│   ├── setup.ps1
│   ├── setup.sh
│   ├── setup.zsh
│   └── turtlesim
├── log
│   ├── build_2024-01-19_20-14-45
│   ├── COLCON_IGNORE
│   ├── latest -> latest_build
│   └── latest_build -> build_2024-01-19_20-14-45
└── src
    └── ros_tutorials

10 directories, 13 files
```
有意思的是如果你观察src/ros_tutorials目录，里面有好几个文件夹。但是最终生成的只有一个package.而上一章其实生成了好几个packages.这一点可以留个疑问。

入门教程还对几个参数做了解释：
* --packages-up-to（构建你想要的软件包及其所有依赖包），但不构建整个工作区（节省时间
* --symlink-install让你在每次修改 python 脚本时都不必重新构建。
* --event-handlers console_direct+ 在构建时显示控制台输出（也可以在日志目录中找到）。

#### 2.2.4 运行测试
要运行测试，老样子还是要source一下underlay和新建的包（overlay）。如下：
```bash
## 教程又提了一遍，但是如果你已经将这个命令写入到.bashrc就没必要重复
source /opt/ros/humble/setup.bash

## 进入demo2_ws工作区，否则不能完成。我这里已经ready.就不再执行。
## 这里使用的是local_setup，为什么没用setup。下文有介绍
source install/local_setup.bash
```
这里需要说明一下`local_setup`和`setup`的区别：
* `local_setup`是ROS2的本地设置，即只设置`overlay`的工作环境。因为我们之前source了`/opt/ros/humble/setup.bash`相当于手动source了`underlay`
* `setup`不仅会设置`overlay`的工作环境还会设置`underlay`的工作环境。所以也可以只用一步`setup`让两个工作区都ready.
测试命令之前也用过：
```bash
ros2 run turtlesim turtlesim_node
```
但是我们怎么知道这个是overlay的，而不是underlay的呢？因为即便我们没有使用`local_setup`也可以运行.

#### 2.2.5 修改测试
为了验证确实是我们的overlay运行了，最简单的办法是修改一下窗口的标题或者窗口的大小等信息。
我这里使用vscode去打开整个工作区。src/ros_tutorials下面有4个目录。经过分析之后感觉目标目录应该就是“turtlesim/src”下面的文件。
入门教程里面提到要修改ros_tutorials/turtlesim/src/turtle_frame.cpp和我的查找是一致的。我们就开始修改吧：
![第一次代码修改](img/ros_turtuals_change_1.png)
<p style="text-align:center; color:orange">图4：代码修改</p>

可以看到代码只要做了三个大的修改：
1. 修改了背景颜色（DEFAULT_BG_R,DEFAULT_BG_G,DEFAULT_BG_B三个地方）
2. 窗口尺寸由(500, 500)改为了(600, 600)
3. 标题由"TurtleSim"改为了"WuguiSim"

修改完成之后：根据步骤前面已经介绍的方法，完成编译。然后我们来设法做一个对比。一个启用了overlay(即使用`source install/local_setup.bash`),另一个不用。效果演示如下：
![两个不同的turtlesim](img/two_diff_turtlesim.gif)
<p style="text-align:center; color:orange">图5：两个不同的turtlesim界面</p>

* 第一个窗口背景为艳粉色的是Overlay,可以看到窗口的title也更改为了"WuguiSim"，窗口也比第二个大了很多。（我屏幕分辨率比较高，所以窗口显示的可能比你电脑上的小一些。）
* 第二个窗口和我们之前测试的一样。窗口明显比第一个小了一圈。标题还是TurtleSim。

所以我们可以认为Overlay层是先被寻找的。类似与C语言的局部变量。当在Overlay里面找不到我们需要的package的时候才会去修找underlay层的包。如果启用了我们修改过的Overlay,因为turtlesim已经在这里寻找到了。所以就会出现我们做出修改的窗口。

### 2.3 ROS2 Package和它的创建
奇怪的是，我其实在笔记1中也没有自己提过Package是什么。官方其实也没有将。我们其实之前用`ROS2 pack`这个命令对包进行过一番操作。因为software package默认是一个大家都熟知的概念。但是其实我自己并不能给它一个很好的解释。我们不妨来看看官方怎么解释的吧：
```txt
A package is an organizational unit for your ROS 2 code. If you want to be able to install your code or share it with others, then you’ll need it organized in a package. With packages, you can release your ROS 2 work and allow others to build and use it easily.

（对于ROS2来说）一个软件包（Package，简称软件包）是ROS2的代码管理单元。如果你想要安装你的的代码，或者将它们分享给其他人，你需要将它们组织成一个包的形式。通过包，您可以发布您的ROS2作品并允许其他人轻松构建和使用它。
```
这个概念其实很清晰。首先它是软件代码的组织形式，通过软件包这种形式会将代码中的所有文件见按照某种形式组织/捆绑在一起。第二，你发布给别人的时候，也是将你的代码当作一个整体（package）发布出去。别人获取时也是b把这个包的整体获取过来。否则软件将事实不完整的。

ROS2中的包创建使用ament作为其构建系统，并使用colcon作为其构建工具。您可以使用官方支持的CMake或Python创建包，但也存在其他构建类型。

#### 2.3.1 ament
(注：这部分主要参考[about build system](https://docs.ros.org/en/foxy/Concepts/About-Build-System.html)这一篇的内容。)

ament是ROS2的构建系统。它是ROS2的核心组件之一。ament的主要目的是帮助ROS2项目开发者快速、可靠的构建ROS2软件。我们不妨看一下[官方是如何解释ament]()的:
```txt
Under everything is the build system. Iterating on catkin from ROS 1, we have created a set of packages under the moniker ament. Some of the reasons for changing the name to ament are that we wanted it to not collide with catkin (in case we want to mix them at some point) and to prevent confusion with existing catkin documentation. ament’s primary responsibility is to make it easier to develop and maintain ROS 2 core packages. However, this responsibility extends to any user who is willing to make use of our build system conventions and tools. Additionally it should make packages conventional, such that developers should be able to pick up any ament based package and make some assumptions about how it works, how to introspect it, and how to build or use it.

一切之下都是构建系统。 在 ROS 1 的 catkin 上进行迭代，我们创建了一组名为 ament 的包。 将名称更改为 ament 的一些原因是我们希望它不与 catkin 冲突（以防我们想在某个时候将它们混合）并防止与现有的 catkin 文档混淆。 ament 的主要职责是让 ROS 2 核心包的开发和维护变得更加容易。 然而，这一责任延伸到任何愿意使用我们的构建系统约定和工具的用户。 此外，它应该使包变得常规，这样开发人员应该能够选择任何基于 ament 的包，并对其如何工作、如何内省以及如何构建或使用它做出一些假设。

```

ament是一个不断发展的构建系统，目前主要由ament_package，ament_cmake, ament_lint和build tools组成。它们被托管在[ament的github仓库](https://github.com/ament)中。关于这几个仓库具体包含什么内容这里就不再赘述。下面只描述与之相关的一些概念。

* ament packages :任何包含package.xml并遵循ament打包准则的包，无论底层构建系统如何。package.xml“清单”文件包含处理和操作包所需的信息。此包信息包括全局唯一的包名称以及包的依赖项等内容。package.xml文件还充当标记文件，指示包在文件系统上的位置。package.xml文件的解析由`catkin_pkg`提供（如 ROS 1 中所示），而通过在文件系统中搜索这些package.xml文件来定位包的功能由构建工具（例如 colcon）提供。

* ament cmake pacakge :使用CMake构建的ament包,它遵循ament的打包准则。这种类型的包由 package.xml 文件的`<export>`标记中的 `<build_type>ament_cmake</build_type>` 标记标识。

* ament Python package :遵循ament打包指南的Python包。

* setuptools : 它是python常用的一个打包和分发工具。它也是ament中python package的打包工具。

* package.xml :包的清单文件（manifest file）。标记包的根并包含有关包的元信息，包括其名称、版本、描述、维护者、许可证、依赖项等。 清单的内容采用机器可读的XML格式，并且内容在REP 127和140中描述，并且有可能在未来的REP中进一步修改。

#### 2.3.2 Package的结构
我们首先来了解一下ament包的组成。对于cmake的包它包含这样几个关键文件/文件夹：
* __CMakeLists.txt__ 描述如何在包中构建代码
* __include/<package_name>__ 包含包的公共标头的目录
* __package.xml__ 文件包含了包的元信息
* __src__ 目录包含包的源代码

其实最简单的是我们去查看一下我们之前2.1中的包的结构：
```bash
$ tree -L 3 wait_set/
wait_set/
├── CHANGELOG.rst
├── CMakeLists.txt
├── include
│   └── wait_set
│       ├── listener.hpp
│       ├── random_listener.hpp
│       ├── random_talker.hpp
│       ├── talker.hpp
│       └── visibility.h
├── package.xml
├── README.md
└── src
    ├── executor_random_order.cpp
    ├── listener.cpp
    ├── static_wait_set.cpp
    ├── talker.cpp
    ├── thread_safe_wait_set.cpp
    ├── wait_set_composed.cpp
    ├── wait_set.cpp
    ├── wait_set_random_order.cpp
    ├── wait_set_topics_and_timer.cpp
    └── wait_set_topics_with_different_rates.cpp

3 directories, 19 files
```
可以看出这个package包含了上面提到的四个部分。当然还有一些其它几个ament包不需要的文件：`CHANGELOG.rst`和`README.md`等。


我们再来看看python的包组成：
* __package.xml__ 文件包含有关包的元信息
* __resource/<package_name>__ 是包的标记文件
* __setup.cfg__ 当包有可执行文件时需要setup.cfg，因此ros2 run可以找到它们
* __setup.py__ 包含如何安装包的说明
* __<package_name>__ 与您的包同名的目录，ROS2工具使用它来查找您的包，包含`__init__.py`

其实最简单的是我们去查看一下我们之前2.1中的包的结构：
```bash
$ tree -L 3 minimal_publisher/
minimal_publisher/
├── CHANGELOG.rst
├── examples_rclpy_minimal_publisher
│   ├── __init__.py
│   ├── publisher_local_function.py
│   ├── publisher_member_function.py
│   ├── publisher_old_school.py
│   └── __pycache__
│       └── __init__.cpython-310.pyc
├── package.xml
├── README.md
├── resource
│   └── examples_rclpy_minimal_publisher
├── setup.cfg
├── setup.py
└── test
    ├── __pycache__
    │   ├── test_copyright.cpython-310-pytest-6.2.5.pyc
    │   ├── test_flake8.cpython-310-pytest-6.2.5.pyc
    │   └── test_pep257.cpython-310-pytest-6.2.5.pyc
    ├── test_copyright.py
    ├── test_flake8.py
    └── test_pep257.py

5 directories, 17 files
```
可以看出这个package包含了上面提到的五个部分。当然还有一些其它几个ament包不需要的文件：`CHANGELOG.rst`和`README.md`等。

比较Cmake和Python的ament包相似之处是都包含了package.xml文件。在Cmake中的include文件夹了里面包含了一个和包名相同的子文件，而Python的resource中也有一个和包名相同的标记文件。两个package.xml文件的build_type标签也不相同。分标包含了`ament_cmake`标签和`ament_python`标签。

然而比较让我觉得不理解的是下面这种结构。一个是rclcpp/topics/minimal_publisher/,它的结构如下：
```
$ tree minimal_publisher/
minimal_publisher/
├── CHANGELOG.rst
├── CMakeLists.txt
├── lambda.cpp
├── member_function.cpp
├── member_function_with_type_adapter.cpp
├── member_function_with_unique_network_flow_endpoints.cpp
├── member_function_with_wait_for_all_acked.cpp
├── not_composable.cpp
├── package.xml
└── README.md

0 directories, 10 files
```
可以看到这个包根本没有include文件夹。和cmake ament的要求的包结构不一样。但应该也是合理的。后面再继续关注这个情况。

另外需要注意的是一个workspace可以包含一个或者多个package,这些package可以是python package或者cmake package.甚至其它受支持的构建系统。比如cargo ament（编译rust包）。但是需要注意它们不能相互嵌套。（一个包里面包含另一个包的情况是不允许的。它们应该都有独立的包结构。）下面是入门教程示例的一个简单的文件结构：
```txt
workspace_folder/
    src/
      cpp_package_1/
          CMakeLists.txt
          include/cpp_package_1/
          package.xml
          src/

      py_package_1/
          package.xml
          resource/py_package_1
          setup.cfg
          setup.py
          py_package_1/
      ...
      cpp_package_n/
          CMakeLists.txt
          include/cpp_package_n/
          package.xml
          src/
```
我们在2.1和2.2小节使用的目录结构都符合这种推荐的方式。

#### 2.3.3 尝试自己创建一个Package
（这一部分的操作我们在2.1.10中其实已经简单尝试过。这里再操作一次是为了更加熟练和深入。）
我们现在先回到我们在2.2小节使用的那个工作区。（就是运行turtlesim的那个工作区）
这一小节，将使用`ros2 pack create`来创建package.以下的操作假定你已经跳转到了demo2_ws工作区。现在让我们开始吧：
```bash
$ ros2 pkg create -h
usage: ros2 pkg create [-h] [--package-format {2,3}] [--description DESCRIPTION] [--license LICENSE]
                       [--destination-directory DESTINATION_DIRECTORY] [--build-type {cmake,ament_cmake,ament_python}]
                       [--dependencies DEPENDENCIES [DEPENDENCIES ...]] [--maintainer-email MAINTAINER_EMAIL]
                       [--maintainer-name MAINTAINER_NAME] [--node-name NODE_NAME] [--library-name LIBRARY_NAME]
                       package_name

Create a new ROS 2 package

positional arguments:
  package_name          The package name

options:
  -h, --help            show this help message and exit
  --package-format {2,3}, --package_format {2,3}
                        The package.xml format.
  --description DESCRIPTION
                        The description given in the package.xml
  --license LICENSE     The license attached to this package; this can be an arbitrary string, but a LICENSE file will only be generated
                        if it is one of the supported licenses (pass '?' to get a list)
  --destination-directory DESTINATION_DIRECTORY
                        Directory where to create the package directory
  --build-type {cmake,ament_cmake,ament_python}
                        The build type to process the package with
  --dependencies DEPENDENCIES [DEPENDENCIES ...]
                        list of dependencies
  --maintainer-email MAINTAINER_EMAIL
                        email address of the maintainer of this package
  --maintainer-name MAINTAINER_NAME
                        name of the maintainer of this package
  --node-name NODE_NAME
                        name of the empty executable
  --library-name LIBRARY_NAME
                        name of the empty library

```
我们先来看一下创建一个包需要的几个主要参数。
* `package_name`是必须参数。想必大家都能理解。
* `--license`是这个包支持的LICENSE，我们来查看一下：
  ```bash
  $ ros2 pkg create --license ? my_test
  Supported licenses:
  Apache-2.0
  BSL-1.0
  BSD-2.0
  BSD-2-Clause
  BSD-3-Clause
  GPL-3.0-only
  LGPL-3.0-only
  MIT
  MIT-0
  ```
  可以看出来它支持`Apache-2.0`, `BSL-1.0`, `BSD-2.0`, `BSD-2-Clause`, `BSD-3-Clause`, `GPL-3.0-only`, `LGPL-3.0-only`, `MIT`, `MIT-0`这几种LICENSE。看一查看[这里](https://opensource.org/licenses/)了解更多license.
* `--package-format {2,3}`是这个包的package.xml格式，我们可以选择`2`或`3`。具体可以查看[REP-0149](https://ros.org/reps/rep-0149.html).
* `--build-type`是这个包的构建类型，我们可以选择`cmake`,`ament_cmake`或`ament_python`来构建。
* `--dependencies`是这个包的依赖关系，可以指定多个依赖。如果是多个依赖项，依次写在后面就行。后面也可以手动修改。
* `--maintainer-email`和`--maintainer-name`是这个包的维护者信息。
* `--node-name`和`--library-name`是这个包的可执行节点和库名称。
* `--destination-directory`是这个包的生成目录，默认是当前目录。
* `--description`是这个包的描述信息。

通过上面对于它的介绍，我们应该可以创建出一个新的包。我们来试试吧：
```bash
## 入门教程提供的脚本，用来创建一个名字叫做my_package，节点名字叫做my_node的包。
$ ros2 pkg create --build-type ament_cmake --license Apache-2.0 --node-name my_node my_package
$ tree my_package/
my_package/
├── CMakeLists.txt
├── include
│   └── my_package
├── LICENSE
├── package.xml
└── src
    └── my_node.cpp

3 directories, 4 files
```
上面的文件结构和我们在上一小节的描述一致。我们现在再打开package.xml看一下：
```xml
<?xml version="1.0"?>
<?xml-model href="http://download.ros.org/schema/package_format3.xsd" schematypens="http://www.w3.org/2001/XMLSchema"?>
<package format="3">
  <name>my_package</name>
  <version>0.0.0</version>
  <description>TODO: Package description</description>
  <maintainer email="zjh.2008.09@gmail.com">galileo</maintainer>
  <license>Apache-2.0</license>

  <buildtool_depend>ament_cmake</buildtool_depend>

  <test_depend>ament_lint_auto</test_depend>
  <test_depend>ament_lint_common</test_depend>

  <export>
    <build_type>ament_cmake</build_type>
  </export>
</package>
```
可以看到默认的package-format是3.0； 版本号默认是0.0.0； 因为我们没有制定依赖项所以也看不到相关信息（只有测试依赖项）；默认的描述信息现实的是`TODO: Package description`。maintainer信息尽管我没有专门制定，但是也会默认使用我自己的名字。license是我们指定的Apache-2.0。`build_type`是ament_cmake。

现在我们依照上面的办法办法来创建一个支持ament python的package.
```bash
$ ros2 pkg create --build-type ament_python --license Apache-2.0 --node-name my_2nd_node my_2nd_package
$ tree my_2nd_package/
my_2nd_package/
├── LICENSE
├── my_2nd_package
│   ├── __init__.py
│   └── my_2nd_node.py
├── package.xml
├── resource
│   └── my_2nd_package
├── setup.cfg
├── setup.py
└── test
    ├── test_copyright.py
    ├── test_flake8.py
    └── test_pep257.py

3 directories, 10 files
```
这样我就创建了一个支持名称叫做my_2nd_package的ament python的包。目录结构和之前提到的一致。我们打开package.xml看一下：
```xml
<?xml version="1.0"?>
<?xml-model href="http://download.ros.org/schema/package_format3.xsd" schematypens="http://www.w3.org/2001/XMLSchema"?>
<package format="3">
  <name>my_2nd_package</name>
  <version>0.0.0</version>
  <description>TODO: Package description</description>
  <maintainer email="zjh.2008.09@gmail.com">galileo</maintainer>
  <license>Apache-2.0</license>

  <test_depend>ament_copyright</test_depend>
  <test_depend>ament_flake8</test_depend>
  <test_depend>ament_pep257</test_depend>
  <test_depend>python3-pytest</test_depend>

  <export>
    <build_type>ament_python</build_type>
  </export>
</package>
```
可以看到默认的package-format是3.0； 版本号默认是0.0.0； 因为我们没有指定依赖项所以也看不到相关信息（只有测试依赖项）；默认的描述信息现实的是`TODO: Package description`。maintainer信息尽管我没有专门制定，但是也会默认使用我自己的名字。license是我们指定的Apache-2.0。`build_type`是ament_python。

python包中还专门提到了__init__.py这个文件，我们不妨也看一下它的内容。结果一查看，里面默认的内容为空。

现在我们来构建刚才创建的两个包。这一次我们根据入门教程的建议，先使用build直接构建。然后修改一部分内容，单独构建某一个包。
```bash
## 构建整个工作区
$ cd ../
$ colcon build
[0.792s] WARNING:colcon.colcon_core.package_selection:Some selected packages are already built in one or more underlay workspaces:
	'turtlesim' is in: /home/galileo/Workspaces/ROS2/execises/demo2_ws/install/turtlesim, /opt/ros/humble
If a package in a merged underlay workspace is overridden and it installs headers, then all packages in the overlay must sort their include directories by workspace order. Failure to do so may result in build failures or undefined behavior at run time.
If the overridden package is used by another package in any underlay, then the overriding package in the overlay must be API and ABI compatible or undefined behavior at run time may occur.

If you understand the risks and want to override a package anyways, add the following to the command line:
	--allow-overriding turtlesim

This may be promoted to an error in a future release of colcon-override-check.
Starting >>> my_2nd_package
Starting >>> my_package
Starting >>> turtlesim
--- stderr: my_2nd_package                                                                                      
/home/galileo/.local/lib/python3.10/site-packages/setuptools/_distutils/cmd.py:66: SetuptoolsDeprecationWarning: setup.py install is deprecated.
!!

        ********************************************************************************
        Please avoid running ``setup.py`` directly.
        Instead, use pypa/build, pypa/installer or other
        standards-based tools.

        See https://blog.ganssle.io/articles/2021/10/setup-py-deprecated.html for details.
        ********************************************************************************

!!
  self.initialize_options()
---
Finished <<< my_2nd_package [0.94s]
Finished <<< my_package [1.15s]                                                           
Finished <<< turtlesim [8.34s]                     

Summary: 3 packages finished [9.05s]
  1 package had stderr output: my_2nd_package
```
我们不妨来分别运行两个包，看一下结果。
```bash
$ source install/local_setup.bash
$ ros2 pkg list| grep my
dummy_map_server
dummy_robot_bringup
dummy_sensors
my_2nd_package
my_package
## 运行my_package
$ ros2 run my_package my_node
hello world my_package package
## 运行my_2nd_package
$ ros2 run my_2nd_package my_2nd_node
Hi from my_2nd_package.
```
现在我们修改一下的my_package输出内容。我们在my_node.cpp原来printf函数下面添加一行`printf("Hallo! Wie geht's?\n");`。然后重新编译：
```bash
## 构建单个包
$ colcon build --packages-select my_package
Starting >>> my_package
Finished <<< my_package [0.49s]                     

Summary: 1 package finished [1.11s]
$ ros2 run my_package my_node
hello world my_package package
Hallo! Wie geht's?
```
这样我们就完成了编译。（因为我们已经source过一次overlay,这一次其实修改没有涉及到依赖项的添加，所以没有再重新source.）

现在我们再修改一下my_2nd_package的输出内容。我们在my_2nd_node.py原来print函数下面添加一行`print(‘Wie ist das wetter?’)`。因为是python,请注意换行的格式。然后重新编译和测试：
```bash
## 构建单个包
$ colcon build --packages-select my_2nd_package 
Starting >>> my_2nd_package
--- stderr: my_2nd_package                   
/home/galileo/.local/lib/python3.10/site-packages/setuptools/_distutils/cmd.py:66: SetuptoolsDeprecationWarning: setup.py install is deprecated.
!!

        ********************************************************************************
        Please avoid running ``setup.py`` directly.
        Instead, use pypa/build, pypa/installer or other
        standards-based tools.

        See https://blog.ganssle.io/articles/2021/10/setup-py-deprecated.html for details.
        ********************************************************************************

!!
  self.initialize_options()
---
Finished <<< my_2nd_package [0.80s]

Summary: 1 package finished [1.43s]
  1 package had stderr output: my_2nd_package

$ ros2 run my_2nd_package my_2nd_node
Hi from my_2nd_package.
Wie ist das wetter?
```

#### 2.3.4 修改package.xml
刚才提到过package.xml文件可以被修改，我们现在讲描述信息修改掉吧。

唯一需要说明的是，ament_python的setup.py中也包含package.xml文件的信息，所以我们需要两处同步修改。

现在你可以使用`$ ros2 pkg xml {package_name}`去查看这个包的package.xml内容了。

### 2.4 尝试编写ament_cmake包
本小节参照入门教程[Writing a simple publisher and subscriber (C++)](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Writing-A-Simple-Cpp-Publisher-And-Subscriber.html)的内容。

这一小节，包的创建和编译还是参照2.2和2.3小节的内容进行。主要是通过编程来深化node（节点）和topic（话题）的概念。其实程序功能比较简单，一个节点发布内容到一个Topic上，另一个订阅内容这个Topic。

这一次我们新建一个工作区，名字叫做demo3_ws. 然后创建一个名字叫做cpp_pubsub的package。
```bash
$ mkdir -p demo3_ws/src
$ cd demo3_ws/src
$ ros2 pkg create --build-type ament_cmake --license Apache-2.0 --destination-directory ./src --description "A simple publisher and subscriber node in C++" cpp_pubsub
$ ls src/cpp_pubsub/
CMakeLists.txt  include  LICENSE  package.xml  src
```
至此，我们已经创建了一个名字叫做cpp_pubsub的包。我们这次将从[这里](https://raw.githubusercontent.com/ros2/examples/humble/rclcpp/topics/minimal_publisher/member_function.cpp)下载一个源文件放到src目录下。可以使用wget或者直接从浏览器现在，然后手动放入也可以。我选择前者：
```bash
$ wget -O src/cpp_pubsub/src/publisher_member_function.cpp https://raw.githubusercontent.com/ros2/examples/humble/rclcpp/topics/minimal_publisher/member_function.cpp
## 省略回应内容 ...
## 下载完成之后，检查一下
$ ls src/cpp_pubsub/src/
publisher_member_function.cpp
## 然后使用你最喜欢的工具查看和修改文档，我使用vscode
$ code src/cpp_pubsub/
```
#### 2.4.1 学习这段示例代码
开头有几个c++11引入的头文件：
```c++
/*This header is part of the date and time library.*/
#include <chrono>
/*This header is part of the function objects library and provides the standard hash function.*/
#include <functional>
/*This header is part of the dynamic memory management library.*/
#include <memory>
#include <string>
```
关于chrono的描述可以看这里[chrono](https://en.cppreference.com/w/cpp/header/chrono);关于functional的描述可以看这里[functional](https://en.cppreference.com/w/cpp/header/functional);关于memory的描述可以看这里[memory](https://en.cppreference.com/w/cpp/header/memory)。


接下来有几个与ros相关的library中的头文件：
```c++
/*`rclcpp` provides the canonical C++ API for interacting with ROS.*/
/*It consists of these main components：Node，Publisher，Subscriber，Servic Client，Servic Server，Timer，Parameter，Rate， Executors， CallbackGroups ... and many more*/
#include "rclcpp/rclcpp.hpp"

#include "std_msgs/msg/string.hpp"
```
如果有必要，可以手动打开查看。请记住这一步我们使用了rclcpp和std_msgs这两个ROS的包。所以后面需要在依赖项中有所体现。

再来看一下主函数：
```c++
int main(int argc, char * argv[])
{
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<MinimalPublisher>());
  rclcpp::shutdown();
  return 0;
}
```
可以大体理解先初始化，然后循环执行MinimalPublisher这个类的构建函数，最后关闭。所以再来看一下MinimalPublisher这个类。

```c++
class MinimalPublisher : public rclcpp::Node
{
public:
  MinimalPublisher()
  : Node("minimal_publisher"), count_(0)
  {
    publisher_ = this->create_publisher<std_msgs::msg::String>("topic", 10);
    timer_ = this->create_wall_timer(
      500ms, std::bind(&MinimalPublisher::timer_callback, this));
  }

private:
  void timer_callback()
  {
    auto message = std_msgs::msg::String();
    message.data = "Hello, world! " + std::to_string(count_++);
    RCLCPP_INFO(this->get_logger(), "Publishing: '%s'", message.data.c_str());
    publisher_->publish(message);
  }
  rclcpp::TimerBase::SharedPtr timer_;
  rclcpp::Publisher<std_msgs::msg::String>::SharedPtr publisher_;
  size_t count_;
};
```
这个函数就比较复杂了。看起来我们还是需要先来理解一些基本知识。

#### 2.4.2 rclcpp和std_msgs学习

* static_assert: 
* std::bind:
* RCLCPP_INFO: 
* rclcpp::init:
* rclcpp::spin
* rclcpp::shutdown
* rclcpp::Node
* rclcpp::create_publisher
* rclcpp::create_wall_timer

这部分函数的功能比较简单，但是用到的函数还是比较复杂的。

#### 2.4.3 配置依赖项
前面提到了我们用到了rclcpp和std_msgs这两个包，所以我们需要在package.xml中添加依赖项。添加内容：
```txt
<depend>rclcpp</depend>
<depend>std_msgs</depend>
```
CMakelists.txt文件内容也要修改，在适当位置添加：
```txt
find_package(rclcpp REQUIRED)
find_package(std_msgs REQUIRED)
```
此外还需要添加一个默认的C++版本：
```bash
# Default to C++14
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 14)
endif()
```
做完这些内容，我们构建一下：
```bash
## 检查一下依赖
$ rosdep check --from-paths src --ignore-src --rosdistro humble -y
All system dependencies have been satisfied

## 我们也可以用另一条指令
$ rosdep install -i --from-paths src --ignore-src --rosdistro humble -y
#All required rosdeps installed successfully
$ colcon build
Starting >>> cpp_pubsub
Finished <<< cpp_pubsub [3.95s]                     

Summary: 1 package finished [4.55s]
```
#### 2.4.3 在这个package中间添加一个subscriber节点
照例从[这里](https://raw.githubusercontent.com/ros2/examples/humble/rclcpp/topics/minimal_subscriber/member_function.cpp)下载文件。
```bash
$ wget -O src/cpp_pubsub/src/subscriber_member_function.cpp https://raw.githubusercontent.com/ros2/examples/humble/rclcpp/topics/minimal_subscriber/member_function.cpp
$ ls src/cpp_pubsub/src/
publisher_member_function.cpp  subscriber_member_function.cpp
```
同样的办法我们查看一下代码。具体这里就不再描述。因为这个源文件同样使用rclcpp和std_msgs这两个包。所以不必要再修改package.xml。但是需要向CMakeLists.txt中添加一个新的target。
新增：
```txt
add_executable(listener src/subscriber_member_function.cpp)
ament_target_dependencies(listener rclcpp std_msgs)
```
修改：
```txt
install(TARGETS
  talker 
  listener
  DESTINATION lib/${PROJECT_NAME})
```
OK,现在我们再来构建一次：
```bash
做完这些内容，我们构建一下：
```bash
## 检查一下依赖
$ rosdep check --from-paths src --ignore-src --rosdistro humble -y
All system dependencies have been satisfied

## 我们也可以用另一条指令
$ rosdep install -i --from-paths src --ignore-src --rosdistro humble -y
#All required rosdeps installed successfully
$ colcon build
Starting >>> cpp_pubsub
Finished <<< cpp_pubsub [4.87s]                     

Summary: 1 package finished [5.53s]
```
这一次可以不用检查依赖项。不过多做一步问题不大。

现在再来source一下overlay,然后测试：
```bash
$ source install/setup.bash
$ ros2 pkg list | grep cpp_pubsub
cpp_pubsub
## 检查一下可执行程序
$ ros2 pkg executables cpp_pubsub
cpp_pubsub listener
cpp_pubsub talker
## 运行listener
$ ros2 run cpp_pubsub listener
``````
同样的方法在另一个终端运行talker：
```bash
$ source install/setup.bash
$ ros2 run cpp_pubsub talker
```
可以看到listener订阅到了talker发布的消息。

![cpp_pubsub测试图](img//simple_cpp_pubsub_test.gif)
<p style="text-align:center; color:orange">图6：cpp_pubsub的测试图</p>

需要说明的使用`ros2 pkg executables cpp_pubsub`检查到的`listener`和`talker`其实是在CMakelists.txt文件中定义的。

#### 2.4.4 总结
这一章节使用了入门教程提供的示例代码来测试两个node之间通过topic进行通讯。代码尽管不复杂，但是有很多地方需要详细了解才行。另外代码使用了modern c++。看起来后面还要更新自己的modern c++知识。

### 2.5 尝试编写ament_python包
本小节参照入门教程[Writing a simple publisher and subscriber (Python)](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Writing-A-Simple-Py-Publisher-And-Subscriber.html)的内容。这一部分的功能和2.4节的基本一致，只是代码是用python编写的。

这一节我们新建一个工作区名称叫做demo4_ws，然后在里面创建一个名称是py_pubsub类型是ament_python的package。如下：
```
$ mkdir -p demo4_ws/src
$ cd demo4_ws
$ ros2 pkg create py_pubsub --build-type ament_python --license "Apache-2.0" --destination-directory src --description "A simple publisher and subscriber example in Python" 
$ tree src/py_pubsub/
src/py_pubsub/
├── LICENSE
├── package.xml
├── py_pubsub
│   └── __init__.py
├── resource
│   └── py_pubsub
├── setup.cfg
├── setup.py
└── test
    ├── test_copyright.py
    ├── test_flake8.py
    └── test_pep257.py

3 directories, 9 files
```
照例我们需要从示例库分别下载两份文件，一份是[publisher_member_function.py](https://raw.githubusercontent.com/ros2/examples/humble/rclpy/topics/minimal_publisher/examples_rclpy_minimal_publisher/publisher_member_function.py);另一份是[subscriber_member_function.py](https://raw.githubusercontent.com/ros2/examples/humble/rclpy/topics/minimal_subscriber/examples_rclpy_minimal_subscriber/subscriber_member_function.py)。这两个文件正如名称所表示的那样一个是publisher的代码一个是subscriber的代码。下载完成之后，我们可以使用vscode打开工程检视代码。
如下：
```bash
$ wget -O src/py_pubsub/py_pubsub/publisher_member_function.py https://raw.githubusercontent.com/ros2/examples/humble/rclpy/topics/minimal_publisher/examples_rclpy_minimal_publisher/publisher_member_function.py
$ wget -O src/py_pubsub/py_pubsub/subscriber_member_function.py https://raw.githubusercontent.com/ros2/examples/humble/rclpy/topics/minimal_subscriber/examples_rclpy_minimal_subscriber/subscriber_member_function.py
$ ls src/py_pubsub/py_pubsub/
__init__.py  publisher_member_function.py  subscriber_member_function.py
$ code src/py_pubsub/
```
我们先从publisher_member_function.py这个文件开始
开头三行
```python
import rclpy
from rclpy.node import Node

from std_msgs.msg import String
```
这两行导入了ROS2的一些基础包，其中rclpy是ROS2的python接口，Node是ROS2的节点基类。std_msgs是ROS2的标准消息类型。整个程序从main开始：
```python
def main(args=None):
    rclpy.init(args=args)

    minimal_publisher = MinimalPublisher()

    rclpy.spin(minimal_publisher)

    # Destroy the node explicitly
    # (optional - otherwise it will be done automatically
    # when the garbage collector destroys the node object)
    minimal_publisher.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
```
main函数的逻辑基本和ament_cmake的一致。先调用rclpy.init初始化ROS2环境，然后创建了一个MinimalPublisher的实例，最后调用rclpy.spin让节点持续运行，直到节点被销毁(rclpy.shutdown)。在shutdown之前，这个函数还调用了 minimal_publisher.destroy_node()去销毁节点。这一点在前面的程序中没有看到。

MinimalPublisher类如下：
```python
class MinimalPublisher(Node):

    def __init__(self):
        super().__init__('minimal_publisher')
        self.publisher_ = self.create_publisher(String, 'topic', 10)
        timer_period = 0.5  # seconds
        self.timer = self.create_timer(timer_period, self.timer_callback)
        self.i = 0

    def timer_callback(self):
        msg = String()
        msg.data = 'Hello World: %d' % self.i
        self.publisher_.publish(msg)
        self.get_logger().info('Publishing: "%s"' % msg.data)
        self.i += 1
```
这一部分逻辑也比较简单使用。整体创建了MinimalPublisher的类，继承自rclpy.node。然后使用rclpy.node.create_timer创建一个500ms调用一次的定时器。在timer_callback函数中，创建了一个std_msgs.msg.String类型的消息，设置了要发布的信息，发布并打印日志。
这中间引用了很多rclpy和std_msgs的API。后面慢慢学习吧，不可能一蹴而就。

然后我们再来看看subscriber_member_function.py的代码。开头也是引用了rclpy和std_msgs的包。main函数的流程也一致，只是这次创建了一个名称叫做MinimalSubscriber的类，继承自rclpy.node。然后使用rclpy.node.create_subscription订阅了topic。订阅的回调函数是listener_callback。在这个函数里面使用rclpy.node.get_logger打印日志。

现在再来修改一下package.xml文件，添加依赖项。
```xml
<exec_depend>rclpy</exec_depend>
<exec_depend>std_msgs</exec_depend>
```
注意这个和ament_cmake的标签不一样。后者之前使用的是一个`depend`标签。
还记得setup.cfg和setup.py这两个文件的区别吗：
* __setup.cfg__ 当包有可执行文件时需要setup.cfg，因此ros2 run可以找到它们
* __setup.py__ 包含如何安装包的说明

现在需要修改setup.py，来添加执行点(entry point):
```python
entry_points={
        'console_scripts': [
                'talker = py_pubsub.publisher_member_function:main',
        ],
},
```
现在再来检查一下setup.cfg文件。内容应当是：
```txt
[develop]
script_dir=$base/lib/py_pubsub
[install]
install_scripts=$base/lib/py_pubsub
```

现在开始检查依赖，然后build整个package.
```bash
$ rosdep install -i --from-path src --rosdistro humble -y
#All required rosdeps installed successfully
$ colcon build
## 如果你里面有多个package,也可以
$ colcon build --packages-select py_pubsub
Starting >>> py_pubsub
--- stderr: py_pubsub                   
/home/galileo/.local/lib/python3.10/site-packages/setuptools/_distutils/cmd.py:66: SetuptoolsDeprecationWarning: setup.py install is deprecated.
!!

        ********************************************************************************
        Please avoid running ``setup.py`` directly.
        Instead, use pypa/build, pypa/installer or other
        standards-based tools.

        See https://blog.ganssle.io/articles/2021/10/setup-py-deprecated.html for details.
        ********************************************************************************

!!
  self.initialize_options()
---
Finished <<< py_pubsub [0.89s]

Summary: 1 package finished [1.51s]
  1 package had stderr output: py_pubsub
```
接着source一下overlay.并在两个终端分别运行talker和listener。
在一个终端执行：
```bash
$ source install/setup.bash
$ ros2 pkg list | grep py_pubsub
py_pubsub
$ ros2 pkg executables py_pubsub
py_pubsub listener
py_pubsub talker
$ ros2 run py_pubsub listener
```
在另一个终端执行：
在一个终端
```bash
$ source install/setup.bash
$ ros2 pkg list | grep py_pubsub
py_pubsub
$ ros2 run py_pubsub talker
```
测试效果如下：
![py_pubsub_test](img/py_pubsub_test.gif)
<p style="text-align:center; color:orange">图7：py_pubsub的测试图</p>

请注意这里的`talker`和`listener`的名称其实是在前面setup.py文件中定义的。

#### 2.5.2 总结
这一章节使用了入门教程提供的示例代码来测试两个node之间通过topic进行通讯。代码尽管不复杂，但是有很多地方需要详细了解才行。

### 2.6 使用c++编写ROS2的server和client
本小节参照入门教程[Writing a simple service and client (C++)](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Writing-A-Simple-Cpp-Service-And-Client.html)的内容。这一部分主要演示了ROS2的service怎么使用。在这一章你会发现请求和响应的结构由`.srv`文件决定。

这一次我们建立一个新的工作空间叫做cmake_ws,之后接下来几篇涉及ament_cmake的工程都放在这个目录中。
```bash
## 你需要先导航到你放置练习工程的目录中
$ mkdir -p cmake_ws/src
## 和前面一样我在操作时始终位于工作区根目录，这一点和官方热门不同，因此命令有一些区别
$ cd cmke_ws
$ 
```
然后我们来创建一个package，名字叫做cpp_srvcli，依赖于rclcpp和example_interfaces，构建类型还是ament_cmake,license还是“Apache-2.0”.请注意命令中名称的位置，要防止写在`--dependencies`后面。另外请注意[example_interfaces](https://github.com/ros2/example_interfaces)也是一个package,它包含构建请求和响应所需的`.srv`文件的包。你可以通过'ros2 pkg list'看到它。至于`.srv`的格式后面在专门做出说明。

如下：
```bash
$ ros2 pkg list | grep example_
example_interfaces
$ ros2 pkg create cpp_srvcli  --destination-directory src  --build-type ament_cmake --license Apache-2.0 --dependencies rc
```
#### 2.6.1 创建server程序
本次将创建一个求和(sum)服务。我们照例打开vscode编辑代码。这次我们将代码写在一个名称叫做`add_two_ints_server.cpp`的文件中。文件中代码如下：
```c++
#include "rclcpp/rclcpp.hpp"
#include "example_interfaces/srv/add_two_ints.hpp"

#include <memory>

void add(const std::shared_ptr<example_interfaces::srv::AddTwoInts::Request> request,
          std::shared_ptr<example_interfaces::srv::AddTwoInts::Response>      response)
{
  response->sum = request->a + request->b;
  RCLCPP_INFO(rclcpp::get_logger("rclcpp"), "Incoming request\na: %ld" " b: %ld",
                request->a, request->b);
  RCLCPP_INFO(rclcpp::get_logger("rclcpp"), "sending back response: [%ld]", (long int)response->sum);
}

int main(int argc, char **argv)
{
  rclcpp::init(argc, argv);

  std::shared_ptr<rclcpp::Node> node = rclcpp::Node::make_shared("add_two_ints_server");

  rclcpp::Service<example_interfaces::srv::AddTwoInts>::SharedPtr service =
    node->create_service<example_interfaces::srv::AddTwoInts>("add_two_ints", &add);

  RCLCPP_INFO(rclcpp::get_logger("rclcpp"), "Ready to add two ints.");

  rclcpp::spin(node);
  rclcpp::shutdown();
}
```
这段代码看似简单，但是本质还是挺复杂的。如果你深入example_interfaces::srv::AddTwoInts::Request和example_interfaces::srv::AddTwoInts::Response去查看，会发现AddTwoInts是一个很复杂的类型。里面用到了很多modern c的新特性。

这段代码的功能其实就是从request里面获取a和b两个变量的值然后相加，再将结果返回给response，同时在服务器这一侧使用`rclcpp::get_logger`打印必要的logger.

程序创建节点使用了`rclcpp::Node::make_shared`函数实现的：
```c++
std::shared_ptr<rclcpp::Node> node = rclcpp::Node::make_shared("add_two_ints_server");
```
为该节点创建一个名为 add_two_ints 的服务，并使用 &add 方法自动在网络上通告它:
```c++
rclcpp::Service<example_interfaces::srv::AddTwoInts>::SharedPtr service =
node->create_service<example_interfaces::srv::AddTwoInts>("add_two_ints", &add);
```
#### 2.6.2 创建client程序
这部分我们将代码写在一个名称叫做`add_two_ints_client.cpp`的文件中。文件中代码如下：
```c++
#include "rclcpp/rclcpp.hpp"
#include "example_interfaces/srv/add_two_ints.hpp"

#include <chrono>
#include <cstdlib>
#include <memory>

using namespace std::chrono_literals;

int main(int argc, char **argv)
{
  rclcpp::init(argc, argv);

  if (argc != 3) {
      RCLCPP_INFO(rclcpp::get_logger("rclcpp"), "usage: add_two_ints_client X Y");
      return 1;
  }

  std::shared_ptr<rclcpp::Node> node = rclcpp::Node::make_shared("add_two_ints_client");
  rclcpp::Client<example_interfaces::srv::AddTwoInts>::SharedPtr client =
    node->create_client<example_interfaces::srv::AddTwoInts>("add_two_ints");

  auto request = std::make_shared<example_interfaces::srv::AddTwoInts::Request>();
  request->a = atoll(argv[1]);
  request->b = atoll(argv[2]);

  while (!client->wait_for_service(1s)) {
    if (!rclcpp::ok()) {
      RCLCPP_ERROR(rclcpp::get_logger("rclcpp"), "Interrupted while waiting for the service. Exiting.");
      return 0;
    }
    RCLCPP_INFO(rclcpp::get_logger("rclcpp"), "service not available, waiting again...");
  }

  auto result = client->async_send_request(request);
  // Wait for the result.
  if (rclcpp::spin_until_future_complete(node, result) ==
    rclcpp::FutureReturnCode::SUCCESS)
  {
    RCLCPP_INFO(rclcpp::get_logger("rclcpp"), "Sum: %ld", result.get()->sum);
  } else {
    RCLCPP_ERROR(rclcpp::get_logger("rclcpp"), "Failed to call service add_two_ints");
  }

  rclcpp::shutdown();
  return 0;
}
```
这段代码也使用了智能指针，我会转么写一篇文章将智能指针。

这段代码先使用rclcpp.init初始化.然后创建node,使用rclcpp::Node::create_client创建client。接着创建request,并设置a和b的值。然后以1s的周期去检查服务器状态，如果服务器不可用就继续等待。rclcpp出错则会报错并退出。如果服务器可用就发送request并用异步方式等待回应，这段代码使用的是`async_send_request`来实现的.使用spin_until_future_complete去等待服务器的响应。如果完成就使用`rclcpp::get_logger`打印结果。最后关闭并推出。

这段程序中还是用到了`atoll`，它的作用和`atol`类似。`atol`是把字符串转成长整形(long int),`atoll`是把字符串转成长长整形(long long int)。主要原因是我们的srv文件中定义的服务输入是int64的：
```txt
int64 a
int64 b
---
int64 sum
```

#### 2.6.3 元文件和编译规则设置
我们需要的两个依赖项是rclcpp和example_interfaces。我们需要在`package.xml`中添加它们.好在我们在创建的时候已经添加。现在只需要检查一下。现在向CMakeLists.txt文件添加依赖项：
```txt
add_executable(server src/add_two_ints_server.cpp)
ament_target_dependencies(server rclcpp example_interfaces)

add_executable(client src/add_two_ints_client.cpp)
ament_target_dependencies(client rclcpp example_interfaces)

install(TARGETS 
        server 
        client 
        DESTINATION lib/${PROJECT_NAME})
```
编辑好之后，我们检查依赖项并编译。
```bash
$ rosdep install -i --from-path src --rosdistro humble -y
#All required rosdeps installed successfully
$ colcon build --packages-select cpp_srvcli
Starting >>> cpp_srvcli
Finished <<< cpp_srvcli [4.09s]                     

Summary: 1 package finished [4.70s]
```

#### 2.6.4 运行程序
在一个终端运行client：
```bash
$ source install/setup.bash
## 确保package可见
$ ros2 pkg list | grep cpp_srvcli
cpp_srvcli
## 查询可执行程序
$ ros2 pkg executables cpp_srvcli
cpp_srvcli client
cpp_srvcli server
## 运行client
$ ros2 run cpp_srvcli client 12 56
```
请注意，理论上服务器要先运行。这里让client运行是为了验证client程序的等待过程是否会报错。我们可以故意等几秒钟再启动server：
```bash
$ source install/setup.bash
## 运行service
$ ros2 run cpp_srvcli server
```
结果如下图8所示。
![cpp_srvcli测试图](img/cpp_srvcli_test.gif)
<p style="text-align:center; color:orange">图8：cpp_srvcli测试图</p>

#### 2.6.5 总结
本章我们学习了ROS2的service的使用，并编写了server和client程序。可以看出这部分的程序还是非常复杂的。至于srv我们本次使用了外部的srv,后面我们还需要学习自己编写srv文件和服务器和客户端的类的编写。

### 2.7 使用python编写ROS2的server和client
本小节参照入门教程[Writing a simple service and client (Python)](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Writing-A-Simple-Py-Service-And-Client.htm)的内容。这一部分功能和上一小节基本一致，只是语言变成了python.



## 三、X
## 四、Y
## 五、Z

## 六、Artemis机器人构想


https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Colcon-Tutorial.html

## 附录
ROS相关：
* [Colcon Tutorial](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Colcon-Tutorial.html)
* [A universal build tool](https://design.ros2.org/articles/build_tool.html)
* [古月居机器人教程](https://book.guyuehome.com/)
* [古月机器人入门21讲](https://class.guyuehome.com/p/t_pc/course_pc_detail/column/p_628f4288e4b01c509ab5bc7a)
* [open-rmf](https://osrf.github.io/ros2multirobotbook/)
* [open-rmf docs](https://osrf.github.io/ros2multirobotbook/)
* [ROS2 for RUST](https://github.com/ros2-rust/ros2_rust)
* [REP 149](https://www.ros.org/reps/rep-0149.html)
* [ROS Tutorials](http://wiki.ros.org/ros_tutorials)
Jetson相关：
* [ament](https://docs.ros.org/en/foxy/Concepts/About-Build-System.html)


Linux相关：
* [Tmux使用教程](https://www.ruanyifeng.com/blog/2019/10/tmux.html)

C++和ROS2语法相关：
* [ROS_PUBLIC](https://floodshao.github.io/2020/03/06/ros2-%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90%E4%B8%8E%E5%AE%9E%E8%B7%B5-Node/)
* [chrono](https://en.cppreference.com/w/cpp/header/chrono)
* [functional](https://en.cppreference.com/w/cpp/header/functional)
* [memory](https://en.cppreference.com/w/cpp/header/memory)
* [rclcpp](https://docs.ros2.org/latest/api/rclcpp/)
* [rclcpp Repository](https://github.com/ros2/rclcpp)
* [std_msgs Repository](https://github.com/ros2/common_interfaces/tree/humble/std_msgs)