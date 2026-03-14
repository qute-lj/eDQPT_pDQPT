# DQPT Fig. 2 De Nicola 2021 Analysis

## Scope

This note audits the new `DQPTFig2DeNicola2021` workflow against main-text Fig. 2 of:

- Stefano De Nicola, Alexios A. Michailidis, Maksym Serbyn, *Entanglement View of Dynamical Quantum Phase Transitions*, Phys. Rev. Lett. 126, 040602 (2021)

The target figure contains two XXZ quenches from the `|→⟩^{⊗}` initial state:

- `pDQPT`: `Jx = Jy = 0.9`, `Jz = 1`, `hx = 0.1`, `hz = 1`, paper time window `t in [0, 8]`
- `eDQPT`: `Jx = Jy = 0.3`, `Jz = 1`, `hx = 0.3`, `hz = 0.1`, paper time window `t in [0, 4]`

The new workflow computes:

- fidelity density / rate
- leading entanglement weights `lambda1..lambda4`
- overlap diagnostics `|o11|`, `|ood|`
- leading fidelity-transfer-matrix eigenvalue magnitudes
- local `x`-magnetization
- mutual-information curves `I12`, `I13`, `I12_3`, `I12_4`

## Numerical setup used here

The implementation supports the paper-style truncation target `sqrt(lambda_i) < 1e-9` with `chi <= 200`, but in the current code path this full setting is too expensive for a single-turn audit: a `chi = 200` full-window run was started and remained in the first `pDQPT` dataset generation for more than 30 minutes without producing the first TSV. I therefore generated the present audit figures using:

- `dt = 0.05`
- `max_bond = 64`
- `cutoff = 1e-8`
- full paper time windows: `t = 0..8` for `pDQPT`, `t = 0..4` for `eDQPT`

This means the present Fig. 2 result is a paper-window approximation, not a faithful `chi = 200` reproduction.

## Generated artifacts

- `outputs/fig2_pdqpt_denicola_2021.tsv`
- `outputs/fig2_edqpt_denicola_2021.tsv`
- `figures/report/dqpt_fig2_denicola_2021.png`
- `figures/report/dqpt_fig2_xxz_audit_denicola_2021.png`

## What the new workflow does correctly

The data path is now paper-oriented rather than proxy-oriented:

- the XXZ Hamiltonians match the paper parameters
- the initial state is the correct `|→⟩^{⊗}` product state
- the main figure now contains the same observable families as paper Fig. 2
- the workflow also computes the overlap diagnostics discussed in Fig. S4, so the mechanism claims can be audited numerically instead of guessed from local observables alone
- the `t = 0` baselines are correct: `rate(0) = 0`, `mx(0) = 1`, and all MI curves start at zero

So from a software-structure standpoint, the repository now has a real Fig. 2 reproduction path.

## What does not match the paper

### 1. `pDQPT` is not reproduced successfully

The paper says Fig. 2(a)(c)(e) should show:

- cusp-like fidelity structure
- gapped entanglement spectrum
- `x`-magnetization near the opposite sign of the initial value at the DQPT
- slowly growing, approximately monotonic MI
- in Fig. S4, a minimum in `|o11|`

The present `max_bond = 64` result does not show this clean pattern:

- the rate grows almost monotonically over `t in [0, 8]` and does not show the paper's repeated cusp structure
- `mx(t)` decreases from `1` to about `0.40` but never approaches sign reversal
- `I12_3` has broad humps rather than simple slow monotonic growth
- `|o11|` is almost flat near `1` and its minimum is only about `0.998`
- worse, `|o11|` later exceeds `1`, reaching about `1.333`, which is a warning sign that the current overlap diagnostic for the XXZ path is not yet numerically trustworthy enough for a paper-faithful claim

Verdict: the current `pDQPT` line is **not** a successful reproduction of paper Fig. 2.

### 2. `eDQPT` is also not reproduced successfully

The paper says Fig. 2(b)(d)(f) should show:

- a DQPT close to an avoided crossing in the entanglement spectrum
- `x`-magnetization with a minimal magnitude near the eDQPT
- complex oscillatory MI with broad maxima in `I12_3`

The present result only partially resembles that story:

- there is a broad rate maximum around `t ≈ 3.6`
- `I12_3` also reaches a broad maximum around `t ≈ 3.65`

But the stronger mechanism checks fail:

- there is no convincing avoided crossing in the leading entanglement weights; the smallest `|lambda1 - lambda2|` in the sampled window is still large, about `0.787`
- `|mx|` reaches its minimum near `t ≈ 3.95`, but the value is still about `0.535`, far from the near-zero behavior expected from the paper discussion
- the MI curves are broad and growing, but not as clearly oscillatory as in the paper

Verdict: the current `eDQPT` line is **not** a successful reproduction of paper Fig. 2.

## Summary judgment

The repository now contains a real De Nicola 2021 Fig. 2 computation path, but the present numerical outputs do **not** justify a claim that Fig. 2 has been faithfully reproduced.

The right wording for the current state is:

- the **workflow exists and runs**
- the **observable families now match the paper**
- the **full `chi = 200` paper-style run remains computationally unresolved in this implementation**
- the **current `max_bond = 64` audit does not reproduce the paper's pDQPT/eDQPT signatures cleanly**

Therefore, Fig. 2 should currently be marked as **implemented but not yet successfully reproduced**.

## Likely next debugging targets

Based on the current audit, the highest-value follow-up checks are:

1. finish or accelerate a true `chi = 200` run, because the current approximate bond cap may be suppressing the paper's DQPT structure
2. audit the XXZ overlap normalization, because `|o11| > 1` strongly suggests the present overlap extraction is not yet numerically consistent enough
3. verify that the 4-site reduced-density construction is using the intended canonical window normalization for infinite states, not just a convenient local contraction that works at `t = 0`
4. benchmark whether the current MPO-apply path should be replaced with a different infinite-state evolution strategy for the XXZ case
