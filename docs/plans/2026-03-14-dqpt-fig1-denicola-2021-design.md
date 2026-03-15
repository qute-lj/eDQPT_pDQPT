# DQPT Fig. 1 De Nicola 2021 Design

**Target paper:** Stefano De Nicola, Alexios A. Michailidis, Maksym Serbyn, *Entanglement View of Dynamical Quantum Phase Transitions*, Phys. Rev. Lett. 126, 040602 (2021)

**Target figure:** Main-text Fig. 1, specifically the numerical solid-line diagnostics in panels (d) and (e)

**Goal:** Reproduce the paper's Fig. 1 numerical mechanism chain for the Ising examples by building a canonical-iMPS workflow that connects the time-evolved MPS to the fidelity transfer matrix, its leading eigenvalues, the leading entanglement-spectrum values, and the overlap matrix `o`.

## Scope

This round is intentionally limited to the two Ising quenches in Fig. 1:

- `pDQPT` example:
  - initial state `|↓⟩^{⊗}`
  - evolution parameters `J = 0.1`, `hx = 1`, `hz = 0.15`
- `eDQPT` example:
  - initial state `|→⟩^{⊗}`
  - evolution parameters `J = 1`, `hx = 0.1`, `hz = 0.15`

Out of scope for this round:

- XXZ example from Fig. 2
- mutual information diagnostics
- dashed analytic `χ = 2` ansatz overlay, unless the numerical chain is already complete and stable

## Success criteria

The implementation is successful only if it produces, from the numerical iMPS alone:

1. fidelity density / rate over time
2. the leading two entanglement-spectrum values
3. the key overlap-matrix entries `|o11|` and `|ood|`
4. the leading fidelity-transfer-matrix eigenvalues
5. a note explaining how these quantities are related in the implemented canonical representation

Qualitative signatures should match the paper:

- `pDQPT`: the leading Schmidt values stay well separated near the DQPT, while the dominant change is in the overlap matrix
- `eDQPT`: the leading Schmidt values approach an avoided crossing near the DQPT, and the transfer-matrix eigenvalue switch tracks that rearrangement

## Architecture

### 1. Ising Fig. 1 driver

A dedicated driver will construct the two paper quenches, evolve the iMPS in time, and call a common diagnostic pipeline at every sampled time.

Planned implementation:

- new source module: `src/DQPTFig1DeNicola2021.jl`
- new run script: `scripts/reproduce_dqpt_fig1_denicola_2021.jl`

### 2. Canonical diagnostics

The driver will extract canonical-form data from the current iMPS state using MPSKit-native gauge/canonical objects. The implementation should use the package's existing canonical representation rather than introducing a custom gauge convention.

Primary outputs:

- canonical tensors needed to define the fidelity transfer matrix
- leading Schmidt values / singular values

### 3. Fidelity transfer matrix analysis

The analysis layer will construct the fidelity transfer matrix `T_f` using:

- the canonical tensor of the time-evolved state
- the product-state bra representing the initial state

It will then compute:

- the leading two eigenvalues of `T_f`
- the overlap matrix `o`
- derived diagnostics connecting `T_f`, the entanglement spectrum, and the overlap structure

### 4. Output and plotting

Artifacts will be split into:

- raw TSV outputs with time-series data
- figure-specific plots matching the information content of Fig. 1(d) and Fig. 1(e)
- a note explaining the implemented formulas and numerical interpretation

## File plan

Planned new or modified files:

- `docs/plans/2026-03-14-dqpt-fig1-denicola-2021-design.md`
- `docs/plans/2026-03-14-dqpt-fig1-denicola-2021.md`
- `src/DQPTFig1DeNicola2021.jl`
- `scripts/reproduce_dqpt_fig1_denicola_2021.jl`
- `scripts/plot_dqpt_fig1_denicola_2021.jl`
- `test/test_dqpt_fig1_denicola_2021.jl`
- `docs/notes/2026-03-14-dqpt-fig1-denicola-2021-analysis.md`
- `outputs/fig1_pdqpt_denicola_2021.tsv`
- `outputs/fig1_edqpt_denicola_2021.tsv`
- `figures/report/dqpt_fig1_pdqpt_denicola_2021.png`
- `figures/report/dqpt_fig1_edqpt_denicola_2021.png`

## Testing strategy

The implementation will follow TDD.

Test layers:

1. unit tests for diagnostic helpers
2. short smoke evolutions for both paper examples
3. fresh end-to-end verification on the paper parameter sets

The end-to-end check must confirm that the generated diagnostics support the intended `pDQPT` versus `eDQPT` interpretation before any completion claim is made.

## Worktree plan

Implementation will proceed in the isolated git worktree `.worktrees/dqpt-fig1-denicola-2021` so the existing proxy-reproduction files stay separate from the new Fig. 1 workflow.
