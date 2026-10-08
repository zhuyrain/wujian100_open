# `wujian100_open_top` SoC 结构说明

本文在 [`readme.md`](./readme.md) 的文件级说明基础上，进一步按照当前 RTL 的**实例层次、总线连接、地址译码、时钟复位、中断和 PAD 连接**整理 SoC 结构。分析对象是 ASIC/仿真顶层 [`wujian100_open_top.v`](./wujian100_open_top.v)，不是 FPGA 适配顶层。

需要先区分两个概念：

- “某模块写在哪个 `.v` 文件中”是源码组织关系；
- “某实例位于哪个父实例下”才是综合后的硬件层次关系。

例如 `usi_top` 的通用实现写在 `usi0.v` 中，但 USI0、USI1、USI2 分别经各自的 `usiN_sec_top` 封装接入 APB0 或 APB1，并不表示它们都从属于 USI0 实例。

## 1. 总体结论

当前 SoC 可以概括为四个顶层功能块：

| 顶层实例       | 模块         | 主要职责                                                              |
| -------------- | ------------ | --------------------------------------------------------------------- |
| `x_cpu_top`  | `core_top` | 封装 E902 CPU、三路 CPU AHB 主接口、CLIC/WIC 中断入口和 JTAG 调试接口 |
| `x_pdu_top`  | `pdu_top`  | 主 AHB 矩阵、DMA、低速 AHB 子总线、APB0/APB1 桥及绝大多数外设         |
| `x_retu_top` | `retu_top` | 片上 SRAM 存储子系统，包含 4 个 64 KiB bank                           |
| `x_aou_top`  | `aou_top`  | PMU/时钟复位、GPIO、RTC；其中 GPIO、RTC、PMU 寄存器通过 APB1 访问     |

这四个实例由顶层直接例化；数字 PAD 和振荡器 PAD 也在顶层直接例化。

## 2. SoC 总体框图

图中 `---->` 表示主要请求、控制或时钟传播方向；AHB/APB 的读数据和响应实际沿反方向返回，为避免图过密不逐根画出。

```text
 PIN_EHS      PIN_ELS      PAD_MCURST       PAD_JTAG_TCLK/TMS
    |            |              |                    |
    +------------+--------------+                    |
                 |                                   |
                 v                                   v
      +----------------------+             +----------------------+
      | AOU: x_aou_top       |             | CPU: x_cpu_top       |
      |                      |             |                      |
      | pmu_dummy_top        |--clk/rst--->| E902_20191018        |
      | GPIO0                |             | CLIC/WIC + HAD/JTAG  |
      | RTC                  |             +----------+-----------+
      +----------+-----------+                        |
                 ^                                    | M0: IAHBL
                 | APB1 S5/S6/S15                     | M1: DAHBL
                 |                                    | M2: BIU
                 |                                    v
                 |                         +------------------------+
                 +-------------------------| PDU: x_pdu_top         |
                                           |                        |
                                           | +--------------------+ |
                                           | | Main AHB 7x12      | |
                                           | | CPU M0/M1/M2       | |
                                           | | DMA M3             | |
                                           | +--+----+----+----+--+ |
                                           |    |    |    |    |    |
                                           |    |    |    |    +------> DMA registers
                                           |    |    |    |
                                           |    |    |    +-----------> Low-speed AHB
                                           |    |    |                   |
                                           |    |    |                   +--> APB0 bridge
                                           |    |    |                   |    +--> TIM0/2/4/6
                                           |    |    |                   |    +--> USI0/USI2
                                           |    |    |                   |    +--> WDT/PWM
                                           |    |    |                   |
                                           |    |    |                   +--> APB1 bridge
                                           |    |    |                        +--> TIM1/3/5/7
                                           |    |    |                        +--> USI1
                                           |    |    |                        +--> AOU GPIO/RTC/PMU
                                           |                        |
                                           | S0/S2/S3/S4            |
                                           +------------------------+----> +----------------------+
                                                                          | RETU: x_retu_top     |
                                                                          | SMU -> SMS           |
                                                                          | S0 -> ISRAM 64 KiB   |
                                                                          | S2 -> SRAM0 64 KiB   |
                                                                          | S3 -> SRAM1 64 KiB   |
                                                                          | S4 -> SRAM2 64 KiB   |
                                                                          +----------------------+

 外设 I/O 路径：

 AOU/GPIO ---------------------------> PAD_GPIO[31:0]
 PDU/PWM  ---------------------------> PAD_PWM_CH[11:0], PAD_PWM_FAULT
 PDU/USI0,1,2 -----------------------> PAD_USI{0,1,2}_{SCLK,SD0,SD1,NSS}
 CPU/HAD ----------------------------> PAD_JTAG_TCLK, PAD_JTAG_TMS
```

这里最重要的结构关系是：

1. CPU 并不直接连接 SRAM 或 APB 外设，而是先进入 PDU 内的主 AHB 矩阵。
2. RETU 是主 AHB 矩阵后面的存储从设备域。
3. APB0/APB1 并非直接挂在主 AHB 矩阵上，而是经过 `S10 -> Low-speed AHB -> S2/S3 -> AHB-to-APB` 两级译码。
4. GPIO、RTC、PMU 的 APB1 译码在 PDU 中，但外设实体位于 AOU；因此 AOU 与 PDU 之间存在 APB1 选择、请求和读数据连线。

## 3. 顶层实例层次

当前主要层次可简化为：

```text
wujian100_open_top
|
+--> x_cpu_top : core_top
|    +--> CPU : E902_20191018
|
+--> x_pdu_top : pdu_top
|    +--> x_main_bus_top : ahb_matrix_top
|    |    +--> ahb_matrix_7_12_main
|    |    +--> x_dmac_top : dmac_top
|    |    +--> AHB dummy master/slave instances
|    |
|    +--> x_sub_ls_top : ls_sub_top
|    |    +--> ahb_matrix_1_6_sub
|    |
|    +--> x_sub_apb0_top : apb0_sub_top
|    |    +--> csky_apb0_top
|    |    +--> TIM0, TIM2, TIM4, TIM6
|    |    +--> USI0, USI2, WDT, PWM
|    |    +--> APB dummy slaves
|    |
|    +--> x_sub_apb1_top : apb1_sub_top
|         +--> csky_apb1_top
|         +--> TIM1, TIM3, TIM5, TIM7
|         +--> USI1
|         +--> APB dummy slaves
|
+--> x_retu_top : retu_top
|    +--> x_smu_top : smu_top
|         +--> x_sms_top : sms_top
|              +--> x_isram_top : sms_bank_64k_top
|              +--> x_sms0_top  : sms_bank_64k_top
|              +--> x_sms1_top  : sms_bank_64k_top
|              +--> x_sms2_top  : sms_bank_64k_top
|
+--> x_aou_top : aou_top
|    +--> x_pmu_top      : pmu_dummy_top
|    +--> x_gpio_sec_top : gpio0_sec_top
|    +--> x_rtc_sec_top  : rtc0_sec_top
|
+--> PAD_OSC_IO x 2
+--> PAD_DIG_IO: reset, JTAG, GPIO, PWM and USI pads
```

顶层四个功能块的直接实例位置见 `wujian100_open_top.v` 中的 `x_aou_top`、`x_pdu_top`、`x_cpu_top` 和 `x_retu_top`。PDU 中的主矩阵、低速矩阵、APB0、APB1 是并列子实例，而不是彼此在源码上的包含关系。

## 4. CPU 与主 AHB 矩阵

`core_top` 把 E902 的三个总线出口映射到主矩阵：

| 主矩阵端口 | E902 侧接口        | 含义                            |
| ---------- | ------------------ | ------------------------------- |
| M0         | `iahbl_*`        | Instruction AHB-Lite，取指通道  |
| M1         | `dahbl_*`        | Data AHB-Lite，数据访存通道     |
| M2         | `biu_*`          | Bus Interface Unit 系统总线通道 |
| M3         | DMA 的`m_*`      | DMA 作为总线主设备搬运数据      |
| M4～M6     | `ahbm_dummy_top` | 当前设计中的保留/占位主设备     |

所以 `ahb_matrix_7_12_main` 的“7 个主端口”是矩阵容量，不等于当前有 7 个真实总线发起者。当前有效的是 CPU 三口加 DMA，共 4 个。

DMA 同时具有两种身份：

- 作为主设备 M3，它能主动读写 SRAM 或其他存储映射目标；
- 作为从设备 S6，CPU 能访问它的配置寄存器。

## 5. 主 AHB 地址空间

主矩阵的 12 个从端口由 `matrix.v` 直接进行地址比较。当前连接如下：

| AHB 从端口 |                           地址范围 | 当前连接                       |
| ---------- | ---------------------------------: | ------------------------------ |
| S0         | `0x0000_0000` ～ `0x0000_FFFF` | RETU 的`x_isram_top`，64 KiB |
| S1         | `0x1000_0000` ～ `0x1007_FFFF` | instruction-memory dummy       |
| S2         | `0x2000_0000` ～ `0x2000_FFFF` | RETU 的`x_sms0_top`，64 KiB  |
| S3         | `0x2001_0000` ～ `0x2001_FFFF` | RETU 的`x_sms1_top`，64 KiB  |
| S4         | `0x2002_0000` ～ `0x2002_FFFF` | RETU 的`x_sms2_top`，64 KiB  |
| S5         | `0x3000_0000` ～ `0x3FFF_FFFF` | data-memory dummy              |
| S6         | `0x4000_0000` ～ `0x4000_3FFF` | DMA 配置从接口                 |
| S7         | `0x4001_0000` ～ `0x4001_FFFF` | AHB dummy                      |
| S8         | `0x4002_0000` ～ `0x4002_FFFF` | AHB dummy                      |
| S9         | `0x4010_0000` ～ `0x401F_FFFF` | AHB dummy                      |
| S10        | `0x4020_0000` ～ `0x7FFF_FFFF` | Low-speed AHB 子系统           |
| S11        | `0x8000_0000` ～ `0x9FFF_FFFF` | AHB dummy                      |

四个 SRAM bank 都例化自 `sms_bank_64k_top`，合计物理容量为 256 KiB；它们不是一个连续的 256 KiB 区间：ISRAM 位于 `0x0000_0000`，另外三个 bank 连续位于 `0x2000_0000`～`0x2002_FFFF`。

## 6. Low-speed AHB 二级译码

主矩阵 S10 覆盖一个较大的低速地址窗口，进入 `ahb_matrix_1_6_sub` 后再次译码：

```text
Main AHB S10
    |
    +----> LS S0  0x4020_0000 - 0x4020_0FFF ----> dummy
    +----> LS S1  0x4030_0000 - 0x403F_FFFF ----> dummy
    +----> LS S2  0x5000_0000 - 0x5004_FFFF ----> APB0 bridge
    +----> LS S3  0x6000_0000 - 0x6004_FFFF ----> APB1 bridge
    +----> LS S4  0x7000_0000 - 0x77FF_FFFF ----> dummy
    +----> LS S5  0x7800_0000 - 0x7FFF_FFFF ----> dummy
```

这个层次说明 CPU 访问一个 USI 寄存器时，完整路径不是“CPU 直接到 USI”，而是：

```text
CPU ----> Main AHB ----> Low-speed AHB ----> AHB-to-APB bridge
    ----> APB slot decoder ----> usiN_sec_top ----> usi_top registers
```

## 7. APB0 与 APB1 外设分布

### 7.1 APB0

APB0 中已实现的外设为：

| APB0 槽位 |                           地址范围 | 外设实例 |
| --------- | ---------------------------------: | -------- |
| S0        | `0x5000_0000` ～ `0x5000_03FF` | Timer0   |
| S1        | `0x5000_0400` ～ `0x5000_07FF` | Timer2   |
| S2        | `0x5000_0800` ～ `0x5000_0BFF` | Timer4   |
| S3        | `0x5000_0C00` ～ `0x5000_0FFF` | Timer6   |
| S4        | `0x5002_8000` ～ `0x5002_8FFF` | USI0     |
| S5        | `0x5002_9000` ～ `0x5002_9FFF` | USI2     |
| S7        | `0x5000_8000` ～ `0x5000_BFFF` | WDT      |
| S12       | `0x5001_C000` ～ `0x5001_FFFF` | PWM      |

其余 APB0 槽位接 `apb_dummy_top`，用于保留地址窗口和提供确定的总线响应。

### 7.2 APB1

APB1 中已实现的外设为：

| APB1 槽位 |                           地址范围 | 外设实例/所在域 |
| --------- | ---------------------------------: | --------------- |
| S0        | `0x6000_0000` ～ `0x6000_03FF` | Timer1，PDU     |
| S1        | `0x6000_0400` ～ `0x6000_07FF` | Timer3，PDU     |
| S2        | `0x6000_0800` ～ `0x6000_0BFF` | Timer5，PDU     |
| S3        | `0x6000_0C00` ～ `0x6000_0FFF` | Timer7，PDU     |
| S4        | `0x6002_8000` ～ `0x6002_BFFF` | USI1，PDU       |
| S5        | `0x6001_8000` ～ `0x6001_BFFF` | GPIO0，AOU      |
| S6        | `0x6000_4000` ～ `0x6000_7FFF` | RTC，AOU        |
| S15       | `0x6003_0000` ～ `0x6003_3FFF` | PMU，AOU        |

其余 APB1 槽位为 dummy。S5、S6、S15 值得特别注意：APB1 桥和选择信号由 PDU 产生，但 `gpio0_sec_top`、`rtc0_sec_top`、`pmu_dummy_top` 的实体在 AOU 内。PDU 把公共 `PADDR/PENABLE/PPROT/PWDATA/PWRITE` 和三个 `PSEL` 送至 AOU，AOU 再将相应 `PRDATA` 返回 APB1 数据选择逻辑。

USI 分布由此也很明确：USI0 和 USI2 挂 APB0，USI1 挂 APB1。三个实例均包含完整的 UART/SPI/I²C 通用 `usi_top`，APB 归属只决定寄存器访问路径和所用时钟/复位域，不代表必须由两个 USI 才能组成一个完整 UART。

## 8. 时钟与复位结构

顶层的两个振荡器接口经 `PAD_OSC_IO` 进入 AOU：

```text
PIN_EHS ----> PAD_OSC_IO ----> ehs_pmu_clk ----> pmu_dummy_top
PIN_ELS ----> PAD_OSC_IO ----> els_pmu_clk ----> pmu_dummy_top

PAD_MCURST ----> PAD_DIG_IO ----> pad_mcurst_b --+
                                                   +--> system reset generation
WDT reset request ----> wdt_pmu_rst_b -------------+
```

当前开源 RTL 使用的是 `pmu_dummy_top`，其实现比完整低功耗 PMU 简化：

- `ehs_pmu_clk` 直接作为 `soc_hclk`、`soc_p0clk`、`soc_p1clk` 和 `soc_s3clk`；
- `els_pmu_clk` 单独作为 RTC 工作时钟；
- 上述时钟再分发给 CPU、主 AHB、低速 AHB、SRAM、DMA、APB 桥及各外设；
- 系统复位条件为 `pad_mcurst_b & wdt_pmu_rst_b`，再分发成各域的低有效复位；
- APB0/APB1 的 `pclk_en` 在当前 dummy PMU 中固定为使能；
- `pad_core_ctim_refclk` 在当前实现中固定为 `0`。

因此信号名保留了 HCLK、P0CLK、P1CLK、S3CLK 等多时钟域结构，但在这份简化实现里大部分最终来自同一个 EHS 时钟。阅读时不应仅凭不同的信号名推断它们当前具有不同频率。

## 9. 中断路径

外设中断由 PDU/AOU 送到 `core_top`，在 `core_top` 中组合成 64 位 `ip_cpu_int_vld`，再接入 E902 的中断控制逻辑：

```text
Timers / PWM / WDT / USI0..2 / DMA ----> PDU ----+
GPIO / RTC / PMU -----------------------> AOU ----+----> core_top
AHB/APB dummy error interrupts ------------------+      |
                                                        +--> ip_cpu_int_vld[63:0]
                                                        +--> E902 CLIC/WIC
```

主要真实外设的向量映射为：

| `ip_cpu_int_vld` 位 | 来源                          |
| --------------------: | ----------------------------- |
|                     7 | CPU core timer                |
|                    16 | GPIO                          |
|                17～24 | Timer0～Timer3，每个 2 位中断 |
|                    25 | PWM                           |
|                    26 | RTC                           |
|                    27 | WDT                           |
|            28、29、30 | USI0、USI1、USI2              |
|                    31 | PMU                           |
|                    32 | DMA                           |
|                33～40 | Timer4～Timer7，每个 2 位中断 |

41～63 位主要接各级 dummy 从设备的中断输出，用于未实现/保留地址窗口的访问响应或验证。

## 10. 外部 PAD 与内部模块

| 顶层 PAD                                             | 内部归属      | 说明                             |
| ---------------------------------------------------- | ------------- | -------------------------------- |
| `PAD_GPIO_0`～`PAD_GPIO_31`                      | AOU/GPIO0     | 32 位双向 GPIO                   |
| `PAD_PWM_CH0`～`PAD_PWM_CH11`、`PAD_PWM_FAULT` | PDU/PWM       | 12 路 PWM/捕获相关通道及故障输入 |
| `PAD_USI0_*`                                       | PDU/APB0/USI0 | USI0 的`SCLK/SD0/SD1/NSS`      |
| `PAD_USI1_*`                                       | PDU/APB1/USI1 | USI1 的`SCLK/SD0/SD1/NSS`      |
| `PAD_USI2_*`                                       | PDU/APB0/USI2 | USI2 的`SCLK/SD0/SD1/NSS`      |
| `PAD_JTAG_TCLK`、`PAD_JTAG_TMS`                  | CPU/HAD       | 调试/TAP 接口                    |
| `PAD_MCURST`                                       | AOU/PMU       | 外部主复位输入                   |
| `PIN_EHS/POUT_EHS`                                 | AOU/PMU       | 高速外部时钟 PAD 对              |
| `PIN_ELS/POUT_ELS`                                 | AOU/RTC/PMU   | 低速外部时钟 PAD 对              |

USI PAD 都是双向数字 PAD。各 USI 根据 UART、SPI 或 I²C 模式生成 `out`、`oe_n` 和 `ie_n`，再由顶层 PAD 模型决定引脚当前是驱动还是采样状态。因此顶层看不到独立命名的 `UART_TX/UART_RX` 引脚；UART 功能复用在 USI 的 `SD0/SCLK` 等通用引脚上。

## 11. 典型访问路径

### 11.1 CPU 从 ISRAM 取指

```text
E902 IAHBL ----> Main AHB M0 ----> address decode S0
           ----> RETU/SMU/SMS ----> x_isram_top ----> instruction data returns
```

### 11.2 CPU 配置 USI0

```text
E902 data/system bus ----> Main AHB ----> S10 Low-speed AHB
                     ----> LS S2 ----> APB0 bridge ----> APB0 S4
                     ----> usi0_sec_top ----> usi_top registers/FIFO
```

### 11.3 CPU 配置 USI1

```text
E902 data/system bus ----> Main AHB ----> S10 Low-speed AHB
                     ----> LS S3 ----> APB1 bridge ----> APB1 S4
                     ----> usi1_sec_top ----> usi_top registers/FIFO
```

### 11.4 CPU 访问 GPIO

```text
E902 ----> Main AHB ----> Low-speed AHB ----> APB1 bridge
     ----> APB1 S5 select crosses PDU/AOU boundary ----> gpio0_sec_top
     <---- GPIO PRDATA crosses back to APB1 response mux <----+
```

### 11.5 DMA 搬运数据

```text
CPU ----> Main AHB S6 ----> program DMA registers
DMA ----> Main AHB M3 ----> read source / write destination
DMA ----> interrupt ----> core_top ----> E902
```

## 12. 主要 RTL 依据

- 顶层端口与四大实例：[`wujian100_open_top.v`](./wujian100_open_top.v)
- CPU 三路总线及中断向量：[`core_top.v`](./core_top.v)
- PDU 内部主矩阵、低速总线和 APB 子系统：[`pdu_top.v`](./pdu_top.v)
- 主/低速 AHB 地址译码：[`matrix.v`](./matrix.v)
- 主矩阵与 DMA 实例：[`ahb_matrix_top.v`](./ahb_matrix_top.v)
- Low-speed AHB 连接：[`ls_sub_top.v`](./ls_sub_top.v)
- APB0/APB1 外设实例：[`apb0_sub_top.v`](./apb0_sub_top.v)、[`apb1_sub_top.v`](./apb1_sub_top.v)
- APB 叶级地址：[`params/apb0_params.v`](./params/apb0_params.v)、[`params/apb1_params.v`](./params/apb1_params.v)
- AOU 中的 PMU/GPIO/RTC：[`aou_top.v`](./aou_top.v)
- 当前 dummy PMU 的时钟复位实现：[`clkgen.v`](./clkgen.v)
- RETU/SMU/SMS 存储层次：[`retu_top.v`](./retu_top.v)、[`smu_top.v`](./smu_top.v)、[`sms.v`](./sms.v)
- USI 公共核与三个实例封装：[`usi0.v`](./usi0.v)、[`usi1.v`](./usi1.v)

## 13. 阅读 RTL 时容易混淆的几点

1. `wujian100_open_top.v` 只直接实例化 CPU、PDU、RETU、AOU 和 PAD；Timer、USI、DMA 等都在子层次中。
2. `ahb_matrix_7_12_main` 的端口数是矩阵配置，不表示所有端口都接了真实设备；dummy 实例明确占据了未实现位置。
3. APB1 的地址译码属于 PDU，但 GPIO、RTC、PMU 实体属于 AOU。这是总线归属与电源/功能域归属不同的典型情况。
4. `usi0.v` 同时保存 USI 公共实现和 USI0 封装；`usi1.v` 保存 USI1/USI2 封装。判断实例归属应沿 `pdu_top -> apbN_sub_top -> usiN_sec_top -> usi_top` 追踪。
5. 当前 `pmu_dummy_top` 将多个名义时钟域直接接到 EHS 时钟。接口命名表达了完整 SoC 的域划分，实际开源实现则是简化版本。
