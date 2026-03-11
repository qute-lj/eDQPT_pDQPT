# DQPT PRL 2021 Reproduction Design

**Target paper:** Stefano De Nicola, Alexios A. Michailidis, Maksym Serbyn, *Entanglement View of Dynamical Quantum Phase Transitions*, Phys. Rev. Lett. 126, 040602 (2021), DOI: <https://doi.org/10.1103/PhysRevLett.126.040602>

**Goal:** Reproduce the paper's main qualitative distinction between precession-driven DQPTs (`pDQPT`) and entanglement-driven DQPTs (`eDQPT`) using local Julia + MPSKit workflows.

## Scope

This reproduction will proceed in two stages:

1. Implement a robust infinite-chain Ising quench workflow that measures:
   - Loschmidt rate function
   - entanglement entropy
   - local magnetizations
2. Extend the same workflow to a second model with a two-site unit cell to capture an `eDQPT`-type protocol.

The primary success criterion is qualitative agreement with the paper's narrative:

- `pDQPT`: cusps in the Loschmidt rate coincide with coherent order-parameter precession and do not require strong entanglement buildup.
- `eDQPT`: cusps are accompanied by stronger entanglement growth and are not explained by simple local precession alone.

## Technical approach

We will use source-aligned MPSKit APIs already present in the local environment:

- `InfiniteMPS` for translation-invariant or two-site-unit-cell states
- `find_groundstate(..., VUMPS())` when a ground state is needed
- `timestep(..., TDVP(), envs)` for infinite real-time evolution
- `changebonds(..., OptimalExpand(...), envs)` to grow bond dimension during early entanglement buildup
- `dot(psi0, psi_t)` for the infinite-chain Loschmidt amplitude density
- `entropy(psi)` and `expectation_value(psi, i => O)` for diagnostics

## Model strategy

### Stage A: Ising baseline / `pDQPT`

Start from the MPSKit DQPT example and generalize it into a reusable script. This gives a known-good baseline and verifies the local setup before adding the 2021 paper's extra diagnostics.

### Stage B: Entanglement-focused protocol / `eDQPT`

Use a two-site-unit-cell infinite MPS workflow with a symmetry-broken or product-like initial state and a post-quench Hamiltonian built either from `heisenberg_XXZ` or a custom `InfiniteMPOHamiltonian`, depending on which reproduces the paper's phenomenology more stably in local runs.

The selection between built-in XXZ and a custom Ising-with-longitudinal-field Hamiltonian will be based on:

- API stability in the local MPSKit version
- ability to initialize the target state cleanly
- whether the resulting data shows the expected entropy/cusp separation

## Deliverables

- `scripts/reproduce_dqpt_prl_2021.jl`
- a small test file for nontrivial helper logic
- output data under `outputs/`
- a short run note summarizing parameter choices and observed behavior

## Verification

Minimum verification will include:

- a smoke test for helper functions and product-state construction
- a short local run that produces nontrivial time-series output
- confirmation that the Ising baseline reproduces known DQPT cusp structure
- confirmation that the extended protocol produces both rate-function and entropy diagnostics

## Constraints and risks

- This workspace is not a git repository, so no commit artifacts will be produced.
- The exact microscopic parameters used in the PRL may need one iteration of tuning if the paper's full text or supplement is not locally available.
- Full quantitative matching to the published figures is less realistic in one pass than a qualitative reproduction with clearly documented assumptions.
