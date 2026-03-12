# DQPT PRL 2021 Reproduction with Julia + MPSKit

This directory contains a local qualitative reproduction of the main physical distinction emphasized in

- Stefano De Nicola, Alexios A. Michailidis, Maksym Serbyn, *Entanglement View of Dynamical Quantum Phase Transitions*, Phys. Rev. Lett. 126, 040602 (2021)
- DOI: <https://doi.org/10.1103/PhysRevLett.126.040602>

It also uses the standard transverse-field Ising DQPT setup introduced in

- M. Heyl, A. Polkovnikov, S. Kehrein, *Dynamical Quantum Phase Transitions in the Transverse-Field Ising Model*, Phys. Rev. Lett. 110, 135704 (2013)
- DOI: <https://doi.org/10.1103/PhysRevLett.110.135704>

## What is in this repo

The current workflow implements two infinite-MPS quench protocols in local Julia/MPSKit:

1. `Ising baseline`
   - Infinite-chain TFIM quench
   - Tracks Loschmidt rate, entanglement entropy, and unit-cell-averaged magnetization
   - Used here as the `pDQPT`-like baseline

2. `XXZ N\'eel protocol`
   - Two-site-unit-cell XXZ real-time evolution starting from a N\'eel product state
   - Tracks Loschmidt rate, entanglement entropy, and staggered magnetization
   - Used here as the more `eDQPT`-like comparison channel

It also now contains a first finite-chain workflow for

3. `Osborne 2025 Ising-side confinement story`
   - Finite-chain Ising-like quench aimed at Osborne, McCulloch, and Halimeh (2025)
   - Main backend: `:longrange`
   - Practical fallback backend: `:proxy`
   - Tracks finite-chain Loschmidt rate, mean bipartite entropy, and mean `mz`
   - Intended as a first local route toward the paper's `branch` versus `manifold` DQPT distinction

This is a qualitative reproduction, not a claim of exact figure-by-figure agreement with the PRL and its supplement.

## Files

- `src/DQPTPRL2021.jl`
  Main library code for state construction, CLI parsing, time evolution, and TSV output.
- `src/DQPTOsborne2025.jl`
  Osborne 2025 finite-chain helpers, Hamiltonian builders, classification logic, and TSV output.
- `scripts/reproduce_dqpt_prl_2021.jl`
  Script entrypoint for running the reproduction.
- `scripts/reproduce_osborne_2025.jl`
  Script entrypoint for the Osborne 2025 finite-chain workflow.
- `scripts/plot_osborne_results.jl`
  Small plotting entrypoint for the current Osborne 2025 long-range window summary.
- `test/runtests.jl`
  Test entrypoint.
- `test/test_helpers.jl`
  Smoke tests for helper functions and both simulation channels.
- `test/test_osborne2025.jl`
  Smoke tests for the Osborne 2025 finite-chain workflow.
- `outputs/`
  Generated TSV files and short summaries.
- `dqpt_reading_list.md`
  Local reading notes and paper positioning.

## Environment assumption

This directory currently does not use its own pinned `Project.toml`.
The workflow assumes your Julia environment can already do:

```julia
using MPSKit, MPSKitModels, TensorKit
```

That matches the local setup used during development here.

## Quick start

Run the Ising baseline:

```bash
julia scripts/reproduce_dqpt_prl_2021.jl ising --steps 40 --dt 0.05 --output-prefix medium
```

Run the XXZ N\'eel channel:

```bash
julia scripts/reproduce_dqpt_prl_2021.jl xxz --steps 40 --dt 0.05 --output-prefix medium
```

Run both:

```bash
julia scripts/reproduce_dqpt_prl_2021.jl all --steps 40 --dt 0.05 --output-prefix medium
```

Run the Osborne 2025 fallback workflow:

```bash
julia scripts/reproduce_osborne_2025.jl \
  --backend proxy \
  --length 10 \
  --steps 6 \
  --dt 0.1 \
  --hz 0.2 \
  --output-prefix osborne_proxy_smoke
```

Run a small Osborne comparison summary:

```bash
julia scripts/reproduce_osborne_2025.jl compare \
  --backend proxy \
  --length 10 \
  --steps 6 \
  --dt 0.1 \
  --hz 0.2 \
  --compare-hz 0.6 \
  --output-prefix osborne_compare
```

Render the current long-range window figure from the saved compare summaries:

```bash
julia scripts/plot_osborne_results.jl
```

Refine the Ising cusp location with a smaller time step:

```bash
julia scripts/reproduce_dqpt_prl_2021.jl ising \
  --steps 90 \
  --dt 0.02 \
  --output-prefix refine \
  --vumps-maxiter 60 \
  --vumps-tol 1e-10 \
  --bond-dim 16 \
  --grow-steps 40 \
  --grow-by 1
```

## Main CLI options

- `ising | xxz | all`
  Select which protocol to run. Default is `all`.
- `--steps`
  Number of real-time steps.
- `--dt`
  Real-time step size.
- `--output-prefix`
  Prefix of the generated TSV file names.
- `--bond-dim`
  Initial Ising iMPS bond dimension.
- `--grow-steps`
  Number of early-time bond-growth steps.
- `--grow-by`
  Increment used by `OptimalExpand`.
- `--g0`, `--g1`
  Pre- and post-quench TFIM field values.
- `--delta`
  XXZ anisotropy.
- `--vumps-maxiter`, `--vumps-tol`
  Ground-state solver settings for the Ising initial state.

## Osborne 2025 CLI options

- `single | compare`
  Optional positional mode for `scripts/reproduce_osborne_2025.jl`. Default is `single`.
- `--backend`
  `longrange` for the Path A target backend or `proxy` for the current fallback backend.
- `--length`
  Finite-chain length.
- `--steps`
  Number of real-time steps.
- `--dt`
  Real-time step size.
- `--output-prefix`
  Prefix used for TSV and summary files.
- `--J`, `--g`, `--alpha`, `--hz`
  Hamiltonian parameters for the finite-chain Ising-like quench.
- `--bond-dim`
  Truncation rank used in the early finite-chain `TDVP2` steps.
- `--compare-hz`
  Second longitudinal-field value used by compare mode.

## Output format

Generated files are written to `outputs/`.

### `*_ising.tsv`

Columns:

- `time`
- `rate`
- `entropy`
- `mx`
- `mz`

### `*_xxz.tsv`

Columns:

- `time`
- `rate`
- `entropy`
- `mz1`
- `mz2`
- `staggered_mz`

### `*_<backend>.tsv`

Generated by `scripts/reproduce_osborne_2025.jl` in single-run mode.

Columns:

- `time`
- `rate`
- `entropy`
- `mz`

### `*_low_<backend>.tsv`, `*_high_<backend>.tsv`

Generated by `scripts/reproduce_osborne_2025.jl compare` for two confinement settings.

Columns:

- `time`
- `rate`
- `entropy`
- `mz`

### `*_<backend>_summary.md`

Generated by Osborne compare mode.

Contents:

- dominant peak time
- peak rate
- peak-time `mz`
- conservative `branch` or `manifold` classification
- maximum entropy reached during the run
- maximum absolute energy drift relative to the initial time
- maximum allocated bond dimension encountered in the run

See also `outputs/README.md`.

## Current reproduced results

The current local runs support the main qualitative narrative of the 2021 PRL:

- In the refined Ising run, the strongest early-time rate peak appears at `t = 1.16`, close to the standard TFIM DQPT estimate `t* ≈ 1.175`.
- At that Ising peak, the mean entanglement entropy is only about `0.474`, while the local order parameter is still appreciable.
- In the XXZ N\'eel channel, a strong rate peak appears together with noticeably larger entanglement growth.
- By the final time in the `medium` XXZ run, the entropy is about `1.070` and the staggered magnetization is nearly gone.
- In the Osborne 2025 `longrange` Path A workflow, finite-chain compare runs at `L = 6, 8, 10, 12` now consistently show a nearby `branch` versus `manifold` separation.
- The strongest current interpretation is a finite-size-shifting confinement crossover: the `manifold` candidate window moves toward smaller `hz` as `L` increases.
- A compact summary figure for that drift is available at `figures/report/osborne_longrange_window.png`.

These numbers are summarized in:

- `outputs/2026-03-11-summary.md`
- `outputs/refine_ising.tsv`
- `outputs/medium_ising.tsv`
- `outputs/medium_xxz.tsv`

## Testing

Run:

```bash
julia test/runtests.jl
```

The tests are intentionally smoke-level:

- helper functions
- CLI parsing
- minimal Ising evolution
- minimal XXZ evolution
- minimal Osborne 2025 finite-chain evolution

They verify that the workflow is wired correctly, but they do not prove publication-level numerical convergence.

## Plotting

Generate both analysis and report figures:

```bash
julia scripts/plot_results.jl --style all
```

Generate only analysis figures:

```bash
julia scripts/plot_results.jl --style analysis
```

Generate only the cleaner report figure:

```bash
julia scripts/plot_results.jl --style report
```

Generated files are written to:

- `figures/analysis/ising_diagnostics.png`
- `figures/analysis/xxz_diagnostics.png`
- `figures/analysis/comparison_overview.png`
- `figures/report/dqpt_qualitative_comparison.png`

## Interpretation and limits

This repository should be read as:

- a clean local starting point for reproducing the paper's physical story with MPSKit
- a scriptable data generator for further sweeps
- a qualitative, not final, numerical comparison to the published paper

What is still missing if you want a tighter paper-level reproduction:

- full parameter matching against the PRL supplement
- longer time windows and convergence sweeps in bond dimension
- plotting scripts for publication-style figures
- a more careful identification of `pDQPT` and `eDQPT` observables exactly as defined in the paper
- long-range Osborne evolution checks and stronger `branch/manifold` evidence

## Suggested next steps

1. Add a plotting script to turn the TSV files into rate/entropy/order-parameter panels.
2. Sweep `bond_dim`, `grow_steps`, and `dt` to check convergence.
3. Re-read the paper supplement and align the XXZ channel more tightly with the published parameter set.
4. Add a second entanglement-focused protocol if the paper section you care about is not fully captured by the current XXZ setup.
