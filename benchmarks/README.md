# Benchmarks

The benchmark suite measures the actual parser and dense MNA path on deterministic
fixtures. It is intentionally small enough to run in CI and large enough to
exercise matrix assembly, pivoting, result formatting, and topology inventory.

Run from the repository root:

```powershell
Measure-Command { moon test --deny-warn }
moon run cmd/spice
```

The CI benchmark job records the complete toolchain version, command, exit code,
and elapsed time as an artifact. Timings are environment-specific; the checked-in
fixtures and command are the reproducible benchmark contract.

## Fixtures

- `voltage-divider.cir`: three-element baseline.
- `resistor-ladder.cir`: repeated MNA stamping and deterministic node ordering.
- `mixed-signal.cir`: source, reactive, diode, and current-source diagnostics.

Benchmark outputs must be generated from these files and should never be copied
from an unrelated machine.
