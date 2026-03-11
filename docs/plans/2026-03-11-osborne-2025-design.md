# Osborne 2025 Reproduction Design

**Target paper:** Jesse J. Osborne, Ian P. McCulloch, Jad C. Halimeh, *Probing confinement through dynamical quantum phase transitions: From quantum spin models to lattice gauge theories*, Phys. Rev. Research 7, 043076 (2025)

**Primary question:** How should this repository reproduce the post-2021 mechanism story in a way that is physically meaningful and still compatible with the current Julia + MPSKit codebase?

## Design summary

The first reproduction target should be the **Ising-side confinement story** from Osborne et al. (2025), not the full paper.

Reason:

- it stays closest to the current repo's Ising-based workflow
- it is already aligned with MPS-friendly Hamiltonians and observables
- it addresses the mechanism shift from simple order-parameter/precession language toward `branch` versus `manifold` DQPTs

The design is therefore intentionally staged:

1. build a new Ising-like confinement-focused channel in the current repo
2. reproduce the qualitative distinction between `manifold` and `branch` DQPT behavior
3. only after that consider the paper's two-dimensional Ising or `U(1)` quantum link extensions

## Three implementation paths

### Path A: finite long-range Ising-chain reproduction

This path aims at the paper's most natural MPS entry point.

#### Core idea

- work with a finite chain rather than the current infinite-chain baseline
- construct a power-law or otherwise effectively confining Ising Hamiltonian as an MPO
- evolve with `TDVP2` or with a time-evolution MPO workflow
- track Loschmidt rate, entanglement, and order-parameter behavior across a confining-parameter sweep

#### Benefits

- best physical fidelity to the Ising side of the paper
- strongest connection to the paper's mechanism claim
- no immediate need for two-dimensional geometry or gauge constraints

#### Costs

- requires a new long-range/custom MPO Hamiltonian path
- requires a finite-size Loschmidt workflow rather than the current iMPS overlap-density proxy
- will need careful runtime management because long-range finite-chain evolution is more expensive

#### Fit to current repo

- medium-to-high

This is the recommended path.

### Path B: proxy confinement in a nearest-neighbor Ising-like model

This path is a pragmatic fallback.

#### Core idea

- start from a nearest-neighbor Ising chain
- add a longitudinal field or domain-wall-confining term as a proxy
- search for qualitative `order-parameter sign change` versus `no sign change` DQPT behavior

#### Benefits

- fastest path to a first result
- maximally reuses existing code patterns

#### Costs

- lower paper fidelity
- weaker claim if the resulting DQPT distinction is only phenomenological

#### Fit to current repo

- high

This is the fallback path if long-range MPO construction proves unstable.

### Path C: direct `U(1)` quantum link model entry

This path is high fidelity to the paper's broader scope but is not a good first move.

#### Core idea

- build a spin-`S` `U(1)` quantum link Hamiltonian
- reproduce the confinement-driven shift in DQPT type directly in the gauge-theory language

#### Benefits

- highest conceptual fidelity to the paper's full narrative

#### Costs

- largest modeling jump from the current repo
- likely requires a fresh state-construction and observable layer
- not a sensible first extension before the Ising-side channel exists

#### Fit to current repo

- low

This path should be deferred.

## Recommended design

Use **Path A** with **Path B** kept as a fallback if the exact long-range MPO route becomes too heavy.

More concretely:

- **stage 1:** build a finite-chain quench driver for custom Ising MPOs
- **stage 2:** implement one confinement-tuning parameter and one small parameter sweep
- **stage 3:** identify whether the strongest DQPT events occur with or without an order-parameter sign change
- **stage 4:** summarize the observed behavior using the paper's `branch/manifold` language, but only when the data really supports it

## Proposed numerical architecture

### Geometry

- finite spin-1/2 chain
- start with moderate lengths that keep sweeps and repeated quenches practical
- do not start with the two-dimensional or gauge-theory variants

### Hamiltonian path

- prefer a custom MPO construction using MPSKit's `FiniteMPOHamiltonian` or related operator-building path
- use the local MPSKit operator machinery because the docs explicitly note support for exponentially decaying interactions and approximations to power-law interactions
- if the exact long-range construction becomes too costly, temporarily fall back to a proxy confinement Hamiltonian

### Initial states

- start from low-entanglement product states or simple symmetry-broken reference states
- avoid overcomplicated initialization in the first pass
- if numerical fragility appears, perturb lightly or expand bonds early rather than baking in a large initial bond dimension

### Time evolution

- default to finite-chain `TDVP2` because bond growth and truncation control will matter
- keep a TEBD-style MPO evolution path as a secondary option if runtime becomes an issue
- measure at every or every few timesteps, depending on runtime

### Diagnostics

Record at minimum:

- time-resolved Loschmidt return rate
- entanglement entropy
- order parameter and whether it crosses zero
- allocated bond dimensions
- energy drift, if the Hamiltonian is static during real-time evolution

Optional second-pass diagnostics:

- connected correlators
- domain-wall density or a confinement-sensitive proxy observable
- finite-size comparison across two or three lengths

## Success criteria

The first design pass is successful if it can show a **qualitative separation** between two DQPT regimes:

- one regime where a dominant DQPT event comes with an order-parameter sign change
- one regime where a dominant DQPT event occurs without an order-parameter sign change

The design does **not** require:

- exact replication of the full published phase diagram
- simultaneous reproduction of the two-dimensional and gauge-theory sectors
- publication-level convergence in the first pass

## Main risks

### Risk 1: long-range MPO construction is the real bottleneck

Mitigation:

- keep Path B as an explicit fallback
- design the quench driver so the Hamiltonian backend can be swapped without rewriting diagnostics

### Risk 2: finite-size artifacts blur the branch/manifold distinction

Mitigation:

- compare at least two chain lengths once a stable workflow exists
- avoid overinterpreting one isolated cusp

### Risk 3: current observables are too close to the 2021 story

Mitigation:

- keep the final labeling conservative
- only use `branch/manifold` labels once the data cleanly distinguishes `with` versus `without` order-parameter sign change

## Verification strategy

Before any large parameter sweep:

1. verify a minimal finite-chain custom-Hamiltonian quench runs without NaN/Inf values
2. verify the Loschmidt and entropy data are nontrivial
3. verify at least one order-parameter trajectory behaves differently under a changed confinement parameter
4. only then add a small sweep and build the comparison plots

## Deliverables

The eventual implementation should produce:

- one new source module for the Osborne 2025 reproduction path
- one new script entrypoint or one extended CLI mode
- one compact output summary comparing at least two confinement regimes
- one figure or report note explaining why the observed behavior is being mapped to `branch` versus `manifold` DQPTs

## Recommendation to the next step

The next concrete step should be an implementation plan for **Path A with Path B fallback**, not direct coding yet.

That plan should:

- define the new module and script boundaries
- choose the first Hamiltonian construction attempt
- specify the minimal sweep
- specify the smallest verification commands that prove the workflow is alive
