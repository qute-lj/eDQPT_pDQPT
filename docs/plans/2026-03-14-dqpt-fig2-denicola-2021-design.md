# DQPT Fig. 2 De Nicola 2021 Design

**Target paper:** Stefano De Nicola, Alexios A. Michailidis, Maksym Serbyn, *Entanglement View of Dynamical Quantum Phase Transitions*, Phys. Rev. Lett. 126, 040602 (2021)

**Target figure:** Main-text Fig. 2, all six panels, plus the XXZ entanglement/overlap audit implied by Fig. S4

**Goal:** Reproduce the paper's XXZ examples with a dedicated iMPS workflow that computes the fidelity density, entanglement-spectrum inset, x-magnetization, and mutual-information curves directly from the time-evolved state, then audit whether the resulting pDQPT and eDQPT mechanisms match the paper's interpretation.

## Scope

This round is intentionally limited to the two XXZ quenches of Fig. 2:

- `pDQPT` example:
  - initial state `|→⟩^{⊗}`
  - evolution parameters `Jx = Jy = 0.9`, `Jz = 1`, `hx = 0.1`, `hz = 1`
- `eDQPT` example:
  - initial state `|→⟩^{⊗}`
  - evolution parameters `Jx = Jy = 0.3`, `Jz = 1`, `hx = 0.3`, `hz = 0.1`

Out of scope for this round:

- later supplemental deformations such as Fig. S5
- analytic ansatz overlays
- rewriting the historical `run_xxz_neel_protocol` path

## Success Criteria

The implementation is successful only if it produces, from the numerical iMPS alone:

1. fidelity density / rate over time for both XXZ quenches
2. the leading entanglement-spectrum values needed for the Fig. 2 insets
3. the overlap diagnostics `|o11|` and `|ood|` needed to audit the pDQPT/eDQPT interpretation against Fig. S4
4. the local x-magnetization `⟨σx⟩`
5. the mutual-information curves
   - `I_{1,2}`
   - `I_{1,3}`
   - `I_{1,2;3}`
   - `I_{1,2;4}`
6. a note explaining how the numerics compare to the paper's claims

Qualitative signatures should match the paper:

- `pDQPT`: cusp-like fidelity structure with a clearly gapped leading entanglement spectrum, minima in `|o11|`, magnetization near the opposite sign of the initial `x`-polarization, and slowly growing near-monotonic MI
- `eDQPT`: fidelity cusp near an avoided crossing of the leading entanglement spectrum, overlap behavior consistent with avoided crossing, `⟨σx⟩` close to a local minimum in magnitude, and oscillatory MI with a broad maximum in `I_{1,2;3}`

## Architecture

### 1. Shared canonical diagnostics

The canonical-form helpers already validated in the Fig. 1 workflow should be extracted into a minimal shared module. This keeps the XXZ workflow from depending on the entire Ising-specific Fig. 1 driver while preserving the same canonical conventions.

Shared outputs:

- product-state spinors such as `|→⟩`
- leading Schmidt values
- canonical `Γ` tensor recovered from the left-canonical tensor and Schmidt values
- overlap matrix `o`
- fidelity transfer matrix `T_f`
- leading transfer-matrix eigenvalues

### 2. XXZ Fig. 2 driver

A dedicated XXZ driver should build the two paper Hamiltonians, evolve the iMPS in time, and record all diagnostics at each sampled time. The new workflow should not extend `run_xxz_neel_protocol`; that function encodes an older proxy experiment with different initial conditions and different observables.

Planned implementation:

- new shared module: `src/DeNicola2021Canonical.jl`
- new source module: `src/DQPTFig2DeNicola2021.jl`
- new run script: `scripts/reproduce_dqpt_fig2_denicola_2021.jl`

Time evolution should follow the MPSKit time-MPO path used successfully for Fig. 1, with truncation chosen to mirror the paper's numerical setup as closely as practical:

- `make_time_mpo(..., WII())`
- compression via `SvdCut`
- truncation rule `trunctol(; atol = 1e-9) & truncrank(200)`

### 3. Mutual-information engine

The MI should be computed from reduced density matrices, not from connected-correlation proxies. This is necessary because the paper's MI panel includes disconnected regions such as `I_{1,3}` and `I_{1,2;4}`.

Implementation strategy:

- contract a 4-site reduced density matrix `ρ1234` from the canonical iMPS
- obtain the needed marginals by partial trace
- compute von Neumann entropies from the reduced-density eigenvalues
- assemble the four MI curves with the paper's exact region choices

The 4-site window keeps the local Hilbert-space dimension small enough to remain numerically cheap while still covering every region used in Fig. 2.

### 4. Plotting and audit outputs

Artifacts should be split into:

- raw TSV outputs for both XXZ quenches
- a single `3 x 2` figure matching the information content of Fig. 2
- an audit figure for XXZ entanglement/overlap diagnostics, inspired by Fig. S4
- an analysis note explaining whether the reproduction is actually faithful

The main figure should contain:

- top row: `f(t)` with an entanglement-spectrum inset
- middle row: `⟨σx⟩`
- bottom row: the four MI curves

The audit output should additionally show:

- leading entanglement weights
- `|o11|` and `|ood|`
- optionally the leading fidelity-transfer-matrix eigenvalue magnitudes if useful for debugging or interpretation

## File Plan

Planned new or modified files:

- `docs/plans/2026-03-14-dqpt-fig2-denicola-2021-design.md`
- `docs/plans/2026-03-14-dqpt-fig2-denicola-2021.md`
- `src/DeNicola2021Canonical.jl`
- `src/DQPTFig2DeNicola2021.jl`
- `scripts/reproduce_dqpt_fig2_denicola_2021.jl`
- `scripts/plot_dqpt_fig2_denicola_2021.jl`
- `test/test_dqpt_fig2_denicola_2021.jl`
- `test/runtests.jl`
- `docs/notes/2026-03-14-dqpt-fig2-denicola-2021-analysis.md`
- `outputs/fig2_pdqpt_denicola_2021.tsv`
- `outputs/fig2_edqpt_denicola_2021.tsv`
- `figures/report/dqpt_fig2_denicola_2021.png`
- `figures/report/dqpt_fig2_xxz_audit_denicola_2021.png`

## Testing Strategy

The implementation will follow TDD.

Test layers:

1. unit tests for the shared canonical helpers and 4-site reduced-density / MI utilities
2. short smoke evolutions for both Fig. 2 presets to verify finite outputs and complete columns
3. fresh end-to-end verification on the paper parameter sets

The end-to-end audit must confirm:

- `pDQPT` remains in a gapped low-entanglement regime near the DQPT and shows a minimum in `|o11|`
- `eDQPT` occurs near an avoided crossing in the leading entanglement spectrum and shows oscillatory MI with a broad `I_{1,2;3}` feature
- the generated plots and TSVs can be recreated from scratch with the provided scripts

## Worktree Plan

Implementation will continue in the isolated git worktree `.worktrees/dqpt-fig1-denicola-2021`, which already contains the new De Nicola 2021 Fig. 1 workflow. Fig. 2 will live alongside it with the same naming convention, keeping the paper-oriented reproduction work separate from the older repository experiments.
