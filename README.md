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

This is a qualitative reproduction, not a claim of exact figure-by-figure agreement with the PRL and its supplement.

## Files

- `src/DQPTPRL2021.jl`
  Main library code for state construction, CLI parsing, time evolution, and TSV output.
- `scripts/reproduce_dqpt_prl_2021.jl`
  Script entrypoint for running the reproduction.
- `test/runtests.jl`
  Test entrypoint.
- `test/test_helpers.jl`
  Smoke tests for helper functions and both simulation channels.
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

See also `outputs/README.md`.

## Current reproduced results

The current local runs support the main qualitative narrative of the 2021 PRL:

- In the refined Ising run, the strongest early-time rate peak appears at `t = 1.16`, close to the standard TFIM DQPT estimate `t* ≈ 1.175`.
- At that Ising peak, the mean entanglement entropy is only about `0.474`, while the local order parameter is still appreciable.
- In the XXZ N\'eel channel, a strong rate peak appears together with noticeably larger entanglement growth.
- By the final time in the `medium` XXZ run, the entropy is about `1.070` and the staggered magnetization is nearly gone.

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

They verify that the workflow is wired correctly, but they do not prove publication-level numerical convergence.

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

## Suggested next steps

1. Add a plotting script to turn the TSV files into rate/entropy/order-parameter panels.
2. Sweep `bond_dim`, `grow_steps`, and `dt` to check convergence.
3. Re-read the paper supplement and align the XXZ channel more tightly with the published parameter set.
4. Add a second entanglement-focused protocol if the paper section you care about is not fully captured by the current XXZ setup.
