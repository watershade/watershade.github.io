<head>
    <script src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>
    <script type="text/x-mathjax-config">
        MathJax.Hub.Config({
            tex2jax: {
            skipTags: ['script', 'noscript', 'style', 'textarea', 'pre'],
            inlineMath: [['$','$']]
            }
        });
    </script>
</head>

---
title: CAN-FD的位定时的思考
permalink: /CAN_FD/Bit_Timing/
---


# CAN-FD的位定时
CAN-FD bit timing of STM32

_______________________________________


## 一、 概述
当我在初次使用CUBEMX配置CAN-FD接口的时候，对于参数的设置往往有些迷茫，因为尽管我知道位定时的要求但是ST的CAN-FD的要求或者说命名往往让人误解。但是如果了解之后，你应该就会游刃有余的掌握这些位定时参数的设置。

下图以STM32G0B1的位定时为例来说明一下：

![image.png](img/CAN配置.png)
<p style="text-align:center; color:orange">图1：CUBEMX中的FDCAN配置 </p>

乍一看，你以为只有Bit Timing Parameters下面的才是和位定时相关的。但是CAN FD相关的位定时需要配置两部分的参数。下面我来详细说明一下。

## 二、CAN FD标准中对于位定时的要求
### 2.1 位定时的组成和基本概念
CAN FD相关的位定时通常由两部分组成。为了说明这个情况没有必要引用一下AN5348（ST官网搜索）上的图。（这里不再赘述CAN FD协议的详细解释，如果需要了解CAN FD相关的描述可以看AN5348或者其它相关文档。）
![CAN FD传输阶段](img/CAN_FD传输阶段.png)
<p style="text-align:center; color:orange">图2：CAN FD传输阶段 </p>
可以看到CAN-FD由两个不同的传输阶段，分别是仲裁阶段和数据阶段。这两个阶段的波特率可以不同。我们所谓的bit timing其实是波特率的倒数。比方说某个CAN网络传输的比特率是500Kbps，那么每一个bit的时长就是2000ns。因为这两个阶段的波特率在CAN FD中是独立配置的，不像CAN 2.0那样整个传输过程只有一个波特率。这两个不同的波特率阶段就需要两套位时序系统。需要说明的是数据阶段是从BRS切换启用到CRC分隔符之间的阶段。剩余的两个阶段都是仲裁阶段，它的位定时一般叫做标称位定时。
和CAN 2.0相同的是，CAN FD的这组位时序的构成和CAN2.0一样都是由四部分组成：
![Norminal Bit time](img/位定时0.png)
<p style="text-align:center; color:orange">图3：标称位定时 </p>

![Data Bit time](img/位定时1.png)
<p style="text-align:center; color:orange">图4：数据位定时 </p>

正如上面两张图展示的那样，这两套位定时分别称作Norminal Bit time和Data Bit Time.在CAN FD specification v1.0中一般将这两种定时分别用符号m(N)和m(D)表示。为了便于后面的描述，我将这四个段的中英文名称分别描述如下：
SYNC_SEG:同步段，synchronization segment。固定位一个1TQ。一般期望边缘（edge）发生在同步段内。
PROP_SEG:传播段，propagation segment。按照CAN FD协议的要求一般是1~32个TQ。但可以更多。（can_fd_spec的page 27.手册在附件中）
PHASE_SEG1:相位缓冲段1，PHASE BUFFER SEGMENT1。按照CAN FD协议的要求一般是1~32个TQ。但可以更多。（can_fd_spec的page 27.）
PHASE_SEG2:相位缓冲段1，PHASE BUFFER SEGMENT2。按照CAN FD协议的要求需要是PHASE_SEG1和Information Processing Time中的更大者。
IPT: 消息处理时间,information processing time。can_fd_spec要求IPT要小于或者等于2TQ。而它的意义是从采样点开始（到CAN控制器采集到电平）的那个时间段。用来计算随后的位电平。它的长度一般是由CAN控制器本身的实现确定的。ST对IPT的描述是`The Information Processing Time (IPT) is 0, meaning the data for the next bit is available at
the first clock edge after the sample point.`大概意思就是说它的IPT很快，就是采样点发生后的下一个时钟。一般一个TQ的长度都是要几倍的时钟。所以大概需要0~1个TQ。
请注意上面的TQ大小是对CAN FD控制器的要求。如果CAN2.0标准对TQ的要求要低的多：
SYNC_SEG：1TQ
PROP_SEG： 1~8 or More
PHASE_SEG1: 1~8 or More
PHASE_SEG2: max(PHASE_SEG1, IPT)
IPT: <= 2TQ
可以发现FD CAN对位定时的要求其实是比CAN2.0高的。ST的CAN FD控制器的要求满足两者，后面再详细介绍。

上面的描述中牵涉到TQ和采样点的概念。采样点的定义是总线电平被采集的时间点，位于PHASE_SEG1的末尾。或者说PHASE_SEG1和PHASE_SEG2交界处。TQ是CAN位定时的最小时间单位。对于CAN来说它的不可分的最小时间单位就是TQ。你可以简单的认为它就是CAN世界的时钟或者时间分辨率。这个TQ是CAN控制器时钟和分频器一起产生的。在CUBEMX中其实可以明确的看到norminal time quamtum。在ST的CAN FD控制器里面data time quamtum可以和norminal time quamtum不一样。（分频器设置不同）

![位定时配置](img/位定时2.png)
<p style="text-align:center; color:orange">图5：位定时配置 </p>

好了讲完了上面的内容，我们大致可以总结出以下公式：
m(N) = SYNC_SEG(N) + PROP_SEG(N) + PHASE_SEG1(N) + PHASE_SEG2(N)
m(D) = SYNC_SEG(D) + PROP_SEG(D) + PHASE_SEG1(D) + PHASE_SEG2(D)
因为数据段的速率不小于仲裁段，所以m(N) >= m(D).

## 2.2 再同步时间宽度SJW的探讨
其实上面关于位定时的描述还不够完善。在位定时中还有一个很重要的概念就是SJW，即reSynchronization Jump Width.再同步补偿宽度。在阅读can_fd_spec的时候我遇到一个问题。这个资料上对于SJW的描述如下：
```txt
As a result of RESYNCHRONIZATION PHASE_SEG1 may be lengthened or PHASE_SEG2
may be shortened. The amount of lengthening or shortening of the PHASE BUFFER SEGMENTS has an upper bound given by the RESYNCHRONIZATION JUMP WIDTH. The RESYNCHRONIZATION JUMP WIDTH(N) shall be programmable between 1 and min(16,
PHASE_SEG1(N)), the RESYNCHRONIZATION JUMP WIDTH(D) shall be programmable between 1 and min(4, PHASE_SEG1(D)).

再同步的结果是增长PHASE_SEG1的时长或者缩短PHASE_SEG2的时长。增长或者缩短的量由SJW给出上限。SJW(N)应当被配置为1到min(16,PHASE_SEG1(N))的范围内。SJW(D)应当被配置为1到min(4,PHASE_SEG1(N))的范围内。
```
这段话听起来好像没有问题。但是实际上，这里的取值范围和ST的cube中关于SJW的范围设置有很大的不同。我们可以理解的是PHASE_SEG2的长度应该大于SJW。否则会出现PHASE_SEG2消失的情况。这个can_fd_spec不是ISO的手册，是Bosch较早起草的V1.0版本。后面应该会有改动。
所以我设法查到了ISO 11898-1：2015的11.3 PCS specification。
![各时段要求表格](img/位定时各时段要求.png)
<p style="text-align:center; color:orange">图6：位定时参数配置表 </p>

关于本表，手册还有一句说明：`With the exception of thesynchronization segment, which shall be exactly one time quantum long, implementations may allowtime segments that exceed the minimum required configuration ranges specified in Table 8`。就是说除了同步段时1个TQ之外，其余的值可以超过表8中的取值。

The following restrictions shall be met for the configuration of the bit time segments.
- The information processing time shall be less than or equal to 2 time quanta long.  (要求  $ IPT \leq 2TQ$, 和前面要求一致.)
- In data bit time, Phase_Seg2 shall be greater than or equal to the maximum information processing time. (数据段要求 $Phase\_Seg2 \geq IPT $, 要求一致)
- In nominal bit time, Phase_Seg2 shall be greater than or equal to the maximum of these two items:SJW and the information processing time. (仲裁段要求$Phase\_Seg2 \geq \max(SJW,IPT) $)
- In nominal bit time and in data bit time, SJW shall be less than or equalto the minimum ofthese twoitems: Phase_Seg1 and Phase_Seg2.(要求$ SJW \leq min(Phase\_Seg1,Phase\_Seg2) $)

In case of synchronization, Phase_Segl may be longer and Phase_Seg2 may be shorter than its programmed value. The position of the sample point may differ in the two bit timing configurations; the length of the Prop_Seg may be zero in the configuration for the data bit rate. 

在同步时，Phase_Segl应当大于它编程的值，Phase_Seg2应当小于它编程的值。采样点的位置可以有两套不同的位定时配置。在数据速率的计算中Prop_Seg的长度可以配置为0.

In a CAN implementation, Prop_Seg and Phase_Seg1 do not need to be programmable separately; it shall be sufficient to program the sum of Prop_Seg and Phase_Segl. The total number of time quantain a nominal bit time shall be programmable at least from 8 to 25 for implementations that are not FD enabled, For implementations that are FD enabled, the total number of time quanta in a data bit time shall be programmable at least from 5 to 25 and in a nominal bit time at least from 8 to 80.

在CAN实现中，Prop_Seg和Phase_Seg1不需要分别配置；对Prop_Seg和Phase_Seg的总和进行配置就足够了。对于FD没有启用的实现，一个标称位时间（nominal bit time）的总TQ数应该配置为至少从8到25个TQ；对于FD已经启用的实现，则一个数据段位时间（data bit time）内的总TQ数至少应当配置为5到25个TQ，而标称位时间的总TQ应当至少被配置为在8到80之间。（上面的数值是居于表8的。如果你的TQ范围非常大，我的理解是这里的数值范围也适当的扩大。）

其实上面转载的图标和内容我可可以基本归纳出来以下几个要点：
* SJW不仅要小于Phase_Seg2，还要小于Phase_Seg1
* 传播段Prop_Seg和Phase_Seg1可以一起配置
* IPT不大于两个TQ
* 同步段Sync_Seg总是为1TQ。
* 标称位定时和数据位定时可以完全不同
* FD是否启用可以影响位定时各个阶段的配置


### 2.3 位同步的机制
CAN的同步机制是即便在异步通讯中也能保证各节点实时性的关键技术之一。要说清楚位同步机制，我们首先要弄懂为什么会产生不同步，什么时候才开始位同步以及怎么同步。
CAN协议通讯方法叫做NRZ (non-return to zero)方式。各个位的开头和结尾都没有附加同步信号。发送单元以与位时序同步的方式开始发送数据。另外，接收单元根据总线上电平的变化进行同步并进行接收工作。但是，发送单元和接收单元存在的时钟频率误差及传输路径上的（电缆、驱动器等）相位延迟会引起同步偏差。因此接收单元通过硬件同步或者再同步的方法调整时序进行接收。（以上文字部分摘取自资料5）
简单的来说，CAN控制器节点会适时的比较CAN_TX和CAN_RX两个线上的相位差来作为同步的依据。
CAN选择了两种同步方式：硬同步（HARD SYNCHRONIZATION）和再同步（RESYNCHRONIZATION）（RESYNCHRONIZATION）。
#### 2.3.1 硬同步
硬同步，可以等同与强制同步。硬同步会重新开始位定时序列，强制将sync_seg和边缘对齐。硬同步不受SJW的限制。
在总线空闲、暂停传输和在INTERMISSION的第2或3位传输期间，只要出现从隐性到显性的边沿，就会执行硬同步。在从 EDL 到 r0 的隐性到显性边沿进行硬同步。对于普通的FD数据帧来说，除了SOF需要硬同步，在EDL像r0转变的时候也会出现硬同步。
其实具体的规则应该非常复杂，还在这部分不需要软件实现。就不再深入了解了。

#### 2.3.4 再同步
在总线电平出现隐形到显性的变化时（除了硬同步的情况，其实规则非常复杂），就会发生再同步。这时候会根据检测到的边缘和期望的采样点时间进行对比。当不同步时会出现两种情况：
* 当边沿出现在Prop_Seg和Phase_Seg1之间时。在Phase_Seg1上插入不多于SJW个TQ的时长，以尝试将下一个位的边缘调整到Sync_Seg.这一位的采样点也随之移动到了下一个边缘之前。
* 当边缘在出现Phase_Seg2上时。立即减小不多于SWJ个TQ的时长，以期望将下一个位的边缘移动到下一个位的Sync_Seg上。因为这一位的采样点已经在下一个边缘之前，因此不需要调整。

当然如果SJW太短可能会导致当同步误差很大时，难以通过再同步。但如果SJW太长，采样点也会有较大的偏移（极端情况下采样点和边缘靠的太近，很容易就出现采样错误的情况）
关于SJW的设置我还是没有找到很能说服我的方法。估计只能实际测试。好在目前CAN的帧不会太长，经过硬同步之后，采样偏差应该不会太大，再同步的压力不会太大。

### 2.4 关于传播段延迟的估计
下图来在附件2链接的视频中截取的一张图片：
![传播延迟](img/CAN传播延迟.png)
<p style="text-align:center; color:orange">图7：传播延迟定义 </p>

可以从图表中看到所谓的传播延迟实际上由两部分组成，一部分是CAN收发器（有些人也把它叫做PHY）的信号转换延迟（回环延迟）和信号传播延迟。
前者需要查看使用的收发器表格，因为有两个收发器所以要计算两个收发器的收发和。我们以TCAN1042V-Q1的数据表为例，有回环延迟参数：

![回环延迟](img/回环延时.png)
<p style="text-align:center; color:orange">图8：数据位定时 </p>

图中的tProp(LOOP1)和tProp(LOOP2)分别表示隐性到显性和显性到隐性的回环延迟。
信号传播延迟大概是一米5ns（按照2x10^8的信号传播速度）。
我们以使用TCAN1042V-Q1收发器，两个节点距离50米为例。则整个传播延时就是：
2 x ( 100 + 250) 到 2 x ( 175 + 250)之间。即传播延迟大概在700ns到850ns之间。

### 2.5 关于每个段设置的一些看法
（本小节是个人的一些想法，因为不具备专业的通讯背景，所以以下论述并不具有权威性。这些看法只是为了抛砖引玉，并希望获得专业人员的指点。谢谢！）

正如图5展示的那样，大多数CAN控制器都将PROP_SEG和PHASE_SEG1合并位一个TSEG1，相应的PHASE_SEG2被更名为TSEG2以与之相配。而SYNC_SEG因为固定是1TQ的常量，因此就不体现在CAN控制器的配置中。那么对于软件工程师来说，一般需要配置的就是TSEG1和TSEG2.因为FD有标称和数据两套位定时，所以就有TSEG1(N),TSEG2(N),TSEG1(D),TSEG2(D)四个变量。此外还有上面的SJW，这样就又增加了SJW(N)和SJW(D)这两个变量。

所以核心的问题就变成怎么配置这6个变量。（TQ的配置在这里先不讨论）为了弄清楚这个问题，我们首先要搞清楚这个问题的核心是什么？其实这个通讯问题的核心就是在要求的通讯速率和其它限制条件下如何提高通讯质量？就位定时参数配置这个问题来说，通讯的核心之一是如果降低采样的错误率，就是说你收到的信息就是别人发送的。因此怎么选择和调整采样点是整个问题的核心之一。

这个核心问题其实有几个衡量的维度：首先、是在目前的状况下通讯的误码率高不高？第二、在目前的环境状况下，总线抗干扰的能力如何？第三、当添加或者删除节点时总线的鲁棒性高不高？第四、当相互通讯的节点变化时，还能否保证一样优秀的通讯质量？

### 2.5.1 理想采样点
![分析情况图1](img/分析情况1.png)
<p style="text-align:center; color:orange">图9：理想采样点 </p>
现在我们先看图9，我将这张图叫做理想采样点图是因为我们理想的采样点应该位于两个bit位跳变的中间。如果只单纯的考虑采样点的选择，这应该是可以理解的。因为太靠近要采样bit的开始或者太靠近这个bit的结尾，当发生干扰时很容易错误的采样到了上一位或者下一位。所以理想的情况当然是，当然是位于两个跳变的中间位置。

### 2.5.2 理想面临的挑战
如果真的这么简单，CAN就不需要提供那么复杂的设置了。还记得传播段这个问题吗？你可能会问为什么其它的通讯根本就不需要担心传播段。传播段存在只是影响时延而已，不是吗？
说到这个问题就需要提到CAN使用的技术CSMA/CD (Carrier Sense, Multiple Access/Collision Detection) 。这项技术的中文名称叫做“载波监听多路访问/碰撞检测”。简单描述就是所有的阶段都要监听总线上的载波，当要发送的时候也是一边发一边监听。当检测到接收到的和发送到的不一样（被别的节点发送的显性电平覆盖，这部分不需要软件参与。详细的可以了解一下线与的概念）. 

既然要一边发一边监听，而且要监听的是整个总线线与之后的结果以实现碰撞检测。就需要让所有节点几乎同步（错位不超过一个bit）。不然因为可能因为延时导致错位或者，导致高优先级的节点反而停止了。这就是为什么要增加传播段的原因。当然因此也就导致了在仲裁段，CAN总线的长度和标称速率相对有一个限制的原因。

因为TSEG1包含了传播段和PHASE_SEG1的原因。请注意这里的传播段是为了考虑到传播延迟故意引入的。按照我的理解这里的传播段长度其实应当考虑当前节点到总线最远节点的延时然后计算出的TQ。还以2.4中的示例，那么我们假定一个TQ是100ns，那我可能会考虑传播段的长度大概就是9个TQ。

### 2.5.3 鲁棒性和复杂工况
上面提到了传播延迟的问题，但是复杂工况下，传播段的延迟其实可能更复杂。在实际使用中还可能有增加节点的问题。有时候节点的引入可能会改变整个拓扑的形态。线缆和节点的电容也会影响传播速度。

在上面的2.5.2的描述中其实有一个问题没有细说，那就是为什么TSEG1不可以只包含传播段就够了呐？我的理解是我们通过添加PHASE_SEG1段来更加自由的调整采样点位置。比方说250kbps的标称速率下，每一位的长度就是4000ns。理想采样点位置是中间位置。按照2.5.2的示例（假定一个TQ是100ns）那么整个bit的长度是40TQ。理想采样点在20TQ和21TQ的交界处。所以可以设置TSEG1为
19TQ，TSEG2为20TQ。但是第一个跳变发生在SYNC_SEQ整个阶段，也可以认为采样点大概在第21个TQ上是比较好的。所以TSEG1可以设置为20TQ，TESG2设置为19TG。因为传播段其实按照上面的描述是9个TQ，其实PHASE1_SEG就是10TQ。可以看到这里的PHASE1_SEG其实就是用来调整采样点的。因为加入了PHASE1_SEG可以提高整个总线的鲁棒性。当增添阶段或者干扰导致实际的延迟超过传播段也没有关系。

### 2.5.4 采样点思考2
但如果还是上面的例子，但是如果波特率提高到了500Kbps呐？那么整个bit的长度就变成了1000ns
,10个TQ。但是传播段就有9个。那TSEG1到底该设置为多少呐？
![采样点示例2-1](img/采样点示例2-1.png)
<p style="text-align:center; color:orange">图10：采样点示例2-1 </p>

我们该不该将采样点放在上图的位置呐？

![采样点示例2-2](img/采样点示例2-2.png)
<p style="text-align:center; color:orange">图11：采样点示例2-2 </p>
可能我们会需要考虑加入一些时延来提供整个网络的稳定性。比如我们将采样点向后移动三个采样点。

### 2.5.5 采样点思考3
现在我们假定我们的TQ分辨率高了变成了50ns一个TQ，我们的标称速率也提高到了1Mbps.那么一个bit就是1000ns，就是20个TQ。还按照2.4中的示例，最长传播段就是850ns，需要17个TQ。
![采样点示例3](img/采样点示例3.png)
<p style="text-align:center; color:orange">图12：采样点示例3 </p>

真如上图所示，我们假定将采样点放在第19和第20个TQ之间。这样TSEG1就是18个TQ，TSEG2就是1个TQ。那么整个总线的抗干扰无疑是很差的。所以你有没有产生一个疑问：我的举例可能不成立？因为1M速率下，通讯线长不能太长。

### 2.5.6 采样点、速率和通讯距离
这里就要再提到资料2中的某一节（忘记那一节课了）其实提到了通讯距离的问题，当时给出了下面一张PPT：
![通讯距离和速率](img/CAN线长和速率.png)
<p style="text-align:center; color:orange">图13：通讯距离和通讯速率 </p>
图中的round trip delay给出的定义更细。但是不记得有对t_prop,t_iso和t_trans有说明。
但是里面有个通讯距离和传输速率的关系。再1Mbps的通讯距离是40m。如果使用2.4一样的收发器。传播延时最大时750ns，就是15个TQ。

![采样点示例4](img/采样点示例4.png)
<p style="text-align:center; color:orange">图14：采样点示例4 </p>
相对于采样点示例3会好一点。但是可以预测的时此时的通讯状况稳定性会稍差。如果降到20米以下。情况就会大大改善。

综上所述，采样点的设置确实是一个复杂的状况。需要根据自己的网络情况和通讯速率综合考虑。

## 三、STM32是如何配置位定时的
现在我们在经历了一番思维的历练之后，回到最基础的问题上STM32要如何设置位定时。
其实CUBEMX对于FD参数的配置稍微有点混乱，现在不妨按照我的说明来将参数分成3类。

------------------------------------
第一组参数 Bsic Parameters：

|序号| 名称 | 取值范围 | 含义|
|:-:|:---:|:---:|:---:|
|1|Clock Divider|1/2/4/8...30|总时钟分频|
|2|Frmae Format|Classic/FD/FD with BRS|帧格式|
|3|Mode|5种模式|工作模式|
|4|Auto Retransmission|Disable/Enable|是否自动重发|
|5|Transmit Pause|Disable/Enable|是否开启传输暂停机制|
|6|Protocol Exception|Disable/Enable|是否开启协议异常处理|
|7|Std Filters Nbr|0~28|标准消息过滤器数据|
|8|Ext Filters Nbr|0~8|扩展消息过滤器数据|
|9|Tx Fifo Queue Mode|FIFO/QUEUE|发送FIFO模式|

------------------------------------
第二组参数 Nominal Timing Parameters：

|序号| 名称 | 取值范围 | 含义|
|:-:|:---:|:---:|:---:|
|1|Nominal Prescaler|1~512|标称时序时钟分频|
|2|Nominal Time Seg1|2~256|TSEG1(N)|
|3|Nominal Time Seg2|2~128|TSEG2(N)|
|4|Nominal Sync Jump Width|1~128|SJW(N)|


------------------------------------
第三组参数 Data Timing Parameters：

|序号| 名称 | 取值范围 | 含义|
|:-:|:---:|:---:|:---:|
|1|Data Prescaler|1~32|数据时序时钟分频|
|2|Data Time Seg1|1~32|TSEG1(D)|
|3|Data Time Seg2|1~16|TSEG2(D)|
|4|Data Sync Jump Width|1~16|SJW(D)|
------------------------------------

基础参数我们暂时不讨论。这部分需要和CAN的时钟配置结合提供TQ。具体的计算没有什么需要特别强调的部分。

第二组参数和第三组参数分别涉及标称位定时参数和数据位定时参数的配置。我们在前面详细论述过。因为DATA的速率可能更高所以每一位占用的TQ数目可能要低于NOMINAL的参数。这两组的TSEG1的范围但与TSEG2的范围的两倍也可以理解。因为TSEG1包含了传播段和调整段1的参数。SJW的范围和TSEG2的一致。在前面的论述中（ISO11898-1/2015的要求）也有说明。
至此我们就大概讲解完了所有的参数配置相关的内容。

在结束之前，还需要提到一个概念：数据有效负载。就是在整包数据中，要传输的数据段在整个包中所占用的比例。有时候我们听到说CAN-FD比CAN块10倍的说法，可能会不理解。这其实是按照通讯速率和有效负载结合起来得出的一个结果。有兴趣的话你可以算一下。我们可以以CAN常用的250Kbps和CAN FD常用的2Mbps来计算。这个问题在附件2中提到的视频有很好的说明。这里就不再计算。

（全文完）


## 附件

[1. can_fd_spec.pdf](data/attachment/forum/?imageMogr2/auto-orient/strip%7CimageView2/2/w/300 "can_fd_spec.pdf")

[2. CAN FD的视频课程](https://mu.microchip.com/understanding-the-can-fd-protocol-ser3-kr-sc)

3. 文章还参考了ISO11898-1/2015.
4. 文章还参考了ST的AN5348.
5. 瑞萨电子的RCJ05B0027-0100/Rev.1.00。