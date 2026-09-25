# `lib` 目录说明

本目录为 RTL 仿真用例提供裸机启动、链接、最小 C 运行库和编译规则。`tools/run_case` 会把所需文件复制到 `../workdir` 后编译测试程序。

## 顶层文件

| 文件 | 作用 |
|---|---|
| `Makefile` | 使用 `riscv64-unknown-elf-*` 工具链编译测试程序，生成 `.elf`、`.obj`、`.hex` 和 `test.pat`。 |
| `crt0.s` | 裸机启动代码，负责复位入口、基础运行环境和进入 C 程序前的初始化。 |
| `linker.lcf` | 链接脚本，定义代码、数据、栈及片上存储器的地址布局；`run_case` 会替换其中的地址占位符。 |

## `clib/`

轻量级 C 库的头文件和最小输出实现：

| 文件 | 作用 |
|---|---|
| `config.h` | 最小 C 库的编译配置。 |
| `datatype.h` | 基础数据类型定义。 |
| `minilibc_stdio.h`、`printf.h` | 精简 stdio/格式化输出接口声明。 |
| `fputc.c` | 字符输出的底层实现，通常连接到仿真 UART/控制台。 |
| `vtimer.h` | 测试程序使用的虚拟计时器接口。 |

## `newlib_wrap/`

提供 printf 家族、字符输入输出以及整数/浮点格式转换的轻量封装，用于避免测试程序依赖完整宿主 C 库。

| 文件组 | 作用 |
|---|---|
| `printf.c`、`fprintf.c`、`vprintf.c`、`vfprintf.c`、`__v_printf.c` | 格式化输出核心及其不同入口。 |
| `sprintf.c`、`snprintf.c`、`vsprintf.c`、`vsnprintf.c` | 向字符串缓冲区输出格式化文本。 |
| `putc.c`、`putchar.c`、`puts.c` | 字符和字符串输出接口。 |
| `getc.c`、`getchar.c` | 字符输入接口。 |
| `__ltostr.c`、`__lltostr.c` | 整数到字符串转换。 |
| `__dtostr.c`、`__isinf.c`、`__isnan.c` | 浮点字符串转换及特殊值判断。 |
| `minilibc_stdio.h` | 上述封装的公共声明。 |
| `csi.mk` | CSI 工程引用这些源码/库时使用的 Make 配置。 |
| `riscv/rv32ec/`、`riscv/rv32emc/` | 面向不同 E902 RISC-V ISA 配置的架构相关库文件或构建输出位置。 |

本目录是仿真软件构建输入；编译生成的 `.o/.elf/.hex/.obj/.pat` 位于 `../workdir`，不应回写到这里。
