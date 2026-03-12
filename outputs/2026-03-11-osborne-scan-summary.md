# 2026-03-11 Osborne 2025 Scan Summary

## Goal

Identify small finite-chain parameter windows that already show the qualitative
`branch` versus `manifold` distinction in the local Osborne 2025 workflow.

All runs below use the current conservative classifier in `src/DQPTOsborne2025.jl`,
which labels a dominant DQPT as `manifold` only when the order parameter changes sign
within the local peak window.

## First confirmed Path A result

The current strongest local `longrange` candidate pair is:

- backend: `longrange`
- length: `6`
- steps: `40`
- dt: `0.1`
- J: `1.0`
- g: `1.05`
- alpha: `3.0`
- bond_dim: `8`

Confinement sweep:

- `hz = 0.52`
  - peak time: `2.2`
  - peak rate: `0.43013329287229607`
  - peak `mz`: `-0.0017470307389224407`
  - classification: `manifold`
- `hz = 0.58`
  - peak time: `2.1`
  - peak rate: `0.39940913077038726`
  - peak `mz`: `0.03687056157857437`
  - classification: `branch`

Generated files:

- `outputs/osborne_longrange_candidate_low_longrange.tsv`
- `outputs/osborne_longrange_candidate_high_longrange.tsv`
- `outputs/osborne_longrange_candidate_longrange_summary.md`

## Stability checks on the Path A candidate

### Smaller timestep at the original `L = 6` point

Rechecking the same `longrange` pair with `dt = 0.05` and `steps = 80` preserves the
qualitative classification:

- `hz = 0.52`
  - classification: `manifold`
  - peak time: `2.2`
  - peak rate: `0.4301332775335362`
- `hz = 0.58`
  - classification: `branch`
  - peak time: `2.1`
  - peak rate: `0.39940911723616107`

This indicates that the first `L = 6` candidate pair is not just a coarse-time-step artifact.

### Second chain length

At `L = 8`, with the same `g = 1.05`, `alpha = 3.0`, `dt = 0.1`, and `steps = 40`, the
transition window shifts toward smaller `hz`.

Representative points:

- `hz = 0.48`
  - classification: `manifold`
  - peak time: `2.2`
  - peak `mz`: `-0.0030901320340051934`
- `hz = 0.50`
  - classification: `manifold`
  - peak time: `2.2`
  - peak `mz`: `0.0066630043609040394`
- `hz = 0.52`
  - classification: `branch`
  - peak time: `2.1`
  - peak `mz`: `0.027275821897478673`

So the local long-range picture is now:

- `L = 6`: manifold window near `hz ≈ 0.52 - 0.54`
- `L = 8`: manifold window near `hz ≈ 0.48 - 0.50`

This looks like a finite-size shift rather than a complete loss of the qualitative effect.

Formal `L = 8` compare output has been written to:

- `outputs/osborne_longrange_L8_candidate_low_longrange.tsv`
- `outputs/osborne_longrange_L8_candidate_high_longrange.tsv`
- `outputs/osborne_longrange_L8_candidate_longrange_summary.md`

That compare pair uses:

- `hz = 0.48` as the `manifold` candidate
- `hz = 0.52` as the `branch` candidate

### Third chain length

At `L = 10`, still with `g = 1.05`, `alpha = 3.0`, `dt = 0.1`, and `steps = 40`, the same
trend continues and the candidate window shifts lower again.

Representative points:

- `hz = 0.44`
  - classification: `manifold`
  - peak time: `2.2`
  - peak `mz`: `-0.011414851614915797`
- `hz = 0.46`
  - classification: `manifold`
  - peak time: `2.2`
  - peak `mz`: `-0.001786593904722969`
- `hz = 0.48`
  - classification: `branch`
  - peak time: `2.1`
  - peak `mz`: `0.019978318246971764`

Formal `L = 10` compare output has been written to:

- `outputs/osborne_longrange_L10_candidate_low_longrange.tsv`
- `outputs/osborne_longrange_L10_candidate_high_longrange.tsv`
- `outputs/osborne_longrange_L10_candidate_longrange_summary.md`

That compare pair uses:

- `hz = 0.46` as the `manifold` candidate
- `hz = 0.48` as the `branch` candidate

So the current finite-size trend is:

- `L = 6`: manifold window near `hz ≈ 0.52 - 0.54`
- `L = 8`: manifold window near `hz ≈ 0.48 - 0.50`
- `L = 10`: manifold window near `hz ≈ 0.44 - 0.46`

The qualitative `branch/manifold` separation survives, but the candidate confinement window
shifts noticeably with chain length.

### Smaller timestep at `L = 10`

Rechecking the `L = 10` candidate pair with `dt = 0.05` and `steps = 80` preserves the
classification:

- `hz = 0.46`
  - classification: `manifold`
  - peak time: `2.2`
  - peak rate: `0.4060812945397442`
- `hz = 0.48`
  - classification: `branch`
  - peak time: `2.1`
  - peak rate: `0.3962658121047491`

So the `L = 10` window also survives a smaller time step.

### Fourth chain length

At `L = 12`, with the same `g = 1.05`, `alpha = 3.0`, `dt = 0.1`, and `steps = 40`, the
candidate window shifts lower again.

Representative points:

- `hz = 0.40`
  - classification: `branch`
  - peak time: `2.3`
  - peak `mz`: `-0.036329858893982055`
- `hz = 0.42`
  - classification: `manifold`
  - peak time: `2.2`
  - peak `mz`: `-0.013678258822657852`
- `hz = 0.44`
  - classification: `manifold`
  - peak time: `2.2`
  - peak `mz`: `-0.004091476344377552`

Formal `L = 12` compare output has been written to:

- `outputs/osborne_longrange_L12_candidate_low_longrange.tsv`
- `outputs/osborne_longrange_L12_candidate_high_longrange.tsv`
- `outputs/osborne_longrange_L12_candidate_longrange_summary.md`

That compare pair uses:

- `hz = 0.40` as the `branch` candidate
- `hz = 0.42` as the `manifold` candidate

However, this `L = 12` coarse-grid pair turns out not to be the final story.

At finer settings,

- `dt = 0.05`
- `steps = 80`
- `bond_dim = 12`

the regenerated `hz = 0.40` versus `0.42` compare run gives:

- `hz = 0.40`
  - classification: `branch`
  - peak time: `2.3`
  - peak `mz`: `-0.03632985983633157`
- `hz = 0.42`
  - classification: `branch`
  - peak time: `2.25`
  - peak `mz`: `-0.020078205645427352`

That refined output is stored in:

- `outputs/osborne_longrange_L12_refine_low_longrange.tsv`
- `outputs/osborne_longrange_L12_refine_high_longrange.tsv`
- `outputs/osborne_longrange_L12_refine_longrange_summary.md`

The immediate reason is that the coarse `dt = 0.1` classifier labeled `hz = 0.42` as
`manifold` because the rate peak landed on a sample whose left neighbor still had positive
`mz`, while at `dt = 0.05` the refined peak sits later and the local three-point window is
already entirely negative.

A narrow refined scan then recovers the actual `L = 12` window:

- `hz = 0.43`
  - classification: `branch`
- `hz = 0.44`
  - classification: `manifold`
  - peak time: `2.15`
  - peak `mz`: `0.0023738148015212124`
- `hz = 0.45`
  - classification: `branch`

The refined `0.44` versus `0.45` compare pair has been written to:

- `outputs/osborne_longrange_L12_refine_right_low_longrange.tsv`
- `outputs/osborne_longrange_L12_refine_right_high_longrange.tsv`
- `outputs/osborne_longrange_L12_refine_right_longrange_summary.md`

To check whether that refined pair was still controlled by the bond cap, the same run was
repeated at `bond_dim = 16`. The classification remains unchanged:

- `hz = 0.44`
  - classification: `manifold`
  - peak time: `2.15`
  - peak rate: `0.40170526050862176`
  - max allocated bond: `16`
- `hz = 0.45`
  - classification: `branch`
  - peak time: `2.15`
  - peak rate: `0.39687040280657365`
  - max allocated bond: `16`

That higher-cap run is stored in:

- `outputs/osborne_longrange_L12_refine_right_bd16_low_longrange.tsv`
- `outputs/osborne_longrange_L12_refine_right_bd16_high_longrange.tsv`
- `outputs/osborne_longrange_L12_refine_right_bd16_longrange_summary.md`

The current finite-size drift pattern is therefore:

- `L = 6`: manifold window near `hz ≈ 0.52 - 0.54`
- `L = 8`: manifold window near `hz ≈ 0.48 - 0.50`
- `L = 10`: manifold window near `hz ≈ 0.44 - 0.46`
- `L = 12`: coarse scan suggests `hz ≈ 0.42 - 0.44`, but the refined check narrows the
  surviving manifold point to about `hz ≈ 0.44`, and that refined point remains stable at
  least up to `bond_dim = 16`

## Bond-dimension and energy-drift check

For the `L = 6` `longrange` candidate pair, repeating the run at `bond_dim = 8` and
`bond_dim = 12` gives the same qualitative outcome and the same observed peak data in the
current workflow.

Representative diagnostics:

- `hz = 0.52`
  - `bond_dim = 8`: `manifold`
  - `bond_dim = 12`: `manifold`
  - energy drift: `6.217248937900877e-15`
  - max allocated bond: `8`
- `hz = 0.58`
  - `bond_dim = 8`: `branch`
  - `bond_dim = 12`: `branch`
  - energy drift: `3.1086244689504383e-15`
  - max allocated bond: `8`

At least for this small-system window, the present candidate does not appear limited by the
current bond cap.

## Proxy-side supporting scan

The current best fallback-side proxy window is:

- backend: `proxy`
- length: `6`
- steps: `40`
- dt: `0.1`
- J: `1.0`
- g: `1.05`
- bond_dim: `8`

Representative `hz` scan:

- `hz = 0.4`
  - classification: `branch`
  - peak time: `3.5`
  - peak `mz`: `-0.11145641961317065`
- `hz = 0.6`
  - classification: `manifold`
  - peak time: `2.3`
  - peak `mz`: `-0.00138722248383488`
- `hz = 0.8`
  - classification: `branch`
  - peak time: `1.8`
  - peak `mz`: `0.12508425019585637`

This suggests a narrow intermediate confinement region where the dominant peak aligns
with an order-parameter zero crossing.

## Interpretation

At the current smoke-to-medium system size, the local workflow already supports the main
qualitative paper direction:

- one confinement setting where the dominant DQPT peak is classified as `manifold`
- nearby confinement settings where the dominant DQPT peak is classified as `branch`

This is still not a paper-level reproduction. The current evidence is:

- finite-size
- small-system
- classifier-driven
- not yet fully convergence-checked in `length`, `dt`, or `bond_dim`
- energy drift and allocated bond checks are good at the current small-system candidate, but only at a very limited set of points
- the apparent confinement threshold is drifting with `L`, so finite-size extrapolation matters

## Most useful next steps

1. add energy-drift and max-bond diagnostics directly to saved run summaries
2. test one more larger bond cap on `L = 10` or `L = 12`
3. decide whether to summarize the current result as a finite-size-shifted confinement crossover rather than a fixed-parameter threshold
4. then build one compact report note or figure from the `L = 6/8/10/12` candidate windows
