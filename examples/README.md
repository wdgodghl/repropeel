# ReproPeel examples

Each pair contains an original failing JSON input and a deterministic Node.js checker.
The checker exits with 0 only when its named target condition remains true, 1 when
the condition disappears, and 2 for malformed or unreadable input.

| Prefix | Target condition |
| --- | --- |
| `duplicate-id` | At least two records share a string ID. |
| `nested-config` | A transform stage has `retry: -1`. |
| `differential` | Per-line and final-total cent rounding disagree. |

Run from the repository root, replacing the prefix:

```sh
node examples/duplicate-id.checker.js examples/duplicate-id.input.json
```

Exit code 0 confirms the baseline. See the repository README for reducer usage.
