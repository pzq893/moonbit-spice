# moonbit-spice

`moonbit-spice` is a reusable SPICE-like circuit analysis library written in
MoonBit. It turns a readable netlist into a validated circuit model, assembles
modified nodal analysis (MNA) equations, solves the operating point, and emits
structured results for teaching tools, design utilities, scripts, and future
WASM front ends.

## Core capabilities

- SPICE-like parsing with blank lines, comments, directives, duplicate-name
  detection, and engineering suffixes (`k`, `meg`, `m`, `u`, `n`, `p`).
- Resistors, capacitors, inductors, diodes, independent current sources, and
  independent voltage sources.
- Dense MNA with partial pivoting, residual diagnostics, singular-system
  reporting, deterministic node ordering, and circuit topology inventory.
- DC operating-point analysis with explicit warnings for DC approximations.
- Reusable matrix/vector utilities, time grids and integration primitives,
  deterministic parameter sweeps, complex-value helpers, and result reports.
- CSV, text, and Markdown output that can be consumed by a CLI or a notebook.

The implementation is intentionally explicit about model boundaries. AC and
full nonlinear/transient circuit solves are represented by extension points and
small reusable kernels; the library does not fabricate results for analyses it
does not yet solve physically.

## Quick start

```moonbit nocheck
let circuit = @spice.parse_netlist(
  "V1 in 0 10\nR1 in out 1k\nR2 out 0 1k",
)
let result = @spice.dc(circuit)
println(result.summary())
```

From the repository root:

```bash
moon fmt --check
moon check --deny-warn
moon test --deny-warn
moon run cmd/spice
```

The sample input is also available at
[`examples/voltage-divider.cir`](examples/voltage-divider.cir).

## CLI

`moon run cmd/spice` runs a deterministic voltage-divider smoke example and
prints a Markdown report. It is deliberately dependency-free so a fresh MoonBit
checkout can run it without a package manager or native runtime library.

The library API is the stable integration surface. Applications can read a file,
call `parse_netlist`, choose `dc` or `analyze`, and serialize with
`report_csv`, `report_markdown`, or `SimulationResult::summary`.

## Architecture

```text
netlist text
    -> parser and validation
    -> Circuit / Device model
    -> MNA stamping
    -> DenseMatrix + MatrixSolver
    -> SimulationResult
    -> CSV / text / Markdown report
```

The `src/` package keeps public data structures and the analysis boundary in one
place. Matrix, topology, sweep, transient, complex-value, reporting, and
benchmark utilities are split into focused files so callers can reuse the
smallest useful unit.

## Benchmarks

The reproducible fixtures and commands live in [`benchmarks/`](benchmarks/).
They measure the real parser, MNA, topology, and formatting path. Run:

```powershell
Measure-Command { moon test --deny-warn }
moon run cmd/spice
```

Timings depend on the host and toolchain. CI stores the command output as an
artifact instead of presenting an unrepeatable number as a universal claim.

## Tests and boundary coverage

Tests cover voltage-divider and current-source solutions, suffix parsing,
duplicate devices, result exports, matrix residuals, topology connectivity,
ordered sweeps, invalid transient grids, and Markdown report metadata. The
stricter local gate is:

```bash
moon fmt --check
moon check --deny-warn
moon test --deny-warn
moon info
```

## CI

GitHub Actions runs the current MoonBit installer on Ubuntu, macOS, and Windows.
It checks all targets, formatting, public interface generation, warnings, tests,
and the CLI smoke path. A separate workflow records deterministic benchmark
artifacts. See [`.github/workflows/ci.yml`](.github/workflows/ci.yml).

## License

Released under the [MIT License](LICENSE). The project is an independent
MoonBit implementation. The example circuits are small educational fixtures and
do not include copied third-party source or proprietary model files.
