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

## Notes

- These runs are qualitative reproductions intended to mirror the paper's physical distinction between precession-dominated and entanglement-dominated behavior.
- Exact figure-by-figure agreement may require parameter tuning against the full paper supplement.
