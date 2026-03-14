# Output Files

The reproduction script writes tab-separated files into this folder.

## Ising baseline

File pattern: `*_ising.tsv`

Columns:

- `time`: real-time point
- `rate`: infinite-chain Loschmidt rate density proxy
- `entropy`: mean entanglement entropy over the unit cell
- `mx`: unit-cell-averaged `sigma_x`
- `mz`: unit-cell-averaged `sigma_z`

## XXZ N\'eel protocol

File pattern: `*_xxz.tsv`

Columns:

- `time`: real-time point
- `rate`: infinite-chain Loschmidt rate density proxy
- `entropy`: mean entanglement entropy over the two-site unit cell
- `mz1`: `sigma_z` on site 1 of the unit cell
- `mz2`: `sigma_z` on site 2 of the unit cell
- `staggered_mz`: `0.5 * (mz1 - mz2)`

## Osborne 2025 finite-chain workflow

This workflow targets the Ising-side confinement story of Osborne, McCulloch, and Halimeh
(2025).

Backend intent:

- `longrange`: main Path A backend, meant to approximate the paper's confining Ising-side route
- `proxy`: fallback backend, currently the practical smoke-tested path

### Single-run Osborne output

File pattern: `*_<backend>.tsv`

Typical examples:

- `osborne_smoke_proxy.tsv`
- `osborne_proxy_smoke_proxy.tsv`

Columns:

- `time`: finite-chain real-time point
- `rate`: finite-chain Loschmidt return rate
- `entropy`: mean bipartite entanglement entropy across all internal cuts
- `mz`: mean on-site `sigma_z`

### Compare-mode Osborne outputs

File patterns:

- `*_low_<backend>.tsv`
- `*_high_<backend>.tsv`
- `*_<backend>_summary.md`

The two TSV files store the lower- and higher-confinement runs used in compare mode.

The summary markdown file records:

- peak time
- peak rate
- peak-time `mz`
- conservative `branch` versus `manifold` classification
- maximum entropy reached during the run
- maximum absolute energy drift relative to the initial time
- maximum allocated bond dimension encountered in the run

### Long-range candidate reports

Representative long-range window scans and report notes are also stored here as markdown,
for example:

- `2026-03-11-osborne-scan-summary.md`
- `2026-03-11-osborne-longrange-window-report.md`

The paired compact figure is written outside this folder at:

- `../figures/report/osborne_longrange_window.png`

## PRL 2021 ESQPT proxy workflow

This workflow does not define `ESQPT` through `eDQPT` signatures. Instead it uses finite-size
spectral diagnostics:

- local density-of-states proxy from level spacings
- energy-resolved observables
- inverse participation ratio (`IPR`)

### ESQPT scan outputs

File patterns:

- `*_esqpt_spectrum.tsv`
- `*_esqpt_summary.md`

The TSV file stores:

- `energy`
- `density_proxy`
- one model-dependent observable column
- `ipr`

The markdown summary records:

- the explicit method statement
- the finite-size model and boundary condition
- candidate energies from density proxy
- candidate energies from observable curvature
- candidate energies from `IPR`

Interpretation rule:

- treat these files as finite-size `ESQPT` proxy scans
- do not interpret them as direct proof that `eDQPT == ESQPT`

### Quench-projection outputs

File patterns:

- `*_projection.tsv`
- `*_projection_summary.md`

These files answer a different question from the plain spectrum scan:

- where does the initial quench state place its spectral weight
- how much of that weight sits in the immediate neighborhood of each ESQPT candidate energy

### Stability-scan outputs

File patterns:

- `*_stability.tsv`
- `*_stability_summary.md`

These files test whether the candidate energies per site drift strongly or remain comparatively stable as:

- chain length changes
- boundary condition changes

### DQPT-ESQPT comparison outputs

File patterns:

- `*_dqpt.tsv`
- `*_comparison_summary.md`

These files combine the two earlier analyses:

- finite-size DQPT rate peaks in time
- spectral overlap with the ESQPT proxy neighborhood

## Notes

- These runs are qualitative reproductions intended to mirror the paper's physical distinction between precession-dominated and entanglement-dominated behavior.
- Exact figure-by-figure agreement may require parameter tuning against the full paper supplement.
- For Osborne 2025 specifically, the current strongest local reproduction evidence now comes from a finite-size-shifting `longrange` candidate window, while `proxy` remains the practical fallback path.
