# `soc` 目录说明

本目录包含无剑100 SoC 的可综合 Verilog RTL、仿真模型、参数头文件和编译文件列表。ASIC仿真入口是 `wujian100_open_top.v`；FPGA综合会在其基础上使用 `../fpga/wujian100_open_fpga_top.v` 进行适配。

## 集成与互连

| 文件 | 作用 |
|---|---|
| `wujian100_open_top.v` | ASIC/SoC 总顶层，实例化 CPU、AOU、PDU、RETU 和所有 PAD。 |
| `core_top.v` | E902 CPU 子系统封装，连接 CPU、调试、中断和系统总线。 |
| `E902_20191018.v` | E902 CPU 核 RTL 汇总文件，包含取指、执行、CP0、CLIC、总线和 HAD 调试模块。 |
| `pdu_top.v` | Peripheral Domain Unit 顶层，集成主 AHB 总线、低速子系统、APB0/APB1 外设域和 DMA。 |
| `aou_top.v` | Always-On Unit 顶层，集成 PMU、GPIO、RTC 等常开域逻辑。 |
| `retu_top.v` | RETU/存储子系统封装，连接 SMU/SMS 与主总线。 |
| `smu_top.v` | 片上存储管理单元顶层，封装 SMS。 |
| `sms.v` | 片上 SRAM bank、AHB从接口和存储子系统实现。 |
| `ahb_matrix_top.v` | 主 AHB 矩阵顶层封装。 |
| `matrix.v` | 主/子 AHB 矩阵、仲裁、译码及跨时钟 FIFO 实现。 |
| `ls_sub_top.v` | Low-Speed 子系统顶层，连接低速 AHB从设备及占位从设备。 |
| `apb0_sub_top.v`、`apb1_sub_top.v` | 两个 APB 外设子系统的集成顶层。 |
| `apb0.v`、`apb1.v` | APB状态控制和叶级从设备数据选择逻辑。 |
| `dummy.v` | 未实现或保留地址窗口使用的 APB/AHB dummy 从设备。 |

## 时钟、复位与通用单元

| 文件 | 作用 |
|---|---|
| `clkgen.v` | PMU/SoC时钟、复位和各外设时钟连接逻辑。 |
| `common.v` | 公共时钟 MUX 和门控时钟单元；包含 ASIC 与 `FPGA` 宏下的不同实现。 |

## 外设 RTL

| 文件 | 作用 |
|---|---|
| `dmac.v` | 多通道 DMA 控制器、仲裁、通道寄存器和状态机。 |
| `gpio0.v` | GPIO控制、APB寄存器接口和安全封装。 |
| `pwm.v` | 多通道 PWM 的 APB接口、控制、分频和波形生成逻辑。 |
| `rtc.v` | RTC的常开/外设域接口、时钟分频、计数、同步和中断逻辑。 |
| `tim.v` | 通用定时器公共实现及 Timer0 安全封装。 |
| `tim1.v`～`tim7.v` | Timer1～Timer7 的实例封装，将公共定时器逻辑接入不同 APB位置。 |
| `usi0.v` | USI公共实现，包含 UART、SPI、I²C主从、FIFO和APB接口，并提供USI0封装。 |
| `usi1.v` | USI1和USI2的实例封装。 |
| `wdt.v` | 看门狗总线接口、计数器、寄存器、中断/复位及安全封装。 |

## 参数与仿真模型

| 路径 | 作用 |
|---|---|
| `params/apb0_params.v` | APB0地址、选择和接口参数。 |
| `params/apb1_params.v` | APB1地址、选择和接口参数。 |
| `params/timers_params.v` | 通用定时器参数。 |
| `params/wdt_params.v` | 看门狗参数。 |
| `sim_lib/PAD_DIG_IO.v` | 数字 PAD 行为模型。 |
| `sim_lib/PAD_OSC_IO.v` | 高/低速晶振 PAD 行为模型。 |
| `sim_lib/STD_CELL.v` | ASIC标准单元的仿真替代模型。 |
| `sim_lib/fpga_spram.v` | FPGA单端口 SRAM 模型/封装。 |
| `sim_lib/fpga_byte_spram.v` | 支持字节写使能的 FPGA SRAM 模型/封装。 |

## 文件列表

| 文件 | 作用 |
|---|---|
| `wujian100_open_syn.filelist` | 从 `soc` 目录运行工具时使用的可综合 RTL列表。 |
| `wujian100_open_syn_for_iverilog.filelist` | 从工程其他目录运行 Icarus Verilog 时使用的相对路径 RTL列表。 |
| `wujian100_open_lib.filelist` | 仿真库模型列表。 |
| `wujian100_open_lib_for_iverilog.filelist` | Icarus Verilog 使用的相对路径仿真库列表。 |

修改 RTL 时应同步确认 Synplify工程和上述 filelist 是否仍包含正确文件；`params` 和 `sim_lib` 虽不一定综合为实际逻辑，但会直接影响地址译码和仿真行为。
