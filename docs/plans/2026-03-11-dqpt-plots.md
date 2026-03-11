# DQPT Plotting Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a Julia plotting script that generates both analysis and report figures from the existing DQPT TSV outputs.

**Architecture:** Put parsing and figure composition in a small source module and keep the CLI in `scripts/plot_results.jl`. Reuse a single data-loading layer for both figure styles.

**Tech Stack:** Julia, Plots.jl, DelimitedFiles, Test

---

### Task 1: Add failing tests for plotting helpers

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/test/test_helpers.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/src/DQPTPlots.jl`

**Step 1: Write the failing test**

Add tests for:

- TSV loading returns named columns
- output path planning returns the expected filenames for `analysis`, `report`, and `all`

**Step 2: Run test to verify it fails**

Run: `julia test/runtests.jl`
Expected: FAIL because plotting helpers do not yet exist.

**Step 3: Write minimal implementation**

Implement:

- TSV reader
- simple style parser
- output path planner

**Step 4: Run test to verify it passes**

Run: `julia test/runtests.jl`
Expected: PASS.

**Step 5: Commit**

This workspace is not a git repository. Skip commit.

### Task 2: Implement plotting script and figure generation

**Files:**
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/scripts/plot_results.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/src/DQPTPlots.jl`

**Step 1: Write the failing test**

Add a small test that planned output filenames include:

- `figures/analysis/ising_diagnostics.png`
- `figures/analysis/xxz_diagnostics.png`
- `figures/analysis/comparison_overview.png`
- `figures/report/dqpt_qualitative_comparison.png`

**Step 2: Run test to verify it fails**

Run: `julia test/runtests.jl`
Expected: FAIL because the figure planning logic is incomplete.

**Step 3: Write minimal implementation**

Implement:

- analysis figure builders
- report figure builder
- save logic
- CLI wiring

**Step 4: Run test to verify it passes**

Run: `julia test/runtests.jl`
Expected: PASS.

**Step 5: Commit**

This workspace is not a git repository. Skip commit.

### Task 3: Document and verify

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/README.md`

**Step 1: Update documentation**

Add:

- plotting command examples
- generated figure locations

**Step 2: Run tests**

Run: `julia test/runtests.jl`
Expected: PASS.

**Step 3: Generate all figures**

Run: `julia scripts/plot_results.jl --style all`
Expected: all PNG files created.

**Step 4: Inspect output**

Check that the generated files exist and visually inspect one analysis and one report figure.

**Step 5: Commit**

This workspace is not a git repository. Skip commit.
