# 2026-03-11 Paper Reproduction Summary

This note records fresh runs used to map the current Julia + MPSKit workflow onto the most relevant DQPT papers that can be addressed without replacing the existing scheme.

## Commands used

```bash
julia scripts/reproduce_dqpt_prl_2021.jl ising --steps 90 --dt 0.02 --output-prefix heyl2013 --vumps-maxiter 60 --vumps-tol 1e-10 --bond-dim 16 --grow-steps 40 --grow-by 1
julia scripts/reproduce_dqpt_prl_2021.jl all --steps 40 --dt 0.05 --output-prefix denicola2021 --vumps-maxiter 40 --vumps-tol 1e-8
```

## Fresh outputs

- `outputs/heyl2013_ising.tsv`
- `outputs/denicola2021_ising.tsv`
- `outputs/denicola2021_xxz.tsv`

## Key observations

### `Heyl et al. 2013` target: TFIM DQPT baseline

- strongest early-time Ising peak: `t = 1.16`
- peak rate: `0.69994803785952`
- entropy at the peak: `0.47427583153319003`
- magnetization at the peak: `mz = 0.5062107618817365`, `mx = -0.42820876783004574`

Interpretation:

- This is the cleanest direct reproduction target for the current scheme.
- The peak location remains close to the standard TFIM DQPT estimate `t* ≈ 1.175`.
- The cusp appears while the local order is still substantial, matching the usual TFIM DQPT story.

### `De Nicola et al. 2021` target: `pDQPT/eDQPT` qualitative split

#### Ising channel

- strongest rate peak: `t = 1.25`
- peak rate: `0.5864988009379188`
- entropy at the peak: `0.5083566992137879`
- magnetization at the peak: `mz = 0.44268671786030805`, `mx = -0.4330920914355116`

#### XXZ N\'eel channel

- strongest rate peak: `t = 1.55`
- peak rate: `0.6744005679096906`
- entropy at the peak: `0.8195738654276417`
- staggered magnetization at the peak: `-0.051088924577724744`
- final-time entropy at `t = 2.0`: `1.0697639807559352`
- final-time staggered magnetization at `t = 2.0`: `-0.10237662057484101`

Interpretation:

- The XXZ channel reaches a comparable or stronger rate peak only after noticeably larger entanglement growth.
- The staggered order is already close to zero near the XXZ peak, while the Ising channel still retains appreciable local order near its own peak.
- That is the qualitative pattern the repo is using as a local proxy for the `pDQPT/eDQPT` split.

## What is covered now

- `Heyl et al. 2013`: directly covered by the refined Ising run
- `De Nicola et al. 2021`: directly covered qualitatively by the Ising-versus-XXZ comparison
- `Heyl 2015`: only partially covered so far

## What is not covered yet

- `Heyl 2015` still needs scaling-oriented diagnostics if we want more than a cusp-location check.
- `Halimeh et al. 2020` likely needs broader model support or additional sweeps.
- `Van Damme et al. 2023` likely needs extra observables or different models.
- `Jurcevic et al. 2017` would need a platform-specific finite-size trapped-ion-style setup for a tighter reproduction.
