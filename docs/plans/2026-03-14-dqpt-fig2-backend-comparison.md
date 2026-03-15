# DQPT Fig.2 Backend Comparison Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a second Fig.2 evolution backend based on `TDVP + OptimalExpand + env reuse`, and compare it against the existing `WII + SvdCut` workflow under the same low-`chi` settings.

**Architecture:** Keep the existing Fig.2 observable and analysis code intact, but factor the time-evolution step behind a backend selector. The default backend remains the current MPO-apply path for compatibility; a new explicit `:tdvp_optimal` backend will use MPSKit's infinite-state `changebonds(..., OptimalExpand, envs)` plus `timestep(..., TDVP(), envs)` path so the two workflows can be compared with the same diagnostics.

**Tech Stack:** Julia, MPSKit, MPSKitModels, TensorKit, Test

---

### Task 1: Backend API and CLI surface

**Files:**
- Modify: `src/DQPTFig2DeNicola2021.jl`
- Modify: `scripts/reproduce_dqpt_fig2_denicola_2021.jl`
- Test: `test/test_dqpt_fig2_denicola_2021.jl`

**Step 1: Write the failing test**

Add tests that:
- parse `--backend tdvp_optimal`
- preserve the current default backend
- verify `run_fig2_xxz_quench(...; backend=:tdvp_optimal)` returns a result whose `parameters.backend` is `:tdvp_optimal`

**Step 2: Run test to verify it fails**

Run: `julia --project=. test/test_dqpt_fig2_denicola_2021.jl`

Expected: FAIL because backend parsing / result metadata does not exist yet.

**Step 3: Write minimal implementation**

Add:
- backend parsing helper
- `backend::Symbol` keyword to `run_fig2_xxz_quench`
- backend metadata in returned `parameters`
- CLI plumbing in `scripts/reproduce_dqpt_fig2_denicola_2021.jl`

**Step 4: Run test to verify it passes**

Run: `julia --project=. test/test_dqpt_fig2_denicola_2021.jl`

Expected: PASS for the new backend API tests.

### Task 2: TDVP backend implementation

**Files:**
- Modify: `src/DQPTFig2DeNicola2021.jl`
- Test: `test/test_dqpt_fig2_denicola_2021.jl`

**Step 1: Write the failing test**

Add a smoke test that runs `run_fig2_xxz_quench(...; backend=:tdvp_optimal, steps=2, max_bond=16, cutoff=1e-8)` and verifies:
- finite outputs
- correct `t=0` baselines
- overlap values remain bounded by `1 + 1e-9`

**Step 2: Run test to verify it fails**

Run: `julia --project=. test/test_dqpt_fig2_denicola_2021.jl`

Expected: FAIL because the TDVP backend does not exist yet.

**Step 3: Write minimal implementation**

Implement a backend-specific stepper:
- `:wii_svdcut`: current `DenseMPO(make_time_mpo(..., WII()))` path
- `:tdvp_optimal`: initialize `envs = environments(psi, H)`, grow bonds with `changebonds(psi, H, OptimalExpand(; trscheme = truncrank(1)), envs)` for an early-time window, and advance with `timestep(psi, H, 0, dt, TDVP(), envs)`

Keep diagnostics identical across both backends.

**Step 4: Run test to verify it passes**

Run: `julia --project=. test/test_dqpt_fig2_denicola_2021.jl`

Expected: PASS for both backends.

### Task 3: Verification and comparison

**Files:**
- Modify: `docs/notes/2026-03-14-dqpt-fig2-denicola-2021-analysis.md`

**Step 1: Run targeted verification**

Run:
- `julia --project=. test/test_dqpt_fig2_denicola_2021.jl`
- `julia --project=. test/runtests.jl`

Expected: PASS

**Step 2: Run low-chi comparison probes**

Run both backends at matching low-`chi` settings for `pDQPT` and `eDQPT`, record:
- runtime cost
- `min(o11)`, `max(ood)`
- `min(|lambda1-lambda2|)`
- `min(|mx|)`
- `max(I12_3)`

**Step 3: Update the analysis note**

Document whether:
- the TDVP path is measurably faster or slower
- the TDVP path moves the curves closer to the paper
- the remaining mismatch now looks primarily like bond-dimension pressure or backend-specific evolution error
