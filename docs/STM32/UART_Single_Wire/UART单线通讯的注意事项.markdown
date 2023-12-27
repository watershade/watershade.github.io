---
title: You should use external resistor for STM32 UART Signle Wire
permalink: /STM32/UART_Signle_Wire/
---


# STM32U5的UART单线通讯上拉电阻问题
UART的单线半双工的上拉电阻问题
------------------------------

## 前言
在移植TMC-API初步完成之后，就像测试以下是否能够正常的读写操作。结果发现能写不能读。也就是说通过逻辑分析仪可以看到发送的数据但是看不到接收的数据。那怎么办呐？
本篇文章就是记录移植过程的问题和调试办法。

另外需要说明的是，尽管本文章的标题是STM32U5的UART单线通讯。但它应当适用于在STM32的其它系列上。

## 第一招：简化矛盾，定位问题
### 1.1 上逻辑分析仪
在分析了目前的问题之后，我决定简化问题：先定位是硬件还是软件问题。我先用逻辑分析仪查看了波形。发现线路上平坦无垠，如果我站在示波器的波形上，相信前方是一望无际一片光明的。然后在三维世界的我此时十分气馁。

### 1.2 内部上拉
然后我分析波形发现一直是低电平，因此意识到我没有加上拉电阻。加上上拉电阻之后，尽管波形变高了，但是还是一片平坦。我决定查看一下半双工通讯的API是不是有我没注意的地方。

### 1.3 工作模式切换
查看了UM2911之后，我发现单线通讯不是那么简单的。需要切换工作模式：
```c
HAL_StatusTypeDef HAL_HalfDuplex_EnableTransmitter(UART_HandleTypeDef *huart);
HAL_StatusTypeDef HAL_HalfDuplex_EnableReceiver(UART_HandleTypeDef *huart);
```
这两个函数的实现并不复杂：
```c
// enable transmitter
  /* Clear TE and RE bits */
  ATOMIC_CLEAR_BIT(huart->Instance->CR1, (USART_CR1_TE | USART_CR1_RE));

  /* Enable the USART's transmit interface by setting the TE bit in the USART CR1 register */
  ATOMIC_SET_BIT(huart->Instance->CR1, USART_CR1_TE);

// enable receiver
  /* Clear TE and RE bits */
  ATOMIC_CLEAR_BIT(huart->Instance->CR1, (USART_CR1_TE | USART_CR1_RE));

  /* Enable the USART's receive interface by setting the RE bit in the USART CR1 register */
  ATOMIC_SET_BIT(huart->Instance->CR1, USART_CR1_RE);

```
其实就是切换以下是打开TE(Transmitter enable)位还是RE(Receiver enable)位。有半双工通讯（比如RS485）经验的朋友应该知道，当没有数据要发送时，就默认让总线进入接收状态。当需要传输时再将通讯切换到发送状态。总起来就是一句话：学会倾听。

好了按照上面的问题分析，修改了代码。发现示波器上出现了起伏。然后却没看到回应。就是说有发送却没有接收。顿时有点气馁，就去查验代码有没有问题。（误区，不够冷静自信，丧失了方法论就丢弃了方向感。）
在无果的一通乱搞之后。发现毫无效果。三维世界和二维世界的我的心情都是一样的起伏。

### 1.4 定位问题
次日，继续分析自己目前的主要问题。决定确定一下是不是TMC驱动板的硬件有问题。我就用手边的USB转串口按照下面的电路图连接了TX和RX和TMC驱动板的PDN_UART通讯。是万用表测量接通之后，开始折腾。
![UART收发接线](img/双线接线图.png)

<center><font color = yellow>图1：双线半双工通讯MCU接线图</font></center>

在发送正确的Read数据包（带CRC）后，是可以收到数据的。比如我发送`05 00 00 48`之后
我就会收到8个字节的回复。因此说明硬件没有问题。备注：为了防止目前模块的状态不处于UART状态，每次上电没都会先发送8个字节`05 00 80 00 00 00 40 47 `将PDN_UART配置位UART总线。

那么既然我的从机驱动模块是OK的，那就是我的主机的配置有问题。因为这次通讯我并没有用图1的接线，而是使用STM32的单线半双工模式，通讯就变成了MCU的TXD连接TMC驱动的PDN_UART。类似如下连接：
![UART收发接线](img/单线接线图.png)

<center><font color = yellow>图2：单线半双工通讯MCU接线图</font></center>
因此我就怀疑是不是单线半双工通讯我没有用好？

## 第二招：按图索骥、步步为营
### 2.1 配置内部上拉
前面讲了，软件模式是AF_OD模式且没有上拉。
```c
    GPIO_InitStruct.Pin = TMC_UART_Pin;
    GPIO_InitStruct.Mode = GPIO_MODE_AF_OD;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
    GPIO_InitStruct.Alternate = GPIO_AF8_UART5;
```
我先前将其改为了：
```c
    GPIO_InitStruct.Pin = TMC_UART_Pin;
    GPIO_InitStruct.Mode = GPIO_MODE_AF_OD;
    GPIO_InitStruct.Pull = GPIO_PULLUP;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
    GPIO_InitStruct.Alternate = GPIO_AF8_UART5;
```

这种情况下是有发送波形，但是示波器就是没有接收波形。所以应该是硬件或者硬件相关的配置有问题。而不是软件本身的逻辑问题。

### 2.2 连接外部上拉
那我自然而然的就想到是不是内部上拉不行，我试一下外部上拉。说干就干。找来了一个直插的10K电阻，将其用杜邦线的接头上。连线方式非常的“有创意”，建议大家不要学习。 :sweat_smile: :sweat_smile: :sweat_smile: 

![电阻接法实图](img/测试实图.jpg)

<center><font color = yellow>图3：单线半双工通讯MCU接线图</font></center>

然后在软件里将上拉去掉。这时候再看示波器就正常了。然后在检查软件的输出，终于收到了回应。

### 2.3 确认
基于以上的原因，我就想知道我什么会这样。我终于在RM0456这个参考手册里看到这样一句话：

```txt
66.5.16 USART single-wire Half-duplex communication Single-wire Half-duplex mode is selected by setting the HDSEL bit in the USART_CR3 register. In this mode, the following bits must be kept cleared:
• LINEN and CLKEN bits in the USART_CR2 register,
• SCEN and IREN bits in the USART_CR3 register.
The USART can be configured to follow a Single-wire Half-duplex protocol where the TX and RX lines are internally connected. The selection between half- and Full-duplex communication is made with a control bit HDSEL in USART_CR3.
As soon as HDSEL is written to 1:
• The TX and RX lines are internally connected.
• The RX pin is no longer used.
• The TX pin is always released when no data is transmitted. Thus, it acts as a standard I/O in idle or in reception. It means that the I/O must be configured so that TX is configured as alternate function open-drain with an external pull-up.
Apart from this, the communication protocol is similar to normal USART mode. Any conflict on the line must be managed by software (for instance by using a centralized arbiter). In particular, the transmission is never blocked by hardware and continues as soon as data are written in the data register while the TE bit is set.
```

大致意思就是说单线半双工模式下，TX和RX连接在了一起，RX引脚不再被使用，<font color=red>TX引脚需要被配置位AF_OD模式且需要外部上拉</font>。除此之外通讯和普通USART模式通讯类似。
这个信息也确认了我外加上拉的操作。


## 第三招：深入思考
尽管我确认了需要外部上拉，但是我还是有一个疑问。请看GPIO的框图：
![GPIO结构图](img/GPIO框图.png)

<center><font color = yellow>图4：GPIO框图</font></center>

可以看到无论输入还是输出其实如果配置为上拉那么信号不会因为方向而改变，那为什么内部上拉就不行呐？Rpu和外部电阻除了阻值不一样还有什么不一样？

这个问题目前仍然悬而未决。