---
title: Modern CPP MicroSoft Guideline
categories: [Programming Language]
date: 2024-02-10
permalink: /PL/modern_cpp_microsoft_guide/
---

# Modern CPP MicroSoft Guideline
Modern入门学习笔记之一：来自微软Modern C++介绍
____________________________________________________

# Modern CPP MicroSoft Guideline
无论是ROS2还是一些新的CPP工程都开始慢慢转向了Mordern C++。 据我所知目前（2024年初）C++的很多项目普遍将C++17作为目标开发语言。之前的C++基本上是C的超集，它允许C语言的样式编程等很多特性。但是因此也增加了C++的复杂性。Modern C++的目标是更加简单安全美观，因此有必要抛弃对C的向后兼容。

本文将[Microsoft提供的Modern C++的介绍](https://learn.microsoft.com/zh-cn/cpp/cpp/welcome-back-to-cpp-modern-cpp?view=msvc-170)作为学习参考。目前Modern C++有四个版本：C++11，C++17，C++20和C++23. Modern C常见的也有C11和C17。 

## 一、Modern C++概述

### 1.1 资源和智能指针
C 样式编程的一个主要 bug 类型是内存泄漏。 泄漏通常是由未能为使用 new 分配的内存调用 delete 导致的。 现代 C++ 强调“资源获取即初始化”(RAII) 原则。 其理念很简单。 资源（堆内存、文件句柄、套接字等）应由对象“拥有”。 该对象在其构造函数中创建或接收新分配的资源，并在其析构函数中将此资源删除。 RAII 原则可确保当所属对象超出范围时，所有资源都能正确返回到操作系统。

C++ 标准库提供了三种智能指针类型：`std::unique_ptr`、`std::shared_ptr` 和 `std::weak_ptr`。 智能指针可处理对其拥有的内存的分配和删除。 

关于RALL原则，微软也提供了[一页介绍](https://learn.microsoft.com/zh-cn/cpp/cpp/object-lifetime-and-resource-management-modern-cpp?view=msvc-170)。这篇文章介绍的很详细。和很多低级语言(如C)一样，C++也没有自动回收机制，需要用户自己管理资源。它new出来的内存，需要delete显式的回收。用C或者C++的出现资源泄露，内存践踏是很常见的时，甚至是高级编程者也不能避免。正因如此新型的RUST语言就凭借内存安全特性获得了大批关注。新式 C++ 通过声明堆栈上的对象，尽可能避免使用堆内存。 当某个资源对于堆栈来说太大时，则它应由对象拥有。 当该对象初始化时，它会获取它拥有的资源。 然后，该对象负责在其析构函数中释放资源。 在堆栈上声明拥有资源的对象本身。 对象拥有资源的原则也称为“资源获取即初始化”(RAII)。


智能指针的详细信息可以看[这里的描述](https://learn.microsoft.com/zh-cn/cpp/cpp/smart-pointers-modern-cpp?view=msvc-170).

别忘了，智能指针需要添加头文件<momery>.

### 1.2 std::string和std::string_view
C样式的字符串时bug的另一个来源。c++标准库的string类和C++17引入的只读权限的string_view为字符串读写带来了更安全的操作。而且功能更强大。

### 1.3 vector和其它容器
使用标准库容器。
vector
map
unordered_map

### 1.4 标准库算法


### 1.5 使用auto代替显式声明？
对于模板类，auto非常有用。


### 1.6 优先使用constexpr，避免使用宏


### 1.7 




## 二、

