---
title: The Index of Pages about PMSM Motor Control
categories: [Motor Control]
date: 2024-02-03
permalink: /MC/PMSM_Control_Index/
---


# PMSM电机控制博客索引

## 前言
PMSM/BLDC电机的使用越来越广，控制要求也越来越高。尤其是近些年机器人技术的发展，几乎所有公司开始一股脑的涌入了机器人赛道，而机器人中的一个核心不见就是电机。而机器人对于电机的控制要求也越来越高。除了传统对于电机快准稳等要求之外，机器人对于多个电机协调运动也变得越来越重要。因此，对于电机的控制算法的研究也越来越重要。

这一组博客文章将重点整理各种电机控制需要的算法、理论和技术的整理、思考和研究。

## 索引

1. FOC（Field-Oriented Control）
FOC（Field-Oriented Control）是一种基于场域控制的电机控制算法，它通过控制电机的转矩和电流来控制电机的转速。

2. MTPA（Maximum Torque Per Ampere）控制策略
 所谓MTPA，即最大转矩电流比（Maximum Torque Per Ampere），可以理解为输出转矩相同条件下，所需定子电流最小的控制策略。


3. MTPV（Maximum Torque Per Voltage）控制策略
所谓MTPV.即最大转矩电压比（Maximum Torque Per Voltage），可以理解为输出转矩相同条件下，所需定子电压最小的控制策略。

4. LM（Low Megatronic）控制策略
所谓LM，即弱磁控制（Low Megatronic）控制。


5. FW控制策略
最小功率损耗控制策略



6. id最小控制
目标控制要求是id===0的控制方式.


4. 各种滤波器

5. 电机控制库


## 附录

* [知乎/沉沙Motor一下](https://www.zhihu.com/people/gun-ne-ni)
* [Matlab弱磁控制介绍](https://ww2.mathworks.cn/discovery/field-weakening-control.html)
* [使用霍尔传感器的 PMSM 的磁场定向控制](https://ww2.mathworks.cn/help/mcb/gs/foc-pmsm-using-hall-sensor-example.html)



