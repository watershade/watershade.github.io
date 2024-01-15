---
title: Robot Motion Planning Knowledge Collection
permalink: /ROS2/The_Detail_Of_ROS2/
---

# Robot Motion Planning Knowledge Collection
This pages is used to record knowledge about Motion Planning.

## Moveit
* [MoveIt 2 Docs](https://moveit.picknik.ai/main/index.html)
![MoveIt Frame](https://moveit.picknik.ai/main/_images/moveit_pipeline.png)

如果你在Ubuntu上已经安装好了ROS2。尽管Moveit是默认没有安装的，但是你可以快速clone仓库，然后编译安装。
```bash
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
cd ~/ws_moveit
colcon build --mixin release

## after all: Setup Your Colcon Workspace
source ~/ws_moveit/install/setup.bash
## or 
echo 'source ~/ws_moveit/install/setup.bash' >> ~/.bashrc

```
可以看到x

## OMPL (The Open Motion Planning Library)
* [OMPL Website](https://ompl.kavrakilab.org/)


##  Nav2
* [Nav2 Website](https://navigation.ros.org/)