# PRL 2021 ESQPT Diagnostics Design

**Target line:** Stefano De Nicola, Alexios A. Michailidis, Maksym Serbyn, *Entanglement View of Dynamical Quantum Phase Transitions*, Phys. Rev. Lett. 126, 040602 (2021), DOI: <https://doi.org/10.1103/PhysRevLett.126.040602>

**Goal:** Add an explicit finite-size `ESQPT` diagnostics path to the PRL 2021 workspace without conflating `ESQPT` with `eDQPT`.

## Design decision

We will implement `ESQPT` diagnostics as a separate finite-size spectral workflow, not as a reinterpretation of the existing infinite-MPS quench outputs.

That choice is deliberate:

- the existing `pDQPT / eDQPT` code studies real-time dynamics
- standard `ESQPT` detection is based on singular structure in the excited-state spectrum near a critical energy

Therefore the new workflow will scan finite chains through exact diagonalization and emit spectral proxies:

- local density-of-states proxy from level spacings
- energy-resolved observables
- state-structure diagnostics through `IPR/PR`

## Scope

The first implementation pass will cover:

1. finite-size Ising-family spectral scan relevant to the PRL 2021 discussion
2. optional finite-size XXZ scan using the same diagnostics interface
3. markdown output that explicitly states the meaning and limitations of the method

The workflow will not claim proof of an `ESQPT`. It will report:

- candidate critical-energy windows
- which diagnostic produced each candidate
- the finite-size and boundary-condition assumptions used

## Technical approach

We will extend the Julia codebase with small dense exact-diagonalization helpers for short chains.

Reasoning:

- the current project is already Julia-based
- no extra Python environment is needed
- exact diagonalization at `L <= 10` is enough for a first finite-size proxy workflow
- the implementation remains testable and self-contained

The Hamiltonians will be built in the computational basis using dense matrices and diagonalized with `LinearAlgebra.eigen(Hermitian(H))`.

## Outputs

For each scan we will save:

- `*_esqpt_spectrum.tsv`
  - `energy`
  - `density_proxy`
  - `observable`
  - `ipr`
  - optional extra observable columns

- `*_esqpt_summary.md`
  - clear statement of method
  - finite-size model definition
  - candidate energies from density proxy
  - candidate energies from observable curvature
  - candidate energies from state-structure anomalies
  - interpretation caveat

## Verification

Minimum verification will include:

- unit tests for Hamiltonian dimensions and sorted spectra
- unit tests for density and IPR helper behavior
- a short end-to-end run creating TSV and markdown outputs
- inspection that the summary text explicitly states the method definition

## Risks

- finite-size chains can only provide `ESQPT` proxies, not thermodynamic-limit proof
- open versus periodic boundaries may shift candidate energies
- some models used in the DQPT literature do not have a universally accepted `ESQPT` interpretation, so wording must remain conservative
