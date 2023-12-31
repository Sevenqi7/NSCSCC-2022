2022龙芯杯个人赛三等奖作品
---------------

A classic 5 stages MIPS32-Based CPU designed for NSCSCC2022 (The Loongson Cup). The repo contains all the vivado 2019.2 project, and the HDL source code is in thinpad_top.srcs/sources_1/new.

本仓库于2023年6月建立，欢迎各位参加龙芯杯～。工程包含Vivado 2019.2工程文件以及HDL源码，但不包含龙芯杯个人赛各个测试的二进制文件。  

（一）设计思路

​	总体设计思路参照教材上的经典五级流水线设计，包括控制信号的命名，旁路的设计，需要阻塞的情形均有受其影响。最高频率为65MHz。总体数据通路如下：

![Datapath](./images/1)

注：本图中部分多选器的控制信号、SRAM的控制信号、串口以及阻塞的控制模块未画出。

采用的是经典的MIPS五级流水线结构，分支的判断提前至了ID级，由于龙芯杯个人赛要求实现延迟槽，在不出现数据相关时可以单周期内完成跳转。若数据相关时则根据具体情况，可能需要在ID级阻塞1至2个周期。阻塞逻辑和前递效率并不是很高，应该有可以优化的地方。

（二）各测试通过结果截图

![image-20230612131616396](./images/2)

![image-20230612131623100](./images/3)

![](./images/4)

（三）参考资料

[1] 汪文祥,邢金璋.CPU设计实战[M].北京：机械工业出版社，2021-1.

[2] 戴维A.帕特森 约翰L.亨尼斯.计算机组成与设计：硬件/软件接口[M].康继昌，王党辉，安建峰 译.北京：机械工业出版社，2015-7.
