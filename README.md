# 异步FIFO
### 代码介绍
位宽和深度可定制的异步FIFO

### 工程结构

- Async_FIFO.sv   

### 日志

* v1.0：首次更新 `2019.11.05`
    * 位宽和深度可定制的异步FIFO。

* v2.0：添加功能及规范化 `2021.08.07`
   * 规范接口；
   * 添加读写计数和almost空满标志位。

* v2.1：添加信号 `2021.08.07`
   * 添加写应答和有效信号。
 
* v2.2: 函数替换 `2021.10.18`
   * 使用SystemVerilog中的求对数系统函数代替自建函数。

* v3.0: 读写位宽不同设计 `2022.01.04`
   * 允许读写位宽不同；
   * 读数据位宽必须为写数据位宽的1/1、1/2、1/4、1/8等等；
   * 原本读模式为FWFT，现更新标准读模式，并可根据define设置两种模式。

* v3.1: 修改输出顺序 `2022.01.12`
   * 读写位宽不一致时，修改成高位先出。

### Wavaform：

* Standard read mode:
![wave](https://raw.githubusercontent.com/Verdvana/Async_FIFO/v3.1/simulation/data/standard.jpg)

* FWFT read mode:
![wave](https://raw.githubusercontent.com/Verdvana/Async_FIFO/v3.1/simulation/data/FWFT.jpg)
