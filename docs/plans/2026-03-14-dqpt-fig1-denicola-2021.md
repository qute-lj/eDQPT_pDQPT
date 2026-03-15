# DQPT Fig. 1 De Nicola 2021 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build and verify a paper-oriented Julia/MPSKit workflow that numerically reproduces Fig. 1 of De Nicola et al. (2021) by analyzing the canonical iMPS, the fidelity transfer matrix, the leading entanglement-spectrum values, and the overlap matrix `o`.

**Architecture:** Keep the implementation separate from the existing proxy workflow by introducing a dedicated Fig. 1 module, a dedicated CLI, and a dedicated plotting script. The evolution layer will generate time-evolved iMPS states for the two paper quenches, while the analysis layer will extract canonical-form objects and compute `T_f`, its leading eigenvalues, and the key overlap-matrix entries.

**Tech Stack:** Julia, MPSKit, MPSKitModels, TensorKit, KrylovKit/LinearAlgebra through MPSKit internals, Test, DelimitedFiles, Plots.

---

### Task 1: Add failing tests for Fig. 1 helper contracts

**Files:**
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_dqpt_fig1_denicola_2021.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/runtests.jl`
- Test: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_dqpt_fig1_denicola_2021.jl`

**Step 1: Write the failing test**

Add tests for pure contracts that the current repo does not implement:

- parsing a new Fig. 1 CLI mode/preset
- building the two paper initial states (`|↓⟩`, `|→⟩`)
- normalizing the paper parameter tuple for `pDQPT` and `eDQPT`

**Step 2: Run test to verify it fails**

Run: `julia test/test_dqpt_fig1_denicola_2021.jl`
Expected: FAIL because the Fig. 1 module and helpers do not yet exist.

**Step 3: Write minimal implementation**

Create `src/DQPTFig1DeNicola2021.jl` with:

- paper parameter presets
- initial-state constructors
- a minimal CLI parser contract

**Step 4: Run test to verify it passes**

Run: `julia test/test_dqpt_fig1_denicola_2021.jl`
Expected: PASS for the helper-level tests.

**Step 5: Commit**

```bash
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 add test/runtests.jl test/test_dqpt_fig1_denicola_2021.jl src/DQPTFig1DeNicola2021.jl
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 commit -m "test: scaffold denicola 2021 fig1 helpers"
```

### Task 2: Add failing tests for fidelity-transfer diagnostics

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_dqpt_fig1_denicola_2021.jl`
- Test: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_dqpt_fig1_denicola_2021.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/src/DQPTFig1DeNicola2021.jl`

**Step 1: Write the failing test**

Add tests for diagnostic functions operating on controlled small inputs:

- extracting leading Schmidt values from a canonical bond object
- computing the key overlap entries `o11` and `ood`
- building a fidelity transfer matrix and returning its leading two eigenvalues

Use minimal hand-built canonical toy data where possible so the tests validate math, not long evolution.

**Step 2: Run test to verify it fails**

Run: `julia test/test_dqpt_fig1_denicola_2021.jl`
Expected: FAIL because the transfer-diagnostic functions do not yet exist.

**Step 3: Write minimal implementation**

Implement:

- canonical diagnostic helpers
- overlap-matrix helper(s)
- fidelity transfer matrix constructor and leading-eigenvalue extractor

**Step 4: Run test to verify it passes**

Run: `julia test/test_dqpt_fig1_denicola_2021.jl`
Expected: PASS for the new diagnostic tests.

**Step 5: Commit**

```bash
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 add test/test_dqpt_fig1_denicola_2021.jl src/DQPTFig1DeNicola2021.jl
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 commit -m "feat: add fig1 fidelity-transfer diagnostics"
```

### Task 3: Add failing smoke tests for the two paper quenches

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_dqpt_fig1_denicola_2021.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/src/DQPTFig1DeNicola2021.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/scripts/reproduce_dqpt_fig1_denicola_2021.jl`

**Step 1: Write the failing test**

Add short-run tests for `pDQPT` and `eDQPT` examples that verify:

- rate and analysis arrays have matching lengths
- the output contains finite values for `rate`, leading Schmidt values, `|o11|`, `|ood|`, and the leading `T_f` eigenvalue magnitudes
- the result object records which paper preset was used

**Step 2: Run test to verify it fails**

Run: `julia test/test_dqpt_fig1_denicola_2021.jl`
Expected: FAIL because the evolution driver is not yet implemented.

**Step 3: Write minimal implementation**

Implement:

- paper-Ising Hamiltonian builder
- iMPS evolution driver for the two Fig. 1 presets
- result struct / named tuple carrying both state and transfer diagnostics
- minimal CLI entrypoint

**Step 4: Run test to verify it passes**

Run: `julia test/test_dqpt_fig1_denicola_2021.jl`
Expected: PASS for the smoke runs.

**Step 5: Commit**

```bash
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 add test/test_dqpt_fig1_denicola_2021.jl src/DQPTFig1DeNicola2021.jl scripts/reproduce_dqpt_fig1_denicola_2021.jl
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 commit -m "feat: add denicola 2021 fig1 evolution driver"
```

### Task 4: Add failing tests for output schema and plotting

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/test/test_dqpt_fig1_denicola_2021.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/scripts/plot_dqpt_fig1_denicola_2021.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/src/DQPTFig1DeNicola2021.jl`

**Step 1: Write the failing test**

Add tests that verify:

- TSV headers include the new transfer-diagnostic columns
- plotting helper returns the expected output paths
- plot bundle creation works for a small saved dataset

**Step 2: Run test to verify it fails**

Run: `julia test/test_dqpt_fig1_denicola_2021.jl`
Expected: FAIL because save/plot helpers are incomplete.

**Step 3: Write minimal implementation**

Implement:

- TSV save helpers
- plotting helper(s) for the Fig. 1(d) and Fig. 1(e) solid-line figures
- path planning for figure output

**Step 4: Run test to verify it passes**

Run: `julia test/test_dqpt_fig1_denicola_2021.jl`
Expected: PASS.

**Step 5: Commit**

```bash
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 add test/test_dqpt_fig1_denicola_2021.jl src/DQPTFig1DeNicola2021.jl scripts/plot_dqpt_fig1_denicola_2021.jl
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 commit -m "feat: add denicola 2021 fig1 outputs and plots"
```

### Task 5: Write the analysis note

**Files:**
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021/docs/notes/2026-03-14-dqpt-fig1-denicola-2021-analysis.md`

**Step 1: Write the failing check**

Create a manual checklist that the note must answer:

- what canonical objects were used
- how `T_f` was built numerically
- how `|e1|, |e2|`, `λ1, λ2`, and `o` are related in the implementation
- what distinguishes the `pDQPT` and `eDQPT` runs

**Step 2: Run the check to verify it fails**

Expected: FAIL because the note does not yet exist.

**Step 3: Write minimal implementation**

Write the note only after the data and plots exist so the text reflects the actual numerical outputs.

**Step 4: Run the check to verify it passes**

Re-read the checklist against the note.
Expected: PASS.

**Step 5: Commit**

```bash
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 add docs/notes/2026-03-14-dqpt-fig1-denicola-2021-analysis.md
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 commit -m "docs: add denicola 2021 fig1 analysis note"
```

### Task 6: Run end-to-end verification

**Files:**
- Verify only

**Step 1: Run targeted tests**

Run: `julia test/test_dqpt_fig1_denicola_2021.jl`
Expected: PASS.

**Step 2: Run full test suite**

Run: `julia test/runtests.jl`
Expected: PASS.

**Step 3: Run `pDQPT` reproduction**

Run: `julia scripts/reproduce_dqpt_fig1_denicola_2021.jl pdqpt`
Expected: `outputs/fig1_pdqpt_denicola_2021.tsv` created with finite transfer-diagnostic columns.

**Step 4: Run `eDQPT` reproduction**

Run: `julia scripts/reproduce_dqpt_fig1_denicola_2021.jl edqpt`
Expected: `outputs/fig1_edqpt_denicola_2021.tsv` created with finite transfer-diagnostic columns.

**Step 5: Render plots**

Run: `julia scripts/plot_dqpt_fig1_denicola_2021.jl`
Expected: figure files for both `pDQPT` and `eDQPT` are created.

**Step 6: Validate the claimed mechanism split**

Check the generated outputs and note:

- `pDQPT` shows separated leading Schmidt values near the DQPT and overlap-driven transfer-eigenvalue change
- `eDQPT` shows a near avoided crossing in the leading Schmidt values and transfer-eigenvalue rearrangement consistent with that

**Step 7: Commit**

```bash
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 add src/DQPTFig1DeNicola2021.jl scripts/reproduce_dqpt_fig1_denicola_2021.jl scripts/plot_dqpt_fig1_denicola_2021.jl test/test_dqpt_fig1_denicola_2021.jl docs/notes/2026-03-14-dqpt-fig1-denicola-2021-analysis.md outputs/fig1_pdqpt_denicola_2021.tsv outputs/fig1_edqpt_denicola_2021.tsv figures/report/dqpt_fig1_pdqpt_denicola_2021.png figures/report/dqpt_fig1_edqpt_denicola_2021.png
git -C /home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021 commit -m "feat: reproduce denicola 2021 fig1"
```
