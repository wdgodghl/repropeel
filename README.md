# 剥例 ReproPeel

用 MoonBit 缩小能够稳定触发错误的 JSON 输入。输入一份故障文件和一条检查命令，ReproPeel 按块删除对象字段、数组元素，再递归处理嵌套结构。只有检查命令确认目标故障仍存在时，候选才会被保留。

当前实现已在 [GitHub Actions](https://github.com/wdgodghl/repropeel/actions/workflows/ci.yml) 和 Windows 本机的 JavaScript 后端通过 MoonBit 类型检查、单元测试和三个端到端缩减案例。案例会验证输出仍触发目标条件且比输入更小。本机运行记录见 [验证报告](docs/verification-2026-09-26.md)。

## 环境

- [MoonBit CLI Tools](https://www.moonbitlang.com/download/)
- Node.js 18 或更高版本
- 当前命令行后端为 JavaScript；MoonBit 负责缩减算法与流程，Node.js FFI 负责文件和子进程。

## 快速开始

```sh
moon check --target js
moon test --target js
moon run --target js cmd/main -- examples/duplicate-id.input.json --out duplicate-min.json --report duplicate-report.json --max-checks 500 --timeout-ms 5000 -- node examples/duplicate-id.checker.js {candidate}
```

两条输出路径在运行前都必须不存在。`{candidate}` 是完整参数占位符，不能嵌入其他文字。检查命令直接执行，不经过 shell。

## 检查协议

| 检查命令退出码 | 含义 | 处理 |
| --- | --- | --- |
| 0 | 目标故障仍然存在 | 接受更小候选 |
| 1 | 目标故障消失或前提不成立 | 拒绝候选 |
| 其他、启动失败或超时 | 无法判断 | 拒绝候选，记录次数 |

工具先对原始输入做基线检查，结束时再次独立检查最终候选。两次都需要退出码 0。候选文件位于系统临时目录；原始输入不会被覆盖。`--max-checks` 约束缩减期间的检查次数，不含基线和最终复查。

检查命令必须识别**同一个目标故障**，不能简单地把所有异常当成故障仍存在。ReproPeel 只保证输出是合法 JSON，业务规则由检查命令负责。结果是局部缩减，不保证全局最小。

## 案例

| 目录 | 目标故障 | 可保留的必要条件 |
| --- | --- | --- |
| `examples/duplicate-id.*` | 导入记录出现重复 ID | 至少两条相同 ID 记录 |
| `examples/nested-config.*` | 转换阶段重试数为负 | `transform` 阶段及 `retry: -1` |
| `examples/differential.*` | 两种金额汇总方式不一致 | 两个 `0.005` 单价项目 |

把快速开始中的示例路径和输出文件名替换即可运行其他案例。检查脚本只是确定性的演示，实际使用时应调用你的程序并精确核对目标错误。

## 报告字段

报告为 JSON，包含 `input_bytes`、`output_bytes`、`candidate_checks`、`cache_hits`、`unresolved_checks`、`accepted_reductions`、`budget_exhausted` 和 `final_verified`。目前不记录逐次候选和检查命令的标准输出。

## 项目说明

本项目计划参加 [2026 MoonBit 黑客松](https://moonbitlang.github.io/Hackathon2026/)。参赛与审核状态以赛事方确认为准。测试输入缩减已有先例；本项目针对**已存在的 JSON 故障文件**以及任意外部检查命令，不主张发明新的缩减算法。开发范围与验收条件见 [PLAN.md](PLAN.md)。

许可证：[MIT](LICENSE)。
