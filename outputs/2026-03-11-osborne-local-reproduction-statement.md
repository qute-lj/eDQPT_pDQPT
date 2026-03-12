# 2026-03-11 Osborne Local Reproduction Statement

This repository now supports a local qualitative reproduction of the Ising-side confinement
story targeted from Osborne, McCulloch, and Halimeh (2025), but only in the restricted
finite-chain `longrange` Path A setting implemented here. The present claim is not that the
full paper has been reproduced figure by figure. The present claim is narrower: the local
workflow now resolves a branch-like versus manifold-like dominant DQPT peak separation in a
confinement-tuned long-range Ising channel, and that separation persists across several small
chain lengths after basic time-step and bond-dimension checks.

The strongest current evidence comes from four finite-chain windows at fixed `J = 1.0`,
`g = 1.05`, and `alpha = 3.0`. At `L = 6`, the pair `hz = 0.52` versus `0.58` separates into
`manifold` and `branch`. At `L = 8`, the analogous pair is `0.48` versus `0.52`. At `L = 10`,
the analogous pair is `0.46` versus `0.48`. At `L = 12`, the original coarse candidate
`0.40` versus `0.42` did not survive a finer rerun, but a refined scan recovered a narrower
pair at `0.44` versus `0.45`, and that refined pair remained `manifold` versus `branch` when
repeated at `bond_dim = 16`. The compact summary figure collecting these four windows is
stored in `figures/report/osborne_longrange_window.png`.

The cleanest interpretation of the local data is therefore a finite-size-shifting confinement
crossover rather than a chain-length-independent threshold. As the chain length grows from
`L = 6` to `L = 12`, the candidate manifold window moves toward smaller `hz`, but the
`L = 12` point is also more sampling-sensitive than the shorter-chain cases. That is why the
most defensible wording is that the code reproduces the qualitative Osborne 2025 mechanism
story in a small-system finite-chain sense, not that it has already pinned down the paper's
final threshold structure.

The numerical diagnostics are good enough for that narrower claim. The compare summaries now
record peak data, maximum entropy, absolute energy drift, and maximum allocated bond. The
stable candidate points show energy drift at roughly the `1e-14` to `1e-15` level. The refined
`L = 12` pair keeps the same qualitative classification between `bond_dim = 12` and
`bond_dim = 16`, which weakens the concern that the surviving manifold point is a pure
truncation artifact. The corresponding strongest-evidence summary file is
`outputs/osborne_longrange_L12_refine_right_bd16_longrange_summary.md`.

What is not yet reproduced is equally important. This work does not yet claim the full
Osborne, McCulloch, and Halimeh (2025) paper, does not yet cover any non-Ising sector, does
not yet establish a thermodynamic-limit threshold, and does not yet provide a broad systematic
convergence study in chain length, time step, and bond dimension. The current fallback
`proxy` backend remains useful for smoke tests, but the main physical evidence now comes from
the `longrange` backend alone.

With those limits stated explicitly, the present local status is best summarized as follows:
the Ising-side confinement story has been qualitatively reproduced in the implemented Path A
workflow, the main branch/manifold separation is visible and numerically supported on
`L = 6, 8, 10, 12`, and the remaining gap is no longer whether the effect exists locally, but
whether one wants to invest in a larger-scale convergence campaign before calling the broader
paper reproduction complete.
