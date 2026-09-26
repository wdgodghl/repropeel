# Windows 本机验证记录（2026-09-26）

环境：Windows NT 10.0.26200.0、MoonBit CLI `0.1.20260920`、`moonc v0.10.14+7d59c7ec9`、Node.js `v24.15.0`。MoonBit 官方 Windows ZIP 已按官方 `.sha256` 文件核对，工具链和 Core 均放在工作区内。运行目标为 `js`。

执行 `moon check --target js`：0 个错误。执行 `moon test --target js`：3 个测试全部通过。

每个案例均执行 `moon run --target js cmd/main -- ...`，然后独立运行对应检查器验证输出，读取报告的 `final_verified`，并比较输入与输出的字节数：

| 案例 | 输入 | 输出 | 候选检查次数 | 独立复查 |
| --- | ---: | ---: | ---: | --- |
| `duplicate-id` | 326 B | 82 B | 20 | 通过 |
| `nested-config` | 384 B | 143 B | 14 | 通过 |
| `differential` | 371 B | 138 B | 19 | 通过 |

输出均为合法 JSON，且对应检查器均返回退出码 0。上述输出大小来自本次运行，MoonBit 工具链更新后缩减顺序或次数可能变化。
