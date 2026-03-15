# De Nicola 2021 Worktree Handoff Summary

## 1. Scope

This document summarizes the current worktree:

- path: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021`
- primary goal: build runnable Fig. 1 / Fig. 2 reproduction workflows for De Nicola et al. 2021, *Entanglement View of Dynamical Quantum Phase Transitions*
- current state:
  - Fig. 1 now has a full canonical iMPS / `o` / fidelity transfer matrix mechanism chain
  - Fig. 2 now has a runnable XXZ workflow with `TDVP` as the default backend
  - the shared canonical extraction logic has been corrected to recover the Schmidt spectrum and Schmidt basis from `svd(C)` instead of incorrectly reading `diag(C)`

This worktree still contains inherited repository content, including Osborne 2025 files, but the main line of work here is the De Nicola 2021 Fig. 1 / Fig. 2 reproduction path.

## 2. Main files that make this worktree run

### 2.1 Shared core

- `src/DeNicola2021Canonical.jl`

Responsibilities:

- build local product-state spinors
- recover paper-style `Gamma` tensors from MPSKit canonical data
- build the overlap matrix `o`
- build the fidelity transfer matrix
- extract leading transfer-matrix eigenvalues

The most important fix in this file is:

- use `svd(C)` rather than `diag(C)` to recover Schmidt values
- reconstruct `A = Lambda Gamma` in the Schmidt basis from `AC` and `C`

### 2.2 Fig. 1 module

- `src/DQPTFig1DeNicola2021.jl`

Responsibilities:

- define the Ising `pDQPT / eDQPT` presets
- evolve from strict product states
- compute `rate`, `s1,s2`, `lambda1,lambda2`, `|o11|`, `|ood|`, `|e1|`, `|e2|`
- generate the Fig. 1 TSV and PNG outputs

Fig. 1 currently uses a `WII` time-MPO evolution path.

### 2.3 Fig. 2 module

- `src/DQPTFig2DeNicola2021.jl`

Responsibilities:

- define the XXZ `pDQPT / eDQPT` presets
- compute `rate`
- compute the leading four entanglement weights
- compute overlap and transfer-matrix audit quantities
- compute `x`-magnetization
- compute the four MI curves: `I12`, `I13`, `I12_3`, `I12_4`
- generate the Fig. 2 TSV and PNG outputs

Fig. 2 currently defaults to:

- backend: `tdvp_optimal`
- algorithmic path: `TDVP + OptimalExpand + env reuse`

The `wii_svdcut` backend is still present as a comparison baseline.

### 2.4 Entry-point scripts

- `scripts/reproduce_dqpt_fig1_denicola_2021.jl`
- `scripts/plot_dqpt_fig1_denicola_2021.jl`
- `scripts/reproduce_dqpt_fig2_denicola_2021.jl`
- `scripts/plot_dqpt_fig2_denicola_2021.jl`

### 2.5 Main tests

- `test/test_denicola2021_canonical.jl`
- `test/test_dqpt_fig1_denicola_2021.jl`
- `test/test_dqpt_fig2_denicola_2021.jl`
- `test/runtests.jl`

## 3. How to run the worktree

All commands below assume the current directory is the worktree root.

### 3.1 Reproduce Fig. 1

```bash
julia --project=. scripts/reproduce_dqpt_fig1_denicola_2021.jl all
julia --project=. scripts/plot_dqpt_fig1_denicola_2021.jl
```

This generates:

- `outputs/fig1_pdqpt_denicola_2021.tsv`
- `outputs/fig1_edqpt_denicola_2021.tsv`
- `figures/report/dqpt_fig1_pdqpt_denicola_2021.png`
- `figures/report/dqpt_fig1_edqpt_denicola_2021.png`

### 3.2 Reproduce Fig. 2

```bash
julia --project=. scripts/reproduce_dqpt_fig2_denicola_2021.jl all --max-bond 100 --cutoff 1e-8 --backend tdvp_optimal
julia --project=. scripts/plot_dqpt_fig2_denicola_2021.jl
```

This generates:

- `outputs/fig2_pdqpt_denicola_2021.tsv`
- `outputs/fig2_edqpt_denicola_2021.tsv`
- `figures/report/dqpt_fig2_denicola_2021.png`
- `figures/report/dqpt_fig2_xxz_audit_denicola_2021.png`

### 3.3 Local eDQPT refinement

Fig. 2 now supports locally refined non-uniform time grids. Example:

```bash
julia --project=. scripts/reproduce_dqpt_fig2_denicola_2021.jl edqpt \
  --dt 0.05 \
  --max-bond 100 \
  --cutoff 1e-9 \
  --backend tdvp_optimal \
  --refine-start 1.0 \
  --refine-stop 1.3 \
  --refine-dt 0.005
```

This is mainly for resolving the `eDQPT` avoided crossing more sharply.

## 4. Output files currently produced

### 4.1 Fig. 1 main outputs

- `outputs/fig1_pdqpt_denicola_2021.tsv`
- `outputs/fig1_edqpt_denicola_2021.tsv`
- `figures/report/dqpt_fig1_pdqpt_denicola_2021.png`
- `figures/report/dqpt_fig1_edqpt_denicola_2021.png`
- `docs/notes/2026-03-14-dqpt-fig1-denicola-2021-analysis.md`

### 4.2 Fig. 2 main outputs

- `outputs/fig2_pdqpt_denicola_2021.tsv`
- `outputs/fig2_edqpt_denicola_2021.tsv`
- `figures/report/dqpt_fig2_denicola_2021.png`
- `figures/report/dqpt_fig2_xxz_audit_denicola_2021.png`
- `docs/notes/2026-03-14-dqpt-fig2-denicola-2021-analysis.md`

### 4.3 Fig. 2 supplemental diagnostics

- `outputs/fig2_edqpt_refined_twindow_denicola_2021.tsv`
- `outputs/fig2_edqpt_backend_wii_chi100.tsv`
- `outputs/fig2_edqpt_backend_tdvp_chi100.tsv`
- `outputs/fig2_edqpt_backend_tdvp_chi150.tsv`
- `outputs/fig2_edqpt_backend_tdvp_chi200.tsv`
- `figures/report/dqpt_fig2_edqpt_backend_compare_chi50.png`
- `figures/report/dqpt_fig2_edqpt_backend_compare_chi100.svg`
- `docs/plans/2026-03-14-dqpt-fig2-backend-comparison.md`

These files are mainly useful for:

- comparing `WII` and `TDVP`
- checking how little `chi = 100 -> 150 -> 200` changes the `eDQPT` line
- confirming that the coarse time step slightly broadens the `eDQPT` avoided crossing

## 5. What the current results look like

### 5.1 Fig. 1

Fig. 1 is no longer a proxy workflow. It now directly follows the paper mechanism chain:

- canonical iMPS
- entanglement spectrum
- overlap matrix `o`
- truncated fidelity transfer matrix

Most important current observations:

- `pDQPT`
  - rate peak at `t ≈ 1.5`
  - `s2 / s1 ≈ 0.077`
  - `|o11|` drops to about `0.146` near `t ≈ 1.55`
  - `|ood| ≈ 0.986`
  - this now cleanly supports the paper mechanism: the entanglement spectrum stays strongly separated while the overlap channel drives the DQPT

- `eDQPT`
  - the most paper-like event is near `t ≈ 2.35`
  - `s1 ≈ 0.746`, `s2 ≈ 0.666`
  - `|o11| ≈ 0.719`, `|ood| ≈ 0.717`
  - `|e1|` and `|e2|` show a near avoided crossing
  - this is now a mechanism-level reproduction, although the time window contains multiple similar events, so it should be read as an audit figure rather than a pixel-perfect panel clone

### 5.2 Fig. 2

Fig. 2 is now a paper-oriented workflow rather than a proxy-only one.

Most important current observations:

- `pDQPT`
  - dominant peak at `t ≈ 1.45`
  - `rate ≈ 2.14`
  - `mx ≈ -0.93`
  - `lambda1 ≈ 0.978`, `lambda2 ≈ 0.021`
  - `|o11| ≈ 0.134`, `|ood| ≈ 0.630`
  - conclusion: the `pDQPT` mechanism is qualitatively reproduced

- `eDQPT`
  - on the coarse main run, `min |lambda1 - lambda2| ≈ 0.0368 @ t ≈ 1.10`
  - with local refinement, `min |lambda1 - lambda2| ≈ 0.0253 @ t ≈ 1.12`
  - the main rate peak is about `0.390 ~ 0.392 @ t ≈ 1.20`
  - `chi = 100 -> 150 -> 200` does not materially change the key diagnostics
  - conclusion: the `eDQPT` avoided crossing is now reliably present; later discussion in this worktree showed that the remaining differences are mostly about panel detail and observable alignment, not a canonical bug or an insufficient bond cap

The user has explicitly judged the current Fig. 2 outputs to be acceptable by direct visual comparison with the paper.

## 6. Measured runtime scale

These are fresh timings measured inside this worktree.

### 6.1 Fig. 1

- main computation:
  - `julia --project=. scripts/reproduce_dqpt_fig1_denicola_2021.jl all`
  - measured `134.47s`
- plotting:
  - `julia --project=. scripts/plot_dqpt_fig1_denicola_2021.jl`
  - measured `4.11s`
- total scale:
  - about `2.3` minutes

### 6.2 Fig. 2

- main computation:
  - `julia --project=. scripts/reproduce_dqpt_fig2_denicola_2021.jl all --max-bond 100 --cutoff 1e-8 --backend tdvp_optimal`
  - measured `327.68s`
- plotting:
  - `julia --project=. scripts/plot_dqpt_fig2_denicola_2021.jl`
  - measured `4.97s`
- total scale:
  - about `5.5 ~ 6` minutes

### 6.3 Full test suite

- command:
  - `julia --project=. test/runtests.jl`
- measured:
  - `239.55s`
- total scale:
  - about `4` minutes

## 7. Current verification state

Fresh verification has passed:

```bash
julia --project=. test/runtests.jl
```

This means the current worktree state has a working:

- shared canonical helper
- Fig. 1 workflow
- Fig. 2 workflow
- plotting layer
- output parser layer

## 8. The main takeaways

1. The main result of this worktree is not just a few figures; it is a runnable De Nicola 2021 Fig. 1 / Fig. 2 reproduction path.
2. The shared canonical bug has been fixed. The key correction is to recover `Lambda` and the Schmidt basis from `svd(C)` rather than `diag(C)`.
3. Fig. 1 is currently stable on the `WII` path, while Fig. 2 should stay on `tdvp_optimal`.
4. Raising Fig. 2 `chi` from `100` to `150` or `200` does not materially improve the current `eDQPT` diagnostics.
5. If the next person only needs to regenerate outputs, the commands in Section 3 are enough.

## 9. Chinese version

The Chinese version is in the same directory:

- `docs/worktree-handoffs/dqpt-fig1-denicola-2021/README.zh-CN.md`
