# `tb` 目录说明

本目录是无剑100 RTL 仿真的顶层 testbench 和监控模块。

| 文件 | 作用 |
|---|---|
| `tb.v` | 仿真顶层 `wujian100_open_tb`。产生高速/低速晶振和复位，实例化 SoC，连接外设管脚模型，加载测试程序并控制波形输出和仿真超时。 |
| `busmnt.v` | 总线/CPU执行监控器，观察提交或总线活动，辅助判断测试结束、异常及 PASS/FAIL。可通过 `run_case --nomnt` 关闭相关监控。 |
| `virtual_counter.v` | 仿真虚拟计数器和性能统计逻辑，用于周期、指令或总线事件计数。 |
| `tb_file.list` | 完整仿真文件列表，按顺序包含参数、SoC RTL、PAD/存储模型及本目录 testbench。路径依赖环境变量 `wujian100_open_PATH`。 |

`tools/run_case` 默认直接引用这些文件；修改模块层级或顶层实例名时，需要同步检查 `busmnt.v` 和 `virtual_counter.v` 中的层次宏。
