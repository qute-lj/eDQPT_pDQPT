# Osborne 2025 `branch/manifold` vs De Nicola 2021 `pDQPT/eDQPT`

Chinese version:

- `docs/notes/2026-03-15-osborne-2025-branch-vs-pdqpt-edqpt-zh.md`

## Scope

This note compares two different DQPT classification languages that are easy to conflate:

- Osborne, McCulloch, Halimeh (2025): `branch DQPT` versus `manifold DQPT`
- De Nicola, Michailidis, Serbyn (2021): `pDQPT` versus `eDQPT`

The short answer is:

- they are related at the level of broad physical intuition
- they are **not** the same classification
- there is no clean one-to-one map such as `branch = pDQPT` or `manifold = eDQPT`

## One-table comparison

| Axis | Osborne 2025: `branch/manifold` | De Nicola 2021: `pDQPT/eDQPT` |
| --- | --- | --- |
| Main question | How does confinement or deconfinement change the dominant type of DQPT? | What microscopic mechanism drives a given DQPT? |
| What is being classified | The structure of nonanalyticities in the total return rate | The mechanism behind the switch in the dominant transfer-matrix contribution |
| Formal diagnostic | Crossings between return-rate branches such as `lambda_1^+`, `lambda_1^-`, `lambda_2^+`, `lambda_2^-` | Behavior of the overlap matrix together with the entanglement spectrum |
| Canonical split | `manifold` crossings versus `branch` crossings | `precession`-driven versus `entanglement`-driven DQPTs |
| Role of order parameter | Central. `manifold` DQPTs are tied to order-parameter zero crossings, while `branch` DQPTs can occur without them | Secondary. Local observables help interpretation, but the key distinction comes from overlap dynamics versus avoided crossings in the entanglement spectrum |
| Role of entanglement spectrum | Not the main classifier in the paper | Central. `pDQPT` occurs with a large entanglement gap; `eDQPT` occurs near avoided crossings of the leading singular values |
| Physical story emphasized | Confinement constrains dynamics and favors `branch` DQPTs; deconfinement favors `manifold` DQPTs | Low-entanglement semiclassical precession favors `pDQPT`; stronger entanglement restructuring favors `eDQPT` |
| Model constraint stressed by authors | They intentionally keep global symmetry unbroken so that `branch/manifold` is well defined through an initial-state manifold | No such requirement in the same sense; one prototype `pDQPT` example uses the longitudinal-field Ising model |
| Best shorthand | A classification by return-rate branch structure, used as a confinement probe | A classification by dynamical mechanism, used to distinguish semiclassical versus entanglement-driven DQPTs |
| Safe one-line relation | Related in spirit, but broader and differently organized than `pDQPT/eDQPT` | Related in spirit, but not equivalent to `branch/manifold` |

## Where they touch

There is still a real conceptual overlap.

- In Osborne 2025, `manifold DQPTs` are the ones directly tied to order-parameter sign changes.
- In De Nicola 2021, `eDQPTs` are the more strongly entanglement-reorganized events and are not captured by a simple semiclassical picture.
- Both papers therefore push beyond the naive statement that every DQPT is just an order-parameter sign change.

At a very loose level, Osborne's `branch DQPT` language plays a similar role to later post-2021 papers that emphasize DQPT structure beyond simple order-parameter zeros.

## Why they are not the same thing

### 1. They classify different objects

Osborne 2025 classifies the **return-rate crossing structure**.

De Nicola 2021 classifies the **driving mechanism** of the DQPT.

Those are not the same axis. In principle, one would need extra diagnostics to know whether a given `branch` event is more `pDQPT`-like or more `eDQPT`-like in the 2021 sense.

### 2. Osborne 2025 does not use the 2021 entanglement-spectrum criterion

The 2021 split is defined through statements like:

- large entanglement gap `=>` `pDQPT`
- avoided crossing of leading singular values `=>` `eDQPT`

Osborne 2025 does not build its classification around that criterion. Its central quantities are return-rate branches and order-parameter dynamics under confinement tuning.

### 3. The symmetry assumptions differ

Osborne 2025 explicitly says the models are chosen so that a degenerate initial-state manifold exists and `branch/manifold` is sharply distinguishable.

This matters because one of the main 2021 `pDQPT` prototypes uses an Ising model with transverse and longitudinal fields. Osborne 2025 explicitly points out that when the global symmetry is broken in that way, the `branch/manifold` distinction is no longer cleanly available.

So even the most standard `pDQPT` example does not sit naturally inside the `branch/manifold` setup.

## Practical conclusion for this repo

If this repository is trying to reproduce Osborne 2025 faithfully, then:

- the primary target language should be `branch/manifold`
- `pDQPT/eDQPT` should only be used as comparative background
- we should not label a result `pDQPT` or `eDQPT` unless we also add the 2021-style diagnostics, especially entanglement-spectrum information

The safest working rule is:

- `branch/manifold` tells us how the return-rate singularity is organized and how it tracks confinement
- `pDQPT/eDQPT` tells us what dynamical mechanism is likely driving the singularity

These two labels may eventually be compared, but they should not be identified by default.

## Implication for future reproduction work

If we want to connect the two papers more tightly, the missing bridge is not just more runs. We would need extra observables:

- entanglement-spectrum diagnostics
- overlap or transfer-matrix diagnostics in the 2021 style
- a careful check of whether a given Osborne-style `branch` or `manifold` event is also semiclassical or entanglement-driven

Until those diagnostics exist, the honest statement is:

- Osborne 2025 is adjacent to the `pDQPT/eDQPT` story
- but it is not simply a renaming of that story
