# Benchmark record

This record was generated locally on 2026-08-21 from the checked-in fixtures
and commands. It is evidence for one environment, not a universal performance
claim.

| Measurement | Result |
| --- | ---: |
| MoonBit source lines (`*.mbt`) | 10,115 |
| `moon test --deny-warn` | 9 passed |
| Test wall time | 165.9596 ms |
| `moon run cmd/spice` wall time | 166.8416 ms |

Environment:

- Moon: `0.1.20260807`
- Moonc: `v0.10.7+bc794d341`
- OS: Windows NT `10.0.26200.0`
- CPU: Intel(R) Core(TM) i9-14900HX

Reproduce with:

```powershell
moon version --all
Measure-Command { moon test --deny-warn }
Measure-Command { moon run cmd/spice }
(rg --files -g '*.mbt' | ForEach-Object { (Get-Content $_).Count } |
  Measure-Object -Sum).Sum
```
