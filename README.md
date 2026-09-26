# 剥例 ReproPeel

**把复杂的 JSON 故障输入，缩减成更容易排查的小样本。**

A MoonBit JSON failure-input reducer: peel away irrelevant data while preserving a user-defined failure predicate.

## 项目状态

项目已完成选题与首版范围设计，正在准备开发。当前仓库包含项目说明、开发计划和许可证，尚未提供可运行版本。以下功能均为计划功能。

本项目计划参加 [2026 MoonBit 黑客松](https://moonbitlang.github.io/Hackathon2026/)。报名及审核状态以赛事方确认结果为准。

## 解决的问题

程序可能只在处理一份很大的 JSON 文件时出错。开发者通常需要反复删除字段和数组元素、重新运行程序，才能找到容易理解的复现样本。

ReproPeel 计划自动完成这个过程：

1. 输入一份能够稳定复现问题的 JSON 文件。
2. 提供一条检查命令，用于判定候选输入是否仍触发目标错误。
3. 工具逐步删除对象字段、数组元素和无关子树，并重新检查。
4. 输出更小的复现文件，以及记录缩减过程和停止原因的报告。

每个候选输入保持合法 JSON。业务约束和目标错误由检查命令判断。缩减结果不保证是全局最小样本，也不能单凭退出码证明故障根因相同。

## 首版计划

- 使用 MoonBit 实现可复用的缩减核心和命令行工具。
- 支持 JSON 对象字段、数组元素的分块删除与递归缩减。
- 将候选文件交给外部检查命令，区分目标错误仍存在、目标错误消失和检查无法判定。
- 缓存重复候选的检查结果。
- 设置单次检查超时和总尝试次数限制。
- 保留原始输入，输出独立的缩减文件。
- 输出输入规模、检查次数、缓存命中和停止原因等统计。
- 提供测试、可复现案例和使用说明。

完整的首版范围与验收条件见 [开发计划](PLAN.md)。

## 与已有工具的关系

测试输入缩减是已有研究方向，本项目不主张发明新的缩减算法。MoonBit QuickCheck 已支持属性测试中的反例缩减；ReproPeel 聚焦开发者已有的 JSON 故障文件，并通过外部检查命令连接被测程序。

- [MoonBit 属性测试介绍](https://www.moonbitlang.com/blog/property-based-testing-moonbit)
- [MoonBit 文档](https://docs.moonbitlang.com/)
- [MoonBit 异步进程 API](https://mooncakes.io/docs/moonbitlang/async/process)

## 许可证

[MIT](LICENSE)
