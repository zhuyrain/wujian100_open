# `fpga` 目录说明

本目录用于将无剑100 SoC 映射到 Xilinx Artix-7 FPGA。主要流程是：Synplify 读取 RTL 并生成 EDIF 网表，Vivado 读取 EDIF、时序约束和板级管脚约束，随后完成布局布线及比特流生成。

## 顶层内容

| 路径 | 作用 |
|---|---|
| `wujian100_open_fpga_top.v` | FPGA 专用 SoC 顶层。负责 MMCM、FPGA 时钟连接和对 ASIC 顶层结构的适配，是 Synplify 工程的综合入口。 |
| `synplify/` | Synplify 综合工程、源时序约束及综合生成物。 |
| `vivado/` | Vivado 建工程、布局布线及生成比特流所需的 Tcl 脚本和工程输出。 |
| `xdc/` | 不同开发板的物理管脚、电气和板级时钟约束。该目录已有独立的 `readme.md`。 |

## `synplify/`

| 路径 | 作用 |
|---|---|
| `wujian100_open_200t_3b.prj` | Synplify 工程配置，指定源文件、宏、器件、综合选项和输出目录。 |
| `wujian100_open.sdc` | 综合阶段的时钟和时序约束源文件。 |
| `FDC_constraints/` | SDC/FDC 转换结果及转换日志。 |
| `wujian100_open_200t_3b_rev/` | 当前综合 revision 的输出目录。关键交付物是 `wujian100_open.edf` 和 `wujian100_open_edif.xdc`。 |
| `stdout*.log`、`stdout_job*.log` | Synplify批处理和作业日志；带 `.bak` 的文件是历史备份。 |
| `synlog.tcl` | Synplify 日志/工程运行过程中生成或使用的 Tcl 文件。 |

`wujian100_open_200t_3b_rev/` 中的 `.srr/.srm/.srd/.srs/.map/.htm`、`rpt_*` 和 `*_cck.rpt` 是综合、面积及时钟检查报告；`synwork/`、`syntmp/`、`dm/`、`coreip/` 等是工具工作目录，不应作为手工维护的源文件。

## `vivado/`

| 路径 | 作用 |
|---|---|
| `wujian100_open_200t_3b_prj.tcl` | 创建 Vivado 工程、加入 EDIF/XDC 并启动实现流程的主脚本。 |
| `project_bx72/` | 针对 BX72 板卡生成的 Vivado 工程及 `.xpr`、缓存、runs 和硬件导出目录。 |
| `vivado.log`、`vivado.jou` | 最近一次 Vivado 会话日志与命令记录。 |
| `.Xil/` | Vivado 临时状态和缓存。可由工具重新生成，不属于设计源文件。 |

## `xdc/`

| 文件 | 作用 |
|---|---|
| `XC7A200T3B.xdc` | 原 XC7A200T 开发板约束。 |
| `XC7A200TBX72.xdc` | BX72 板卡的管脚及配置约束。 |
| `BX72管脚分配表V2.1.xlsx` | BX72 原始管脚分配依据。 |
| `readme.md` | 各约束块与板上物理模块的详细说明。 |

注意区分源文件与生成物：重新运行 Synplify 或 Vivado 时，revision、工程缓存和日志可能被覆盖。
