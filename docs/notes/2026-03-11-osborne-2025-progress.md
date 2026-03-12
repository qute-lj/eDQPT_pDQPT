# 2026-03-11 Osborne 2025 Progress Note

## What `batch` meant

In the previous update, `batch` referred to the first execution block from
`docs/plans/2026-03-11-osborne-2025.md`, namely the first three tasks in that plan.

For this repository state, that means:

1. scaffold a new Osborne 2025 module and CLI parser
2. add finite-chain state construction and Hamiltonian backends
3. add a finite-chain quench driver, TSV export, and a script entrypoint

This note only summarizes work that is already implemented and verified locally.

## Scope actually completed

The current work follows the repo's chosen Osborne 2025 direction:

- target paper: Osborne, McCulloch, Halimeh (2025)
- focus: Ising-side confinement story
- mainline design: `Path A`
- current verified runtime path: `Path B` style `:proxy` fallback evolution

At this point, the codebase has a first finite-chain Osborne workflow, but it is still an
early-stage reproduction scaffold rather than a paper-level comparison.

## Files added or changed

### New source

- `src/DQPTOsborne2025.jl`
  - finite-chain Loschmidt-rate helper
  - Osborne-specific CLI parsing
  - polarized product-state construction
  - Hamiltonian backend switch
  - finite-chain quench driver
  - TSV output writer

### New script

- `scripts/reproduce_osborne_2025.jl`
  - runs the Osborne finite-chain workflow from the command line
  - writes `outputs/<prefix>_<backend>.tsv`
  - prints a small runtime summary

### New tests

- `test/test_osborne2025.jl`
  - helper parsing tests
  - finite-chain state and Hamiltonian smoke coverage
  - finite-chain quench smoke coverage for the `:proxy` backend

### Test entrypoint change

- `test/runtests.jl`
  - now includes the Osborne 2025 test file

## Implemented behavior

### 1. Helper and CLI scaffold

The new module exports:

- `finite_loschmidt_rate`
- `parse_osborne_cli`

The parser currently supports:

- `--backend`
- `--length`
- `--steps`
- `--dt`
- `--output-prefix`
- `--J`
- `--g`
- `--alpha`
- `--hz`
- `--bond-dim`

### 2. Finite-chain initial state and Hamiltonians

The new module also exports:

- `build_polarized_state`
- `build_osborne_hamiltonian`

Two Hamiltonian backends are present:

- `:longrange`
  - finite-chain Ising-like Hamiltonian with power-law `zz` couplings
  - intended to match the repo's `Path A` direction
- `:proxy`
  - nearest-neighbor `zz` couplings plus transverse and longitudinal fields
  - used as the practical fallback path

### 3. Finite-chain quench driver and output

The new module exports:

- `ensure_dir`
- `run_osborne_quench`
- `save_osborne_result`

The runtime result currently records:

- `times`
- `rate`
- `entropy`
- `mz`
- a `parameters` tuple

The output TSV format is:

- `time`
- `rate`
- `entropy`
- `mz`

## Verification performed

### Targeted Osborne tests

Command:

```bash
julia test/test_osborne2025.jl
```

Observed passing testsets:

- `Osborne helper parsing`
- `Osborne state and Hamiltonian builders`
- `Osborne quench smoke test`

### Full repository regression

Command:

```bash
julia test/runtests.jl
```

Observed result:

- the pre-existing Ising and XXZ smoke tests still pass
- the new Osborne tests also pass

### Script smoke run

Command:

```bash
julia scripts/reproduce_osborne_2025.jl \
  --backend proxy \
  --length 6 \
  --steps 1 \
  --dt 0.1 \
  --hz 0.2 \
  --bond-dim 8 \
  --output-prefix osborne_smoke
```

Observed generated file:

- `outputs/osborne_smoke_proxy.tsv`

Observed summary values from that run:

- `backend = proxy`
- `peak time = 0.1`
- `peak rate = 0.0012241021398594833`
- `max entropy = 3.525978913487936e-8`
- `final mz = 0.4987766451722547`

The TSV header and first data rows are consistent with the intended format.

## Current limitations

This is the main status boundary right now:

- `:longrange` Hamiltonian construction exists and is test-covered
- actual time-evolution smoke verification has only been completed for `:proxy`
- no regime classification or compare-mode summary has been added yet
- README and outputs documentation have not yet been updated for the Osborne workflow

There is also a practical runtime caveat:

- a fresh Julia process pays a heavy first-use JIT cost for finite-chain `TDVP2`
- on local verification, the first finite-chain real-time step was dominated by compilation time

## Current interpretation

The repository now has a working first Osborne 2025 implementation scaffold for the
Ising-side confinement story.

What it can already do:

- build a finite-chain Osborne-specific Hamiltonian
- run a minimal fallback quench
- save the result as TSV
- keep that workflow under automated tests

What it cannot yet claim:

- a completed `branch` versus `manifold` analysis
- a validated `Path A` long-range evolution result
- a paper-level reproduction of Osborne, McCulloch, and Halimeh (2025)
