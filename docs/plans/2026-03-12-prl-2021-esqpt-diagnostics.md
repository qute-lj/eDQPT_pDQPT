# PRL 2021 ESQPT Diagnostics Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a finite-size ESQPT proxy scanner for the PRL 2021 line and archive the method definition in project docs.

**Architecture:** Add dense exact-diagonalization helpers to the Julia module, expose a small CLI for finite-size scans, and emit both machine-readable TSV data and human-readable markdown summaries. Keep the ESQPT workflow separate from the existing iMPS quench evolution so the conceptual boundary remains explicit.

**Tech Stack:** Julia, LinearAlgebra, Statistics, Test, DelimitedFiles, existing project docs/output conventions.

---

### Task 1: Add failing tests for spectral helper behavior

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/esqpt-edqpt-pdqpt-survey/test/test_helpers.jl`
- Test: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/esqpt-edqpt-pdqpt-survey/test/test_helpers.jl`

**Step 1: Write the failing test**

Add tests that expect:

- a finite-size Ising Hamiltonian of length `L` has size `2^L x 2^L`
- spectral diagnostics return sorted energies
- `density_proxy` and `ipr` arrays are finite and length-matched

**Step 2: Run test to verify it fails**

Run: `julia test/runtests.jl`
Expected: FAIL because the ESQPT helper functions do not yet exist.

**Step 3: Write minimal implementation**

Implement the smallest helper surface needed by the tests:

- finite-size Pauli-operator builders
- dense Ising Hamiltonian constructor
- eigen-decomposition wrapper
- density and IPR helpers

**Step 4: Run test to verify it passes**

Run: `julia test/runtests.jl`
Expected: PASS for the new helper tests.

**Step 5: Commit**

Not requested. Skip commit.

### Task 2: Add failing tests for summary and CLI parsing

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/esqpt-edqpt-pdqpt-survey/test/test_helpers.jl`
- Test: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/esqpt-edqpt-pdqpt-survey/test/test_helpers.jl`

**Step 1: Write the failing test**

Add tests that expect:

- ESQPT CLI parsing returns the requested model, length, and output prefix
- the summary markdown includes the explicit statement that this workflow uses spectral ESQPT diagnostics rather than direct eDQPT equivalence

**Step 2: Run test to verify it fails**

Run: `julia test/runtests.jl`
Expected: FAIL because the parser and summary helpers do not yet exist.

**Step 3: Write minimal implementation**

Implement:

- ESQPT CLI parsing
- TSV writer
- markdown summary writer with the required wording

**Step 4: Run test to verify it passes**

Run: `julia test/runtests.jl`
Expected: PASS.

**Step 5: Commit**

Not requested. Skip commit.

### Task 3: Implement the end-to-end finite-size scan script

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/esqpt-edqpt-pdqpt-survey/src/DQPTPRL2021.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/esqpt-edqpt-pdqpt-survey/scripts/scan_esqpt_prl2021.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/esqpt-edqpt-pdqpt-survey/README.md`

**Step 1: Write the failing test**

Add a smoke-style test that runs the spectral scanner on a tiny chain and checks:

- an output TSV is written
- a summary markdown file is written
- the summary contains candidate-energy lines

**Step 2: Run test to verify it fails**

Run: `julia test/runtests.jl`
Expected: FAIL because no ESQPT scan entrypoint exists.

**Step 3: Write minimal implementation**

Implement:

- finite-size Ising scan path
- optional XXZ scan path via the same helper interface
- CLI entrypoint that writes output files to `outputs/`

**Step 4: Run test to verify it passes**

Run: `julia test/runtests.jl`
Expected: PASS.

**Step 5: Commit**

Not requested. Skip commit.

### Task 4: Run verification and archive a real scan

**Files:**
- Verify only

**Step 1: Run the test suite**

Run: `julia test/runtests.jl`
Expected: PASS.

**Step 2: Run a small Ising ESQPT proxy scan**

Run: `julia scripts/scan_esqpt_prl2021.jl ising --length 8 --output-prefix prl2021_esqpt_smoke`
Expected: TSV and markdown summary files appear in `outputs/`.

**Step 3: Inspect the summary wording**

Confirm the markdown explicitly states that the workflow uses finite-size spectral ESQPT diagnostics and does not equate eDQPT with ESQPT.

**Step 4: Record the result path in the final response**

Expected: final response links the archived method note, design doc, implementation plan, and generated outputs.

**Step 5: Commit**

Not requested. Skip commit.
