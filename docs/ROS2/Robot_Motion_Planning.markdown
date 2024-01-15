---
title: Robot Motion Planning Knowledge Collection
permalink: /ROS2/The_Detail_Of_ROS2/
---

# Robot Motion Planning Knowledge Collection
This pages is used to record knowledge about Motion Planning.

## Moveit
* [MoveIt 2 Docs](https://moveit.picknik.ai/main/index.html)
![MoveIt Frame](https://moveit.picknik.ai/main/_images/moveit_pipeline.png)

如果你在Ubuntu上已经安装好了ROS2 Desktop。尽管Moveit是默认没有安装的，但是你可以快速clone仓库，然后编译安装。
```bash
## 默认没有安装colcon mixin版本，这里需要
sudo apt install python3-colcon-mixin
colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml
colcon mixin update default

## create folder
mkdir -p ws_moveit/src
cs ws_moveit/src

## clone repository
git clone https://github.com/ros-planning/moveit2_tutorials

## download others from Moveit
vcs import < moveit2_tutorials/moveit2_tutorials.repos

## build
sudo apt update && rosdep install -r --from-paths . --ignore-src --rosdistro $ROS_DISTRO -y

## config colcon
cd ..

## 我最初使用下面这条命令，colcon会以全速去编译，结果导致ubuntu崩溃。
colcon build --mixin release

## 改用下面这条命令，速度会慢一些（但也就30秒左右）。顺利完成编译。
## 使用nproc查询，我可以同时执行20路并行任务。
colcon build --mixin release --parallel-workers 8

## 最后设置一下moveit，我的路径不同，可以用pwd查看。
source ~/ws_moveit/install/setup.bash
## or 
echo 'source ~/ws_moveit/install/setup.bash' >> ~/.bashrc

```
可以看到MoveIt底层运动算法调用了三个库：CHOMP planner, OMPL, SBPL。好像也集成了[Pilz Industrial Motion](https://wiki.ros.org/pilz_industrial_motion).

## OMPL (The Open Motion Planning Library)
* [OMPL Website](https://ompl.kavrakilab.org/)


##  Nav2
* [Nav2 Website](https://navigation.ros.org/)


## OpenRave (Open Robotics Automation Virtual Environment)
* [OpenRave Website](www.openrave.org)
* [OpenRave Github](https://github.com/rdiankov/openrave)

