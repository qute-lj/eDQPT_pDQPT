# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- Julia plotting module `src/DQPTPlots.jl` for TSV loading, figure assembly, and output-path planning.
- Plot CLI `scripts/plot_results.jl` to generate analysis and report figures from existing DQPT outputs.
- Plotting design and implementation notes in `docs/plans/2026-03-11-dqpt-plots-design.md` and `docs/plans/2026-03-11-dqpt-plots.md`.
- Generated figure outputs under `figures/analysis/` and `figures/report/`.
- Post-2021 DQPT mechanism roadmap note covering `A/B/C` literature options and the detailed `A`-track assessment.

### Changed
- `README.md` now documents plotting commands and generated figure locations.
- `test/test_helpers.jl` now covers plotting helpers, figure-path planning, and figure-bundle construction.

## [0.1.0] - 2026-03-11

### Added
- Initial Julia + MPSKit qualitative reproduction of the 2021 PRL on `eDQPT/pDQPT`.
- Infinite-chain Ising baseline and XXZ N\'eel comparison workflow in `src/DQPTPRL2021.jl`.
- Reproduction entrypoint `scripts/reproduce_dqpt_prl_2021.jl`.
- Smoke tests for helpers, CLI parsing, Ising evolution, and XXZ evolution.
- Initial run outputs and run summary under `outputs/`.
- DQPT reading list in `dqpt_reading_list.md`.
- Design and implementation plans for the initial PRL reproduction.
