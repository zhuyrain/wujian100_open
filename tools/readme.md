# `tools` 目录说明

本目录包含仿真环境初始化、用例构建执行和存储器镜像转换工具。

| 文件 | 作用 |
|---|---|
| `run_case` | 主用例运行脚本（Perl）。清空 `../workdir`，复制测试及运行库，调用 RISC-V 工具链编译，再启动 VCS 或 Icarus Verilog，最后把结果复制到 `../regress/regress_result`。 |
| `setup.csh` | C Shell 环境初始化，配置 Icarus Verilog/GTKWave路径、`TOOL_PATH` 和 `wujian100_open_PATH`。 |
| `bash_setup.sh` | Bash环境初始化示例，配置 VCS、RISC-V工具链和工程根路径；其中路径是本地环境相关配置。 |
| `Srec2vmem.py` | Python版 Motorola S-record 到 Verilog memory 初始化格式的转换器，由 `../lib/Makefile` 默认调用。 |
| `Srec2vmem` | 预编译的32位 x86 Linux转换程序，是 Python脚本的旧版二进制替代；运行需要兼容的32位动态库。 |

典型用法：

```bash
source bash_setup.sh
cd ../workdir
../tools/run_case -sim_tool iverilog ../case/timer/timer_test.c
```

注意：`run_case` 会递归删除 `workdir` 中已有内容，因此不要把手工源文件或唯一副本放入该目录。
