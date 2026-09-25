# `regress` 目录说明

本目录保存回归测试结果。测试由 `../tools/run_case` 执行，结果文件按用例名称复制到 `regress_result/`。

| 路径 | 作用 |
|---|---|
| `regress_result/` | 各测试用例的最终状态和报告集合。 |
| `regress_result/README` | 原工程对结果目录的简短说明。 |
| `regress_result/<case>.report` | 对应用例的结果文件，常见内容为 `TEST PASS`、失败状态或 `NOT RUN`。当前包含 `usi_spi_test.report`。 |

这些文件是运行结果而非设计输入。重新运行同名用例会覆盖相应报告；判断回归是否完整时应同时检查报告是否存在、是否为 `TEST PASS`，以及仿真日志中是否有超时或异常退出。
