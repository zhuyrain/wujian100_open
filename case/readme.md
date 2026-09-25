# `case` 目录说明

本目录保存 SoC RTL 仿真的软件测试用例。通常由 `../tools/run_case` 选择一个 `.c` 文件，将其复制到 `../workdir`，使用 RISC-V 裸机工具链生成 ELF、反汇编和存储器初始化文件，再与 RTL testbench 一起运行。

部分用例同时带有同名 `.v` 文件：`.c` 是运行在 E902 上的软件，`.v` 是 testbench 侧的外部激励、连线或协议模型。只有 `.c` 的目录主要依靠软件访问片上寄存器完成验证。

| 目录 | 文件 | 作用 |
|---|---|---|
| `addr_map/` | `map_test.c`、`map_test.v` | 验证 SoC 地址映射及不同总线目标的访问响应。 |
| `dma/` | `dma_test.c` | 验证 DMA 控制器的配置、搬运和完成状态。 |
| `gpio/` | `gpio_test.c`、`gpio_test.v` | 验证 GPIO 输入、输出及 testbench 侧管脚激励。 |
| `had_soc/` | `e902_had_test.c`、`e902_had_test.v` | 验证 E902 HAD/JTAG 硬件调试接口及相关 SoC 交互。 |
| `pwm/` | `pwm_test.c`、`pwm_test.v` | 验证 PWM 配置、通道输出、分频/周期及外部波形检查。 |
| `rtc/` | `rtc_test.c` | 验证 RTC 寄存器、计数、匹配和中断功能。 |
| `timer/` | `timer_test.c` | 验证通用定时器装载、计数和中断。 |
| `usi_i2c/` | `usi_i2c_test.c`、`usi_i2c_test.v` | 验证 USI 工作在 I²C 模式时的软件配置和总线交互。 |
| `usi_spi/` | `usi_spi_test.c`、`usi_spi_test.v` | 验证 USI 工作在 SPI 模式时的主从传输。 |
| `usi_uart/` | `usi_uart_test.c`、`usi_uart_test.v` | 验证 USI 工作在 UART 模式时的收发。 |
| `wdt/` | `wdt_test.c` | 验证看门狗计数、喂狗、超时和复位/中断行为。 |

典型调用方式：

```bash
cd ../workdir
../tools/run_case -sim_tool iverilog ../case/timer/timer_test.c
```

`run_case` 会清空并重建 `workdir`，仿真结果会同步到 `../regress/regress_result/`。
