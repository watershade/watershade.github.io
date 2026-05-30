---
title: "用gpio来休眠与唤醒orange pi 3（armbian）"
date: 2020-06-14 00:00:00 +0800
categories: [Embedded Linux]
tags: [orange pi专栏收录该内容, ROS2, 日积月累计划, linux, Mentor Xpedition]
description: ""
layout: article
csdn_id: 106959895
---

### **1、 linux的几个状态**

freeze

standby

mem

disk

可在/sys/power中查看状态

cd到/sys/power之后可以“cat state”查看支持的状态

以root权限使用“echo xxx > /sys/power/state”来改变状态。其中xxx可以是standby，freeze，mem，disk等

### 2、 选择gpio

orange pi 3使用的是allwinner H6 CPU。它所有代唤醒（wakeup）功能的引脚都在PL口上。不同于PA、PB，PC,PD...等端口。这个端口在设备树中的表示也是不同的：

PA~PK口分别用0~10表示。在设备树中通常是这样表示的 ：
[code] 
    gpios = <&pio 0 11 GPIO_ACTIVE_HIGH>;  // PA11
    
    gpios = <&pio 3 9 GPIO_ACTIVE_HIGH>;   // PD9
[/code]

而PL口上通常这样表示
[code] 
    gpios = <&r_pio 0 8 GPIO_ACTIVE_HIGH>;  // PL8
[/code]

可以看出分别PL口的独特性.另外似乎PM也支持wakeup功能。

再有一个相关的问题就是gpio-keys的键码可参考<https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h>

这里面定义了KEY_POWER,KEY_WAKEUP等的code。

### 4、 配置设备树

4.1 编写

编写支持gpio-keys的dts文件.不妨叫做gpio-pin-wakeup.dts： 
[code] 
    /dts-v1/;
    /plugin/;
    
    / {
    	compatible = "allwinner,sun8i-h3";
    
    	fragment@0 {
    		
    		target = <&pio>;
    		__overlay__ {
    			poweroff_pins:poweroff_pins {
            		allwinner,pins = "PA13";
            		allwinner,function = "gpio_out";
    
    			};
    		};
    	};
    
    	fragment@1 {
    	
    		target-path = "/";
            	__overlay__ {
                		poweroff: poweroff {
                    	compatible = "gpio-poweroff";
                    	gpios = <&pio 0 13 1>;
     			};
        		};
    	};
    };
    
[/code]

注意PL10暂不能使用，因为它已经被分配给了BT-WIFI-ON，具体可以查看原理图。事实上如果不改动系统文件，目前只有PL8是可自由使用的。另外似乎PM也可用于唤醒源。但是它也已经被完全占用了。

同时不妨再分配一个sleep按钮，设备树如下：
[code] 
    /dts-v1/;
    /plugin/;
    
    / {
    	compatible = "allwinner,sun50i-h6";
    	/*
    	 * This fragment is needed only for the internal pull-up activation,
    	 * external pull-up resistor is highly recommended if using long wires
    	 */
    	fragment@0 {
    		target = <&pio>;
    		__overlay__ {
    			gpio_but_sleep: gpio_but_sleep {
    				pins = "PH3";
    				function = "gpio_in";
    				bias-pull-up;
    			};
    		};
    	};
    
    	fragment@1 {
    		target-path = "/";
    		__overlay__ {
    			gpio-keys-user {
    				/*
    				 * Use "gpio-keys" for EINT capable pins, "gpio-keys-polled" for other pins
    				 * add "poll-interval" property if using "gpio-keys-polled"
    				 */
    				compatible = "gpio-keys";
    				autorepeat;
    				pinctrl-names = "default";
    				pinctrl-0 = <&gpio_but_sleep>;
    
    				sleep_button {
    					label = "KEY_SLEEP";
    					linux,code = <142>; /* KEY_SLEEP, see include/uapi/linux/input-event-codes.h */
    					linux,input-type = <1>;     // EV_KEY
    					gpios = <&pio 7 3 1>; /* PD15 GPIO_ACTIVE_LOW */ 
    					gpio-key;
    				};
    			};
    		};
    	};
    };
    
[/code]

将这个设备树文件叫做gpio-key-sleep.dts

4.2 编译

armbian支持arrmbian-add-overlay,但不幸的是它恰恰不支持H6.现需要自己编写完成dts之后用dtc命令编译成dtbo文件。
[code] 
    dtc -@ -q -I dts -O dtb -o gpio-key-wakeup.dtbo gpio-key-wakeup.dts
    
    dtc -@ -q -I dts -O dtb -o gpio-key-sleep.dtbo gpio-key-sleep.dts
[/code]

4.3 配置armbianEnv.txt

在其中添加一行：
[code] 
    user_overlays=gpio-key-wakeup gpio-key-sleep
[/code]

### 5、测试

可进入root权限后使用

cat /sys/power来获取当前支持的几种sleep模式

使用echo xxx > /sys/power/state来进入想要的状态

另外在配置之后还可以使用evtest来测试中断源是否正常.

### 6、 流程归纳

首先选择具有中断可作为唤醒源的按键，然后编写设备树dts源文件，编译设备树overlay的dtbo文件，接着将编译好的dtbo文件放到/boot/overlay-user文件夹中。最后修改armbianEnv.txt文件，重启系统。

尽管看似流程简单，中间设计很多细节。竟然搞了两天时间。总在细枝末节上折腾，什么时候才能游刃有余？