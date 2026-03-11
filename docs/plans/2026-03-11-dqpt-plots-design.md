# DQPT Plotting Design

**Goal:** Add a local plotting workflow that turns the generated TSV files into both analysis-oriented and report-oriented figures.

## Scope

The plotting workflow will consume existing outputs:

- `outputs/refine_ising.tsv`
- `outputs/medium_xxz.tsv`

and produce:

- `figures/analysis/ising_diagnostics.png`
- `figures/analysis/xxz_diagnostics.png`
- `figures/analysis/comparison_overview.png`
- `figures/report/dqpt_qualitative_comparison.png`

## Design

Use a single Julia entrypoint, `scripts/plot_results.jl`, with a small library module under `src/` for:

- TSV parsing
- output path selection
- plot composition

The script will support:

- `--style analysis`
- `--style report`
- `--style all`

## Figure layout

### Analysis figures

These are for debugging and direct data inspection:

- `ising_diagnostics.png`: 3 panels for rate, entropy, and `mx/mz`
- `xxz_diagnostics.png`: 3 panels for rate, entropy, and `mz1/mz2/staggered_mz`
- `comparison_overview.png`: 2 panels for Ising-vs-XXZ rate and entropy

### Report figure

This is the cleaner presentation figure:

- `dqpt_qualitative_comparison.png`: 2x2 panel layout
  - Ising rate
  - Ising entropy + `mz`
  - XXZ rate
  - XXZ entropy + `staggered_mz`

## Styling

- `analysis`: denser legends, thinner lines, full diagnostic curves
- `report`: larger fonts, cleaner background, fewer curves, restrained palette

## Verification

- Add tests for TSV parsing and output path planning
- Generate all figures locally
- Verify the output files exist
- Inspect at least one analysis figure and one report figure

## Constraints

- Keep the implementation Julia-native
- Avoid introducing a separate Python plotting dependency
- This workspace is not a git repository, so documentation references should not mention commits
