# DQPT Fig. 2 De Nicola 2021 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build and verify a paper-oriented Julia/MPSKit workflow that numerically reproduces Fig. 2 of De Nicola et al. (2021) for the XXZ chain, including fidelity density, entanglement-spectrum inset, x-magnetization, and mutual-information curves, and then audit whether the reproduced pDQPT/eDQPT mechanisms match the paper.

**Architecture:** Keep the implementation separate from the historical proxy workflow by extracting a minimal shared canonical-diagnostics module and adding a dedicated XXZ Fig. 2 module, CLI, and plotting script. The evolution layer will generate time-evolved iMPS states for the two paper XXZ quenches, while the analysis layer will compute canonical overlap/transfer diagnostics, 4-site reduced density matrices, and the exact mutual-information curves used in the paper.

**Tech Stack:** Julia, MPSKit, MPSKitModels, TensorKit, LinearAlgebra, DelimitedFiles, Test, Plots, and the existing De Nicola 2021 Fig. 1 worktree.

---

### Task 1: Extract shared canonical helpers under test

**Files:**
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/src/DeNicola2021Canonical.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/src/DQPTFig1DeNicola2021.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_denicola2021_canonical.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/runtests.jl`
- Test: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_denicola2021_canonical.jl`

**Step 1: Write the failing test**

Add a new focused test file covering the helper contracts already relied on by Fig. 1:

```julia
@test build_local_spinor(:down) ≈ ComplexF64[0.0, 1.0]
@test build_local_spinor(:right) ≈ ComplexF64[inv(sqrt(2)), inv(sqrt(2))]
@test leading_entanglement_spectrum(Diagonal([0.9, 0.3]); count = 2) ≈ [0.81, 0.09]
@test overlap_matrix(gamma, ComplexF64[1.0, 0.0]; count = 2) ≈ expected
@test abs.(leading_transfer_eigenvalues(transfer; count = 2)) ≈ expected_abs
```

Use small hand-built toy tensors so these tests validate math, not time evolution.

**Step 2: Run test to verify it fails**

Run: `julia test/test_denicola2021_canonical.jl`
Expected: FAIL because the shared canonical module does not yet exist.

**Step 3: Write minimal implementation**

Create `src/DeNicola2021Canonical.jl` and move the reusable helpers out of the Fig. 1 module:

- `build_local_spinor`
- `build_single_site_product_state`
- `leading_singular_values`
- `leading_entanglement_spectrum`
- `canonical_gamma_from_left`
- `overlap_matrix`
- `fidelity_transfer_matrix`
- `leading_transfer_eigenvalues`

Update `src/DQPTFig1DeNicola2021.jl` to include and reuse the new shared module instead of duplicating those functions.

**Step 4: Run test to verify it passes**

Run: `julia test/test_denicola2021_canonical.jl`
Expected: PASS.

**Step 5: Commit**

```bash
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 add src/DeNicola2021Canonical.jl src/DQPTFig1DeNicola2021.jl test/test_denicola2021_canonical.jl test/runtests.jl
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 commit -m "refactor: extract denicola 2021 canonical helpers"
```

### Task 2: Add failing tests for the Fig. 2 XXZ presets and Hamiltonian driver skeleton

**Files:**
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/src/DQPTFig2DeNicola2021.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_dqpt_fig2_denicola_2021.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/runtests.jl`
- Test: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_dqpt_fig2_denicola_2021.jl`

**Step 1: Write the failing test**

Add helper-level tests for the two paper presets and the CLI:

```julia
cfg_p = paper_fig2_preset(:pdqpt)
@test cfg_p.initial_state == :right
@test cfg_p.Jx == 0.9
@test cfg_p.Jy == 0.9
@test cfg_p.Jz == 1.0
@test cfg_p.hx == 0.1
@test cfg_p.hz == 1.0

cfg_e = paper_fig2_preset(:edqpt)
@test cfg_e.Jx == 0.3
@test cfg_e.hx == 0.3
@test cfg_e.hz == 0.1

cli = parse_fig2_cli(["pdqpt", "--steps", "8", "--dt", "0.05"])
@test cli.mode == :pdqpt
@test cli.steps == 8
@test cli.dt == 0.05
```

**Step 2: Run test to verify it fails**

Run: `julia test/test_dqpt_fig2_denicola_2021.jl`
Expected: FAIL because the Fig. 2 module does not yet exist.

**Step 3: Write minimal implementation**

Create `src/DQPTFig2DeNicola2021.jl` with:

- `paper_fig2_preset`
- `parse_fig2_cli`
- a minimal `build_fig2_xxz_hamiltonian`
- any include/import glue needed to reuse `DeNicola2021Canonical`

Prefer `@mpskit-time-evolution` conventions and source-aligned MPSKit model construction.

**Step 4: Run test to verify it passes**

Run: `julia test/test_dqpt_fig2_denicola_2021.jl`
Expected: PASS for the preset/CLI tests.

**Step 5: Commit**

```bash
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 add src/DQPTFig2DeNicola2021.jl test/test_dqpt_fig2_denicola_2021.jl test/runtests.jl
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 commit -m "test: scaffold denicola 2021 fig2 presets"
```

### Task 3: Add failing tests for reduced-density and mutual-information math

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_dqpt_fig2_denicola_2021.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/src/DQPTFig2DeNicola2021.jl`
- Test: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_dqpt_fig2_denicola_2021.jl`

**Step 1: Write the failing test**

Add pure linear-algebra tests for the MI utilities before wiring them to iMPS contractions:

```julia
rho_prod = ket_to_density(product_state_4spin())
@test von_neumann_entropy(rho_prod) ≈ 0.0 atol = 1e-12
@test mutual_information_from_rho(rho_prod, [1], [2], 4) ≈ 0.0 atol = 1e-12

rho_bell = ket_to_density(bell_pair_12_tensor_product_34())
@test mutual_information_from_rho(rho_bell, [1], [2], 4) ≈ 2log(2) atol = 1e-10
@test mutual_information_from_rho(rho_bell, [1], [3], 4) ≈ 0.0 atol = 1e-10
```

Also add tests for the exact curve keys expected from the Fig. 2 MI bundle:

```julia
mi = mutual_information_bundle(rho1234)
@test keys(mi) == Set(["I12", "I13", "I12_3", "I12_4"])
```

**Step 2: Run test to verify it fails**

Run: `julia test/test_dqpt_fig2_denicola_2021.jl`
Expected: FAIL because the reduced-density and MI helpers do not exist.

**Step 3: Write minimal implementation**

Implement:

- `partial_trace_sites`
- `von_neumann_entropy`
- `mutual_information_from_rho`
- `mutual_information_bundle`

Keep this code independent of MPSKit state evolution so the math stays easy to test.

**Step 4: Run test to verify it passes**

Run: `julia test/test_dqpt_fig2_denicola_2021.jl`
Expected: PASS.

**Step 5: Commit**

```bash
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 add src/DQPTFig2DeNicola2021.jl test/test_dqpt_fig2_denicola_2021.jl
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 commit -m "feat: add fig2 mutual information utilities"
```

### Task 4: Add failing tests for 4-site iMPS diagnostics and short XXZ smoke runs

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_dqpt_fig2_denicola_2021.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/src/DQPTFig2DeNicola2021.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/scripts/reproduce_dqpt_fig2_denicola_2021.jl`
- Test: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_dqpt_fig2_denicola_2021.jl`

**Step 1: Write the failing test**

Add smoke tests for both paper presets with very short evolutions, for example `steps = 2`, `dt = 0.05`, and a reduced truncation cap:

```julia
result = run_fig2_xxz_quench(; preset = :pdqpt, dt = 0.05, steps = 2, max_bond = 16)
@test result.preset == :pdqpt
@test length(result.times) == 3
@test all(isfinite, result.rate)
@test all(isfinite, result.mx)
@test all(isfinite, result.lambda1)
@test all(isfinite, result.o11)
@test all(isfinite, result.I12)
@test all(isfinite, result.I12_3)
```

Mirror the same smoke contract for `:edqpt`.

**Step 2: Run test to verify it fails**

Run: `julia test/test_dqpt_fig2_denicola_2021.jl`
Expected: FAIL because the XXZ evolution driver, 4-site RDM contraction, and result schema do not yet exist.

**Step 3: Write minimal implementation**

Implement:

- `run_fig2_xxz_quench`
- 4-site reduced-density contraction from a canonical iMPS
- x-magnetization measurement
- overlap diagnostics `|o11|`, `|ood|`
- fidelity-density measurement
- MI bundle attachment to the result object
- minimal CLI entrypoint in `scripts/reproduce_dqpt_fig2_denicola_2021.jl`

Use the same product-state overlap convention as Fig. 1. For evolution, start with:

```julia
evolution_mpo = MPSKit.DenseMPO(make_time_mpo(H, Float64(dt), WII()))
trscheme = truncrank(max_bond) & trunctol(; atol = cutoff)
psi = changebonds(evolution_mpo * psi, SvdCut(; trscheme = trscheme))
normalize!(psi)
```

Expose `max_bond` and `cutoff` so tests can run cheaply while the paper path defaults to `max_bond = 200`, `cutoff = 1e-9`.

**Step 4: Run test to verify it passes**

Run: `julia test/test_dqpt_fig2_denicola_2021.jl`
Expected: PASS for the smoke runs.

**Step 5: Commit**

```bash
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 add src/DQPTFig2DeNicola2021.jl scripts/reproduce_dqpt_fig2_denicola_2021.jl test/test_dqpt_fig2_denicola_2021.jl
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 commit -m "feat: add denicola 2021 fig2 xxz driver"
```

### Task 5: Add failing tests for output schema, audit plot, and full Fig. 2 plot assembly

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_dqpt_fig2_denicola_2021.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/src/DQPTFig2DeNicola2021.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/scripts/plot_dqpt_fig2_denicola_2021.jl`
- Test: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_dqpt_fig2_denicola_2021.jl`

**Step 1: Write the failing test**

Add tests covering:

- TSV headers for all expected columns
- output-path planning for the two TSVs and two figure files
- plot builders returning non-empty `Plots.Plot` objects for the main `3 x 2` figure and the XXZ audit figure

Expected column set:

```julia
expected = Set([
    "time", "rate", "mx",
    "s1", "s2", "s3", "s4",
    "lambda1", "lambda2", "lambda3", "lambda4",
    "o11", "ood",
    "tf1_re", "tf1_im", "tf1_abs",
    "tf2_re", "tf2_im", "tf2_abs",
    "I12", "I13", "I12_3", "I12_4",
])
```

**Step 2: Run test to verify it fails**

Run: `julia test/test_dqpt_fig2_denicola_2021.jl`
Expected: FAIL because save/load/path/plot helpers do not yet exist.

**Step 3: Write minimal implementation**

Implement:

- `planned_fig2_output_paths`
- `save_fig2_result`
- `load_fig2_table`
- `build_fig2_plot`
- `build_fig2_audit_plot`
- `scripts/plot_dqpt_fig2_denicola_2021.jl`

Keep the main figure faithful to the paper:

- top row: rate with entanglement inset
- middle row: `⟨σx⟩`
- bottom row: four MI curves

Keep the audit figure focused on the p/e mechanism checks:

- entanglement weights
- overlap diagnostics
- optional transfer-eigenvalue magnitudes if they aid debugging

**Step 4: Run test to verify it passes**

Run: `julia test/test_dqpt_fig2_denicola_2021.jl`
Expected: PASS.

**Step 5: Commit**

```bash
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 add src/DQPTFig2DeNicola2021.jl scripts/plot_dqpt_fig2_denicola_2021.jl test/test_dqpt_fig2_denicola_2021.jl
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 commit -m "feat: add denicola 2021 fig2 outputs and plots"
```

### Task 6: Write the Fig. 2 analysis note and audit checklist

**Files:**
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/docs/notes/2026-03-14-dqpt-fig2-denicola-2021-analysis.md`

**Step 1: Write the failing check**

Create a manual checklist that the note must answer:

- which XXZ quenches were run
- how the entanglement-spectrum inset was computed
- how the four MI curves were defined
- whether `pDQPT` shows a gapped entanglement spectrum and a minimum in `|o11|`
- whether `eDQPT` shows an avoided crossing and a broad `I_{1,2;3}` maximum
- whether the reproduction is qualitative or quantitative relative to the paper

**Step 2: Run the check to verify it fails**

Expected: FAIL because the note does not yet exist.

**Step 3: Write minimal implementation**

Write the note only after the full datasets and plots exist so the text can cite real times, amplitudes, and mismatches.

**Step 4: Run the check to verify it passes**

Re-read the checklist against the note.
Expected: PASS.

**Step 5: Commit**

```bash
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 add docs/notes/2026-03-14-dqpt-fig2-denicola-2021-analysis.md
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 commit -m "docs: add denicola 2021 fig2 analysis note"
```

### Task 7: Run end-to-end verification and reproduction

**Files:**
- Verify only

**Step 1: Run focused tests**

Run: `julia test/test_denicola2021_canonical.jl`
Expected: PASS.

**Step 2: Run Fig. 2 tests**

Run: `julia test/test_dqpt_fig2_denicola_2021.jl`
Expected: PASS.

**Step 3: Run full test suite**

Run: `julia test/runtests.jl`
Expected: PASS.

**Step 4: Reproduce the pDQPT XXZ dataset**

Run: `julia scripts/reproduce_dqpt_fig2_denicola_2021.jl pdqpt`
Expected: `outputs/fig2_pdqpt_denicola_2021.tsv` created with finite rate, entanglement, overlap, transfer, and MI columns.

**Step 5: Reproduce the eDQPT XXZ dataset**

Run: `julia scripts/reproduce_dqpt_fig2_denicola_2021.jl edqpt`
Expected: `outputs/fig2_edqpt_denicola_2021.tsv` created with the same schema.

**Step 6: Render the figure bundle**

Run: `julia scripts/plot_dqpt_fig2_denicola_2021.jl`
Expected:

- `figures/report/dqpt_fig2_denicola_2021.png`
- `figures/report/dqpt_fig2_xxz_audit_denicola_2021.png`

**Step 7: Validate the paper claims against the generated outputs**

Check the datasets, figures, and note using `@verification-before-completion`:

- `pDQPT`: cusp-like rate, gapped leading entanglement spectrum, minimum in `|o11|`, magnetization near sign inversion, slow near-monotonic MI
- `eDQPT`: cusp near leading-level avoided crossing, `⟨σx⟩` near a magnitude minimum, oscillatory MI, broad `I12_3` maximum

If any of these fail, update the note to state the mismatch instead of claiming success.

**Step 8: Commit**

```bash
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 add src/DeNicola2021Canonical.jl src/DQPTFig2DeNicola2021.jl scripts/reproduce_dqpt_fig2_denicola_2021.jl scripts/plot_dqpt_fig2_denicola_2021.jl test/test_denicola2021_canonical.jl test/test_dqpt_fig2_denicola_2021.jl test/runtests.jl docs/notes/2026-03-14-dqpt-fig2-denicola-2021-analysis.md outputs/fig2_pdqpt_denicola_2021.tsv outputs/fig2_edqpt_denicola_2021.tsv figures/report/dqpt_fig2_denicola_2021.png figures/report/dqpt_fig2_xxz_audit_denicola_2021.png
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 commit -m "feat: reproduce denicola 2021 fig2"
```
