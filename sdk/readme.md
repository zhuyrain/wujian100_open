# `sdk` 目录说明

本目录是无剑100的软件开发套件，面向 E902 内核和无剑100片上外设，采用 CSI（Common Software Interface）接口组织。它包含板级启动、内核访问接口、外设驱动、RTOS适配、公共库和示例工程。

| 路径 | 作用 |
|---|---|
| `VERSION` | SDK版本标识。 |
| `board/` | 板级支持包。`wujian100_open_evb/` 包含开发板初始化、链接脚本、管脚及测试配置。 |
| `csi_core/` | CSI-Core 接口以及 E902/RISC-V 内核寄存器、异常、中断等访问封装；公共头文件位于 `include/`。 |
| `csi_driver/` | CSI外设驱动接口和实现。`include/` 是统一 API，`wujian100_open/` 是无剑100的 UART、GPIO、Timer、中断、管脚复用等具体实现。 |
| `csi_kernel/` | CSI-Kernel 抽象及 RTOS适配。`include/` 提供统一内核接口，`rhino/` 包含 AliOS Rhino 内核、RISC-V移植和电源管理代码。 |
| `libs/` | 公共运行库，包括精简 libc、动态内存、环形缓冲和 syslog；`libnewlib_wrap.a` 是预编译的 newlib封装库。 |
| `projects/` | 可构建的软件工程。`benchmark/` 包含 CoreMark/Dhrystone，`examples/` 包含驱动、内核和 Hello World 示例，`tests/` 包含核心、驱动和内核测试。 |
| `utilities/` | SDK构建与调试辅助文件：`aft_build.sh` 为构建后处理脚本，`gdb.init` 和 `flash.init` 为调试/下载初始化命令。 |

依赖关系通常为：

```text
projects
  ├── board
  ├── csi_core
  ├── csi_driver
  ├── csi_kernel（使用RTOS时）
  └── libs
```

本目录用于开发运行在 FPGA/SoC 上的软件；`../case` 则主要服务于 RTL 仿真验证，两者用途不同。
