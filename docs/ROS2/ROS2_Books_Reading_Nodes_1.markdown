---
title: ROS2读书笔记 (1)
permalink: /ROS2/ROS2_Books_Reading_Note_1/
---

# ROS2读书笔记 (1)

《ROS2机器人编程实践-基于现代从++和Python3》，徐海望，高佳丽
________________________________

## 一、书本基本信息/Basic Information about this Book
本次阅读的书籍名称叫做《ROS2机器人编程实践-基于现代从++和Python3》，作者是徐海望，高佳丽。书号ISBN 978-7-111-71550-4, 由机械工业出版社出版，出版日期2022.10。

本书的两位作者参与过小米铁蛋（CYBERDOG）机器人开发.具有实战经验，因此此书应该不同于那些为了评选各种职称而拼凑的各种著作。本书是基于ROS2开发，尽管本书出版于2022.10,当时LTS版本Humble刚刚发布几个月。但是目前也是市面上以ROS2作为唯一开发平台的少数书籍。多数书籍将ROS1作为描述的主题，而ROS2作为补充内容。所以本书的内容是比较适合当前的开发环境的。

全书总共分为8个章节，正文共330页。按照作者在前沿的描述，前五章是基础内容，后面的内容是建立在前面内容讲解基础上的。后三章是扩展知识内容，内容相对独立。

现代开发人员在开发实战内容时，往往以阅读官方文档和源码为主。但是本书价值是将分散在各处的内容整合成一个整体的学习系统。书中提供了大量的源码（在简单翻阅书籍时发现几乎每页都有命令或者代码），作者也将本书的大量代码开源（网址见附录）。所以也可以看出本书不是以理论见长的，而是以实战见长的。因为源码的存在，也就要求读者也应当以实践的方式去阅读。（作者建议读者准备一台计算机）作者尤其强调了社区的重要性，对于我而言社区往往只是一个问题解答的途径。但是作者强调参数社区讨论的重要性，我表示认同但是暂时可能尚未养成参与社区讨论的习惯。作者的说法是想要了解最新的研究成果需要阅读和发表论文，以及参与会议交流。

## 二、关于本读书笔记
本读书笔记以记录核心思想和理解为主。应当很少提到具体代码。但是会提出代码执行中的问题和改动。ROS2一直在进展，所以当时作者的代码（开发平台是Foxy）能否在Humble代码上很好的运行，暂时不能确定。

## 三、第1章：构建与部署ROS2
详细介绍了ROS2的发行和支持的操作系统详情。安装的一个必要条件是网络要好，在国内这一点尤其重要。
ros-infrastructure/bloom是基于catkin/colcon的自动化打包工具，目标是针对Debian系和RHEL系;superflore (flore是拉丁文的bloom)是一个面向更多Linux发行版本的自动化打包工具。

OpenEmbdded这个发行版本是ROS2的Tier3支持的，这个版本主要针对嵌入式系统（目前主要是ARM32,ARM64,我记得好像也支持RISC-V）。

ROS官方使用rosdep作为依赖解决方案，Arch Linux也可以使用AUR来解决依赖问题。

核心组件：

机器人基础应用组件：

文中介绍了三个版本的区别，因为humble版本可能有改动。读者可以使用
```bash
## 需要首先安装此工具
sudo apt install python3-rosinstall-generator

## 可使用core命令查看所有的tar包
rosinstall_generator ros_core --rosdistro humble --deps --tar

## 可使用base命令查看所有的tar包
rosinstall_generator ros_base --rosdistro humble --deps --tar

## 可使用desktop命令查看所有的tar包
rosinstall_generator ros_desktop --rosdistro humble --deps --tar

```
这里的显示太繁琐，也可以到[ROS2的variants](https://github.com/ros2/variants)中去查看。但是我暂时不知道不同版本的variants是否相同。



[关于DDS版本的说明](https://docs.ros.org/en/humble/Installation/DDS-Implementations.html)：ROS2默认支持的是eProsima的FastRTPS。但目前ROS2 Humble版本支持4种DDS：eProsima的FastRTPS，RTI公司的Connext DDS，Eclipse基金会维护的Cyclone DDS,GurumNetworks的GurumDDS。其中FastRTPS和Cyclone DDS是开源的。对商业比较友好，另外两种都需要商业授权。

URDF为同意机器人描述格式。URDF使用XML格式进行描述，可以描述机器人、传感器、连杆、关节和执行器的基本信息，运动学和动力学的参数。

KDL为运动学和动力学库。在实际的工程中，工程师们并不一定会将控制算法去安全从头实现，而是会借助一些现有的算法库提高工程效率，快速完成算法和工程验证。KDL便是这类库之一。KDL库使用一种被称作KDL树的数据结构来描述机器人构型，包括各类参数。这与ROS的机器人构型不同。因此需要使用一个工具来将ROS中的URDF转换为KDL可处理的数据结构，这个工具便是kdl_parser.

ROS中两个可视化组件RQt和RViz.colcon是ROS2的构建管理工具。这是一个很重要的工具，需要学会它的命令使用。

## 四、第2章：模块化的功能包和节点
第二章，以上来就针对`ROS2 pkg create`的使用方法展开描述。但是对于未入门的用户，可能有一定的门槛。建议读者起码阅读官方而入门文档，再来学习这部分的内容。




## 五、第3章：节点的体系化和扩展

## 六、第4章：ROS2的基础通讯

## 七、第5章：ROS2的扩展通讯



## M、
<本文创作自2024.01.14,完成于？>
## N、附录
* [本书配套源码](https://github.com/homalozoa/ros2_for_beginners_code)