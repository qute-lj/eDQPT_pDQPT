# 2026-03-11 Osborne Long-Range Window Report

## Scope

This note summarizes the strongest current local reproduction signal for the Osborne,
McCulloch, and Halimeh (2025) Ising-side confinement story in the `:longrange` backend.

The main question is whether nearby confinement settings can be separated into:

- a `manifold`-like dominant DQPT peak, where the local order parameter changes sign in the
  peak window
- a `branch`-like dominant DQPT peak, where the order parameter does not change sign in the
  peak window

## Current candidate windows

All rows below use:

- backend: `longrange`
- `J = 1.0`
- `g = 1.05`
- `alpha = 3.0`

For `L = 6/8/10`, the best current pair is still the original:

- `bond_dim = 8`
- `dt = 0.1`
- `steps = 40`

For `L = 12`, the best current pair now comes from a tighter rerun:

- `bond_dim = 16`
- `dt = 0.05`
- `steps = 80`

| Length | Manifold candidate | Branch candidate | Manifold peak time | Branch peak time |
| --- | --- | --- | --- | --- |
| `6` | `hz = 0.52` | `hz = 0.58` | `2.2` | `2.1` |
| `8` | `hz = 0.48` | `hz = 0.52` | `2.2` | `2.1` |
| `10` | `hz = 0.46` | `hz = 0.48` | `2.2` | `2.1` |
| `12` | `hz = 0.44` | `hz = 0.45` | `2.15` | `2.15` |

The corresponding compare summaries are:

- `outputs/osborne_longrange_candidate_longrange_summary.md`
- `outputs/osborne_longrange_L8_candidate_longrange_summary.md`
- `outputs/osborne_longrange_L10_candidate_longrange_summary.md`
- `outputs/osborne_longrange_L12_refine_right_bd16_longrange_summary.md`

These compare summaries now all include:

- `max_entropy`
- `energy_drift`
- `max_allocated_bond`

## Compact figure

The current compact figure for these four compare points is:

- `figures/report/osborne_longrange_window.png`

It is generated locally with:

- `julia scripts/plot_osborne_results.jl`

## Stability checks

### Time-step checks

- At `L = 6`, the pair `hz = 0.52` versus `0.58` keeps the `manifold` versus `branch`
  separation when rerun with `dt = 0.05` and `steps = 80`.
- At `L = 10`, the pair `hz = 0.46` versus `0.48` also keeps the same separation when
  rerun with `dt = 0.05` and `steps = 80`.
- At `L = 12`, the original coarse pair `hz = 0.40` versus `0.42` does not survive as
  `branch` versus `manifold` under `dt = 0.05`; both points become `branch`.
- A narrow refined `L = 12` scan then finds the surviving local pair at `hz = 0.44`
  versus `0.45`, which restores the `manifold` versus `branch` separation.

### Bond-dimension and energy-drift spot check

For the `L = 6` long-range pair:

- `bond_dim = 8` and `bond_dim = 12` give the same qualitative classification
- measured energy drift stayed at the `1e-15` level
- allocated bond space never exceeded `8`

For the regenerated `L = 10` compare run:

- `hz = 0.46`
  - classification: `manifold`
  - energy drift: `1.0658141036401503e-14`
  - max allocated bond: `8`
- `hz = 0.48`
  - classification: `branch`
  - energy drift: `9.769962616701378e-15`
  - max allocated bond: `8`

For the refined `L = 12` compare run:

- `hz = 0.44`
  - classification: `manifold`
  - energy drift: `1.509903313490213e-14`
  - max allocated bond: `16`
- `hz = 0.45`
  - classification: `branch`
  - energy drift: `1.865174681370263e-14`
  - max allocated bond: `16`

Compared with the earlier `bond_dim = 12` refined pair, the peak times and peak rates move
only at the `1e-6` to `1e-3` level, so the current `L = 12` `branch/manifold` split no
longer looks like a bond-cap artifact.

## Interpretation

The present finite-chain evidence supports a qualitative Osborne 2025-style story in the
long-range Ising channel:

- there is a narrow confinement window where the dominant DQPT peak aligns with an
  order-parameter sign change
- nearby confinement settings remain `branch`-like

The important numerical caveat is that the candidate window drifts with chain length:

- toward smaller `hz` as `L` increases from `6` to `12`
- without destroying the qualitative `branch/manifold` separation
- but the `L = 12` point is visibly more sampling-sensitive than `L = 6` and `L = 10`

So the cleanest current interpretation is:

- the local code now reproduces a finite-size-shifting confinement crossover
- it does not yet pin down a chain-length-independent threshold
- the `L = 12` window survives only as a narrower refined band near `hz ≈ 0.44`

## Recommended next move

The compact figure now exists, so the highest-value next step is:

1. decide whether the current finite-size crossover evidence is already sufficient for the local reproduction claim
2. if a stronger claim is needed, add one last narrow scan around the refined `L = 12` band near `hz ≈ 0.44`
3. otherwise package the current summaries and figure as the Osborne 2025 local reproduction bundle
