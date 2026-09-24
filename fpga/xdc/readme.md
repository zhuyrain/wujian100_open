# XC7A200T3B.xdc 约束说明

本文说明 [`XC7A200T3B.xdc`](./XC7A200T3B.xdc) 中各约束块对应的板级物理资源、信号用途，以及部分约束被注释的原因。

该文件面向 FMX7AR3B 板卡及 Xilinx Artix-7 `XC7A200T-FBG484`。它与 FPGA 顶层 [`wujian100_open_fpga_top.v`](../wujian100_open_fpga_top.v) 配合使用。

## 1. XDC 与顶层 RTL 的关系

`PACKAGE_PIN` 约束只负责把一个已经存在的顶层端口绑定到 FPGA 封装管脚。例如：

```tcl
set_property PACKAGE_PIN B17 [get_ports PIN_EHS]
```

表示将顶层端口 `PIN_EHS` 放到 FPGA 的 B17 管脚。XDC 不会创建端口，也不会自动实例化 GPIO、存储器控制器或串口模块。

当前 FPGA 顶层共导出了 62 个板级端口，原 XDC 对这 62 个端口均有有效管脚约束：

| 类别 | 数量 | 顶层端口 |
| --- | ---: | --- |
| 主时钟 | 1 | `PIN_EHS` |
| 复位 | 1 | `PAD_MCURST` |
| C-SKY JTAG | 2 | `PAD_JTAG_TCLK`、`PAD_JTAG_TMS` |
| GPIO | 32 | `PAD_GPIO_0`～`PAD_GPIO_31` |
| PWM | 13 | `PAD_PWM_CH0`～`PAD_PWM_CH11`、`PAD_PWM_FAULT` |
| USI | 12 | 三组 `PAD_USI*_NSS/SCLK/SD0/SD1` |
| 时钟输出 | 1 | `POUT_EHS` |

被注释的约束多数属于板卡约束模板中的可选资源，但当前 FPGA 顶层没有相应端口。若直接取消注释，`get_ports` 将找不到对象，Vivado 会报告类似 `No ports matched` 的警告或错误；如果误把不同功能绑定到同一管脚，还会引起管脚冲突。

## 2. I/O 电平标准

```tcl
set_property IOSTANDARD LVCMOS33 [get_ports]
```

这条约束把当前设计的所有顶层端口统一设置为 3.3 V LVCMOS。它只设置 I/O 标准，没有设置驱动强度、压摆率、上下拉或输入终端。

使用时必须确认相关 I/O Bank 的 `VCCO` 确实为 3.3 V。若板卡或外设使用其他电压，应按 Bank 和端口分别设置，不能继续使用全局 `LVCMOS33`。

## 3. 时钟约束

### 3.1 `PIN_EHS`

```tcl
set_property PACKAGE_PIN B17 [get_ports PIN_EHS]  ;# 20 MHz
```

`PIN_EHS` 是 Wujian100 的高速外部时钟输入，在原板上连接 B17 管脚的 20 MHz 时钟源。该时钟进入 `PAD_OSC_IO`，形成 SoC 的 `ehs_pmu_clk`，供系统时钟和电源管理相关逻辑使用。

原 XDC 中下面的时序约束被注释：

```tcl
#create_clock -period 50.00 -name MAIN_CLK [get_ports PIN_EHS]
```

`50 ns` 周期对应 20 MHz。它保持注释不是因为 `PIN_EHS` 不使用，而是因为原工程已经在 [`wujian100_open.sdc`](../synplify/wujian100_open.sdc) 中定义了同一时钟：

```tcl
define_clock {n:PIN_EHS} -name PIN_EHS -freq 20 -clockgroup clkgroup_2
```

原流程先由 Synplify 综合并将 SDC 转换成实现约束，再由 Vivado Tcl 工程同时载入 Synplify 生成的 `wujian100_open_edif.xdc` 和板级 XDC。因此不应在多个文件中重复创建同一个主时钟。

如果改为 Vivado 直接综合 RTL，或者不再导入 Synplify 生成的时序约束，就需要在 Vivado 使用的 XDC 中恢复等效的 `create_clock`，并按实际板载时钟修改周期。

### 3.2 `OSC_CLK_48M`

```tcl
#set_property PACKAGE_PIN E19 [get_ports OSC_CLK_48M]  ;# 48 MHz
```

E19 是原板可用的另一时钟资源，占位名称为 `OSC_CLK_48M`。当前 FPGA 顶层没有 `OSC_CLK_48M` 端口，系统也未使用该时钟，因此保持注释。

## 4. 复位源

```tcl
set_property PACKAGE_PIN W11 [get_ports PAD_MCURST]  ;# K1
```

W11 连接板载按键 K1，作为 Wujian100 的 MCU 复位输入。端口进入设计后连接到内部低有效信号 `pad_mcurst_b`，用于产生系统复位。

由于机械按键会产生抖动，是否需要消抖取决于板级复位电路和 RTL；XDC 本身不提供消抖功能。

## 5. C-SKY JTAG 调试接口 J8

```tcl
set_property PACKAGE_PIN AA15 [get_ports PAD_JTAG_TCLK]
set_property PACKAGE_PIN P14  [get_ports PAD_JTAG_TMS]
```

这两条约束连接原板 J8 调试接口：

| 信号 | 作用 |
| --- | --- |
| `PAD_JTAG_TCLK` | 调试时钟输入 |
| `PAD_JTAG_TMS` | 双向调试控制/数据信号 |

当前 Wujian100 FPGA 顶层采用这两个信号完成处理器调试，所以传统四线 JTAG 中的 `TDI`、`TDO`、`TRST`、`NRST` 等模板管脚均被注释；这些名称也没有出现在当前顶层端口中。

```tcl
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets PAD_JTAG_TCLK_c]
```

这条约束允许 `PAD_JTAG_TCLK_c` 使用非专用时钟布线。其用途是放宽 Vivado 对调试时钟管脚和专用时钟网络之间连接的检查，使当前板级接法能够完成布局布线。

该属性会降低时钟布线检查的严格程度，不应无条件复制到系统主时钟。更换管脚或修改 JTAG 逻辑后，应重新检查该例外是否仍有必要。

## 6. 外部 NOR Flash 与 PSRAM

该约束块描述原板上的两类并行存储器：

| 物理器件 | 数量 | 主要用途 |
| --- | ---: | --- |
| S29GL128S NOR Flash | 2 | 非易失代码、固件或数据存储 |
| EM7644SU16ASZP PSRAM | 2 | 运行时易失数据存储 |

两片器件组合形成较宽的数据通路，并共用或配合使用以下总线信号：

| 信号组 | 作用 |
| --- | --- |
| `mmc_addr[22:0]` | 地址总线 |
| `mmc_data[31:0]` | 32 位双向数据总线 |
| `mmc_bsel_b[3:0]` | 低有效字节选通 |
| `mmc_flash_cs_b` | NOR Flash 片选 |
| `mmc_sram_cs_b` | PSRAM 片选 |
| `mmc_oe_b`、`mmc_we_b` | 低有效读、写控制 |
| `mmc_flash_wp_b` | Flash 写保护 |
| `mmc_flash_rst_b` | Flash 复位 |
| `mmc_sram_zz_b` | PSRAM 低功耗/休眠控制 |

### 为什么整个 Memory 块被注释

这里的注释不代表原板一定没有这些存储芯片，而是当前 Wujian100 FPGA 实现没有把外部存储器控制器总线导出到顶层：

- `wujian100_open_fpga_top.v` 中不存在任何 `mmc_*` 顶层端口；
- 当前内部存储路径在 `soc/sms.v` 中实例化 `fpga_spram`，由 FPGA 片内存储资源实现；
- 因而当前比特流不会驱动板载 NOR Flash 或 PSRAM 的并行总线；
- 若取消注释，Vivado 无法为这些名称找到顶层端口。

若后续需要使用板载 NOR Flash 或 PSRAM，不能只取消 XDC 注释。还需要加入或恢复外部存储控制器、在顶层导出完整的 `mmc_*` 总线、确认总线时序及 I/O 电压，然后再启用对应管脚和读写时序约束。

## 7. YOC SOCKET 1

该插座连接 Wujian100 GPIO 的前 19 路：

```text
PAD_GPIO_0 ～ PAD_GPIO_18
```

这些端口均为双向数字 I/O，可由 SoC 的 GPIO 控制器配置为输入或输出，用于连接传感器、按键、LED、扩展模块等。该块中的 19 条约束全部启用。

## 8. YOC SOCKET 2

该插座继续连接 GPIO：

```text
PAD_GPIO_19 ～ PAD_GPIO_31
```

前 13 个插座位置分配给当前设计剩余的 13 路 GPIO。其后 V20、U21、W21、Y22、W22、Y21 六个管脚没有对应的 Wujian100 顶层端口，所以只是被注释的板卡管脚占位符。

## 9. YOC SOCKET 3

该插座承载 PWM 模块信号：

| 信号 | 作用 |
| --- | --- |
| `PAD_PWM_CH0`～`PAD_PWM_CH11` | 12 路 PWM 通道，可用于脉冲、调光、电机或定时波形输出 |
| `PAD_PWM_FAULT` | PWM 故障输入，用于外部异常或保护条件 |

上述 13 条约束均启用。M16、M22、L13、M20、L14、L20 六个插座位置没有分配顶层端口，因此保持注释。

## 10. YOC SOCKET 4

该插座承载三组 USI（Universal Serial Interface）信号：

```text
PAD_USI0_NSS/SCLK/SD0/SD1
PAD_USI1_NSS/SCLK/SD0/SD1
PAD_USI2_NSS/SCLK/SD0/SD1
```

每组包含四个可复用串行信号。Wujian100 软件和控制器可按配置将 USI 用作 USART、SPI 或 I²C 等串行协议接口；各信号在不同模式下的方向和含义会变化。

12 个 USI 顶层端口均已约束。J16、K21、J15、J22、J19、J17、J21 七个剩余插座位置没有对应端口，因此保持注释。

## 11. YOC SOCKET 5～8

这些块主要保留原板插座的可用 FPGA 管脚，但当前 FPGA 顶层没有为它们导出信号，所以整体或大部分被注释。

### SOCKET 5

H14 曾预留给 `PIN_ELS`，即低速外部时钟输入。完整 SoC 顶层中存在 ELS 振荡器接口，但 FPGA 专用顶层删除了 `PIN_ELS/POUT_ELS`，并使用：

```verilog
assign els_pmu_clk = ehs_pmu_clk;
```

因此 FPGA 版本直接以高速时钟路径代替独立低速时钟输入，`PIN_ELS` 约束不能启用。其余位置没有信号名称，仅为插座管脚占位。

### SOCKET 6

所有条目都没有 `get_ports` 名称，只列出了 FPGA 管脚，表示这些插座位置没有分配给当前设计。

### SOCKET 7 和 SOCKET 8

模板中使用了 `gpio7_port[*]` 和 `gpio8_port[*]` 这两组旧式或可选向量端口名。当前顶层只存在标量 `PAD_GPIO_0`～`PAD_GPIO_31`，不存在 `gpio7_port` 或 `gpio8_port`，因此这些约束不能直接启用。

如果以后希望利用这些插座，应先在顶层增加新的端口，再根据实际功能建立新的明确映射，不应直接取消模板注释并假定端口已经存在。

## 12. UART

该块只列出 N3、N4、N5、M2、M5、M6 六个可用管脚，`get_ports` 内没有填写任何端口名，因此属于未完成的板级占位约束。

当前设计没有独立命名的 UART 顶层端口。UART 功能可通过已导出的 USI 接口实现，所以此块保持注释。

## 13. SE 安全器件接口

该块预留安全器件（Secure Element，SE）的数据、时钟和复位连接：

```text
SE_DATA
SE_CLK
SE_RST
```

模板尝试使用 `gpio0_port[18]`、`gpio0_port[16]` 和 `gpio0_port[17]`，但这些向量端口不存在于当前 FPGA 顶层，实际顶层端口名称也没有直接对应关系，所以全部保持注释。

## 14. 用户按键

该块对应板载用户按键 K3～K6。它们原本可作为 GPIO 输入：

- K3 没有填写端口名；
- K4～K6 使用不存在的 `gpio0_port[*]` 端口名；
- K1 已在前面的复位块中连接到 `PAD_MCURST`。

因此 K3～K6 的约束保持注释。若要将其作为软件可读按键，应明确选择 `PAD_GPIO_n`，同时避免与 YOC 插座上的既有管脚分配冲突。

## 15. 八位拨码开关

该块对应板载 8 位拨码开关，可作为八路 GPIO 输入。前五条没有端口名，后三条使用当前顶层不存在的 `gpio0_port[10:12]`，所以全部保持注释。

启用前需要决定拨码开关应连接到哪些现有或新增 GPIO 端口，并检查这些 GPIO 是否已经分配到其他插座。

## 16. RGB LED

```tcl
set_property PACKAGE_PIN P4 [get_ports POUT_EHS]
#set_property PACKAGE_PIN P5 [get_ports POUT_ELS]
```

P4、P5 等管脚连接板载 RGB LED 的不同颜色通道。当前仅 `POUT_EHS` 存在于 FPGA 顶层，因此 P4 约束启用。

`POUT_EHS` 是 `PAD_OSC_IO` 的高速振荡器输出，不是普通软件控制 GPIO；在当前 FPGA 仿真模型中它跟随启用后的 `PIN_EHS`。将其连接到 LED 主要用于板级观测或保留原芯片振荡器接口映射。

`POUT_ELS` 不存在于 FPGA 专用顶层，第三个 LED 通道也没有端口名，因此两条约束保持注释。

## 17. FPGA 配置属性

最后一组约束不对应普通用户 I/O，而是控制 FPGA 配置电气条件和生成的配置比特流：

| 属性 | 作用 |
| --- | --- |
| `CONFIG_VOLTAGE 3.3` | 声明配置接口使用 3.3 V |
| `CFGBVS VCCO` | 配置 Bank 电压选择参考 VCCO |
| `CONFIG_MODE SPIx4` | 指定四线 SPI 配置模式 |
| `BITSTREAM.CONFIG.SPI_BUSWIDTH 4` | 生成支持 x4 数据宽度的 SPI 配置比特流 |
| `BITSTREAM.CONFIG.CONFIGRATE 40` | 设置主模式配置时钟速率参数为 40 MHz |
| `BITSTREAM.CONFIG.EXTMASTERCCLK_EN DIV-2` | 设置外部 Master CCLK 相关的分频选项 |

这些属性必须与板卡的配置模式拨码/电阻、配置 Flash 接法和 Bank 电压一致。它们与前面的外部 NOR Flash/PSRAM 数据存储接口不是同一组资源：配置 Flash 用于 FPGA 上电加载比特流，而 Memory 块中的 NOR Flash/PSRAM 是设计运行后由用户逻辑访问的外部存储器。

## 18. 注释约束的判断原则

原文件中的注释大致分为四类：

1. **当前设计不使用的物理模块**：例如外部 NOR Flash、PSRAM、SE 和部分按键/拨码开关。
2. **RTL 顶层没有对应端口**：例如全部 `mmc_*`、`PIN_ELS`、`POUT_ELS`、`gpio7_port` 和 `gpio8_port`。
3. **只有管脚、没有信号名的模板占位项**：例如部分 YOC 插座和 UART 管脚。
4. **约束已在其他阶段提供**：例如主时钟的 20 MHz 时序定义已经存在于 Synplify SDC 中。

取消任何注释前，至少应确认：

- `get_ports` 中的名称与当前综合顶层完全一致；
- 该 FPGA 管脚没有被其他端口占用；
- 所在 I/O Bank 的电压与 `IOSTANDARD` 匹配；
- 输入、输出或双向方向与板上器件一致；
- 时钟、异步输入和外部总线具有必要的时序约束；
- 板上同一物理管脚没有同时连接到会产生电气冲突的器件。

只取消 XDC 注释并不会让某个外设自动工作；RTL 控制器、顶层端口、管脚约束、时序约束和软件驱动必须相互匹配。
