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

## 三、项目开发
## 四、项目开发
## 五、项目开发

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


Linux相关：
* [Tmux使用教程](https://www.ruanyifeng.com/blog/2019/10/tmux.html)

