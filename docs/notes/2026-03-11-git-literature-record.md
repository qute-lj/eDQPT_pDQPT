# 2026-03-11 Git and Literature Record

## Git snapshot

- `HEAD`: `d8ac581` (`git init: init 2021 prl eDQPT_pDQPT paper.`)
- Commit scope: initial repository import for the 2021 PRL qualitative reproduction, including the MPSKit workflow, tests, outputs, reading list, and design/implementation plans.

## Working tree changes relative to `HEAD`

### Modified tracked files

- `README.md`
  - adds plotting usage examples
  - records the four generated PNG outputs
- `test/test_helpers.jl`
  - imports `Plots`
  - loads `DQPTPlots`
  - adds tests for TSV parsing, figure-path planning, and figure-bundle creation

### Untracked source and documentation

- `src/DQPTPlots.jl`
  - adds TSV loading, plot-style parsing, figure composition, and PNG rendering
- `scripts/plot_results.jl`
  - adds a small Julia CLI for plotting existing Ising and XXZ outputs
- `docs/plans/2026-03-11-dqpt-plots-design.md`
  - plotting workflow design note
- `docs/plans/2026-03-11-dqpt-plots.md`
  - plotting implementation plan

### Untracked generated artifacts

- `figures/analysis/ising_diagnostics.png`
- `figures/analysis/xxz_diagnostics.png`
- `figures/analysis/comparison_overview.png`
- `figures/report/dqpt_qualitative_comparison.png`

## Verified state on 2026-03-11

- `julia test/runtests.jl`
  - passes, including the Ising and XXZ smoke tests and the new plotting tests
- `julia scripts/plot_results.jl --style all`
  - regenerates all four figure outputs successfully
- `julia scripts/reproduce_dqpt_prl_2021.jl ising --steps 90 --dt 0.02 --output-prefix heyl2013 --vumps-maxiter 60 --vumps-tol 1e-10 --bond-dim 16 --grow-steps 40 --grow-by 1`
  - regenerates a refined TFIM reference run for `Heyl et al. 2013`
- `julia scripts/reproduce_dqpt_prl_2021.jl all --steps 40 --dt 0.05 --output-prefix denicola2021 --vumps-maxiter 40 --vumps-tol 1e-8`
  - regenerates the current `De Nicola et al. 2021` comparison data
- fresh run summary:
  - `outputs/2026-03-11-paper-reproduction-summary.md`

## Important papers around `eDQPT/pDQPT`

The current repository is centered on De Nicola, Michailidis, and Serbyn (2021), but the most important nearby papers are not all equally suitable for the same reproduction workflow.

| Priority | Paper | Why it matters | Fit to current Julia + MPSKit workflow |
| --- | --- | --- | --- |
| 1 | Heyl, Polkovnikov, Kehrein (2013), *Dynamical Quantum Phase Transitions in the Transverse-Field Ising Model* | Foundational DQPT paper. It defines the Loschmidt-rate nonanalyticity story that later `pDQPT/eDQPT` work builds on. | Direct fit. The current Ising baseline is already the right model family and observable set. |
| 2 | De Nicola, Michailidis, Serbyn (2021), *Entanglement View of Dynamical Quantum Phase Transitions* | Source paper for the `pDQPT/eDQPT` distinction. It is the conceptual center of this repo. | Direct fit. The current Ising-versus-XXZ comparison is already aimed at this paper. |
| 3 | Heyl (2015), *Scaling and Universality at Dynamical Quantum Phase Transitions* | Elevates DQPT from “there is a cusp” to a dynamical critical-phenomena viewpoint with scaling language. | Partial fit. The current refined Ising runs capture cusp timing, but full reproduction still needs extra scaling diagnostics. |
| 4 | Halimeh et al. (2020), *Quasiparticle origin of dynamical quantum phase transitions* | Explains DQPT structure through excitation content and anomalous cusps, which is highly relevant for interpreting `pDQPT/eDQPT` mechanisms. | Medium fit. It likely needs additional Hamiltonian support or wider sweeps beyond the current two-channel workflow. |
| 5 | Van Damme et al. (2023), *Anatomy of dynamical quantum phase transitions* | Organizes several DQPT mechanisms into a broader conceptual picture and is a strong modern synthesis paper. | Low-to-medium fit. Reproducing it credibly will need extra observables or new models. |
| 6 | Jurcevic et al. (2017), *Direct Observation of Dynamical Quantum Phase Transitions in an Interacting Many-Body System* | Key experimental anchor showing DQPT physics is measurable, not only formal. | Qualitative fit only. The current observables overlap, but the trapped-ion platform is not the current model. |

## Why these rankings matter

- If the goal is to understand what `pDQPT/eDQPT` is built on, the essential chain is `2013 -> 2015 -> 2021`.
- If the goal is to understand why different cusp types occur, `Halimeh 2020` becomes the next paper after `2021`.
- If the goal is to connect theory to experiment, `Jurcevic 2017` is the quickest bridge.
- If the goal is to organize the field after the original definitions, `Van Damme 2023` is the most useful synthesis paper in the current reading list.

## Recommended reproduction order with the existing scheme

### Immediate targets

1. `Heyl et al. 2013`
   - use the current Ising quench workflow
   - emphasize rate-function cusps and their location
2. `De Nicola et al. 2021`
   - use the current Ising-versus-XXZ split
   - emphasize entropy growth versus local-order dynamics

### Partial target without replacing the scheme

3. `Heyl 2015`
   - reuse refined Ising runs
   - add scaling-oriented diagnostics rather than changing the model first

### Phase-2 targets

4. `Halimeh et al. 2020`
5. `Van Damme et al. 2023`
6. `Jurcevic et al. 2017`

These are still important, but they are less natural fits for the exact workflow already implemented in this repository.
