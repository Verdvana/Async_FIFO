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
   * 使用SystemVerilog中的求对数系统函数代替自建函数

### Wavaform：
![wave](https://raw.githubusercontent.com/Verdvana/Async_FIFO/master/simulation/data/wave.png)
