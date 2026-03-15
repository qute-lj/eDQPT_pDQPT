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

After fixing the canonical extraction bug, the present audit figures were regenerated using:

- `dt = 0.05`
- `max_bond = 100`
- `cutoff = 1e-8`
- backend `:tdvp_optimal`
- full paper time windows: `t = 0..8` for `pDQPT`, `t = 0..4` for `eDQPT`

The crucial correction is that the paper's diagonal Schmidt tensor `Λ` must be obtained from the singular-value decomposition of the MPSKit gauge tensor `C`. The previous code incorrectly read `diag(C)` as the Schmidt spectrum, which is only safe when `C` is already diagonal. That happened to be nearly true for the `WII` path, but it is false for the `TDVP` path and was the direct cause of the earlier unphysical overlap diagnostics.

This is still not a faithful `chi = 200` reproduction, but it is now a gauge-consistent paper-window audit.

## Generated artifacts

- `outputs/fig2_pdqpt_denicola_2021.tsv`
- `outputs/fig2_edqpt_denicola_2021.tsv`
- `outputs/fig2_edqpt_refined_twindow_denicola_2021.tsv`
- `figures/report/dqpt_fig2_denicola_2021.png`
- `figures/report/dqpt_fig2_xxz_audit_denicola_2021.png`

## What the new workflow does correctly

The data path is now paper-oriented rather than proxy-oriented:

- the XXZ Hamiltonians match the paper parameters
- the initial state is the correct `|→⟩^{⊗}` product state
- the main figure now contains the same observable families as paper Fig. 2
- the workflow also computes the overlap diagnostics discussed in Fig. S4, so the mechanism claims can be audited numerically instead of guessed from local observables alone
- the `t = 0` baselines are correct: `rate(0) = 0`, `mx(0) = 1`, and all MI curves start at zero
- the canonical-overlap extraction now uses `svd(C)` to recover the Schmidt spectrum and Schmidt basis before reconstructing `A = ΛΓ`
- with that fix in place, the `TDVP` overlap diagnostics are again numerically sane; for example, the previous `eDQPT` sample with `|ood| ≈ 1.47` now drops to `|ood| ≈ 0.51`

So from a software-structure standpoint, the repository now has a real Fig. 2 reproduction path.

## What matches the paper after the canonical fix

### 1. `pDQPT` is now qualitatively reproduced

The paper says Fig. 2(a)(c)(e) should show:

- cusp-like fidelity structure
- gapped entanglement spectrum
- `x`-magnetization near the opposite sign of the initial value at the DQPT
- slowly growing, approximately monotonic MI
- in Fig. S4, a minimum in `|o11|`

The corrected `TDVP` result now shows the expected pDQPT structure around the dominant peak at `t ≈ 1.45`:

- the rate has a strong sharp maximum, `l(t) ≈ 2.14`
- the magnetization is near the opposite sign of the initial state, `mx ≈ -0.93`
- the leading entanglement weights are still well separated there, `lambda1 ≈ 0.978`, `lambda2 ≈ 0.021`
- the overlap channel drives the event: `|o11| ≈ 0.134`, `|ood| ≈ 0.630`

This is the paper's pDQPT mechanism: a still-gapped entanglement spectrum combined with a strong rearrangement of the overlaps. The late-time tail is still not paper-perfect, but the main pDQPT mechanism is now reproduced qualitatively.

### 2. `eDQPT` is now partially and qualitatively reproduced

The paper says Fig. 2(b)(d)(f) should show:

- a DQPT close to an avoided crossing in the entanglement spectrum
- `x`-magnetization with a minimal magnitude near the eDQPT
- complex oscillatory MI with broad maxima in `I12_3`

The corrected `TDVP` result now does show a genuine near-crossing:

- the smallest sampled gap is `|lambda1 - lambda2| ≈ 0.0368` at `t ≈ 1.10`
- at that point `lambda1 ≈ 0.506` and `lambda2 ≈ 0.470`, with `s1 ≈ 0.712` and `s2 ≈ 0.685`
- the rate is already large there, `l(t) ≈ 0.343`, and reaches its maximum `≈ 0.390` shortly afterward at `t ≈ 1.20`

So the avoided-crossing mechanism is now present numerically, which was completely hidden before the canonical fix.

The remaining mismatch is that the eDQPT line is still not as clean as the paper:

- the minimum `|mx|` is only about `0.314`, not close to zero
- the overlap signal is moderate rather than dramatic, with `|o11|` staying above about `0.675` and `|ood|` peaking near `0.511`
- the MI curves are still not as clearly oscillatory or as well aligned with the rate structure as in the paper panel

Verdict: the current `eDQPT` line is **qualitatively captured but not yet paper-grade**.

## Higher-chi probe

I also reran the corrected `eDQPT` line with the same `TDVP` backend at `max_bond = 150` and `max_bond = 200`.

The result is strikingly stable: all key mechanism diagnostics are numerically identical, within print precision, to the `max_bond = 100` run:

- peak rate remains at `t ≈ 1.20` with `l(t) ≈ 0.390`
- the minimum entanglement-weight gap remains at `t ≈ 1.10` with `|lambda1 - lambda2| ≈ 0.0368`
- the minimum magnetization magnitude remains `|mx| ≈ 0.314`
- the overlap diagnostics remain `min |o11| ≈ 0.675`, `max |ood| ≈ 0.511`

This means that, for the present corrected `TDVP` workflow and `eDQPT` paper window, the current mismatch to the paper is **not** coming from a too-small bond cap between `chi = 100` and `chi = 200`.

## Local time-grid refinement probe

I then reran the corrected `eDQPT` line with the same `TDVP` backend and `max_bond = 100`, but with a locally refined time grid:

- coarse grid `dt = 0.05` outside the interesting window
- refined grid `dt = 0.005` for `t in [1.0, 1.3]`

This specifically tests whether the remaining `eDQPT` mismatch is just a coarse-time-sampling artifact.

The refined run does sharpen the avoided crossing:

- the smallest sampled gap moves from `|lambda1 - lambda2| ≈ 0.0368` at `t ≈ 1.10` to `≈ 0.0253` at `t ≈ 1.12`
- the rate maximum shifts slightly from `t ≈ 1.20` with `l(t) ≈ 0.390` to `t ≈ 1.205` with `l(t) ≈ 0.392`
- at the narrowest crossing, the overlap diagnostics become somewhat more mixed, `|o11| ≈ 0.712`, `|ood| ≈ 0.398`

But the magnetization mismatch does **not** improve:

- the minimum `|mx|` remains essentially unchanged at `≈ 0.314`, still far from a near-zero crossing

So the coarse `dt = 0.05` grid was indeed broadening the `eDQPT` avoided crossing a little, but it was **not** the main reason the full panel still disagrees with the paper. The remaining mismatch is no longer credibly explained by either bond cap or local time resolution.

## Summary judgment

The repository now contains a real De Nicola 2021 Fig. 2 computation path, and after the canonical-fix audit the status improves substantially:

The right wording for the current state is:

- the **workflow exists and runs**
- the **observable families now match the paper**
- the **previous overlap-normalization bug has been fixed by extracting `Λ` from `svd(C)` instead of `diag(C)`**
- the **`TDVP + OptimalExpand + env reuse` backend is now the only backend that gives a convincing Fig. 2 mechanism audit**
- the **full `chi = 200` paper-style run for both lines is still expensive, but the `eDQPT` line itself is already converged by `chi = 100` in the current workflow**
- the **current `max_bond = 100` audit qualitatively reproduces the pDQPT mechanism and qualitatively captures the eDQPT avoided crossing**
- the **local `dt = 0.005` refinement confirms that the eDQPT crossing is real and somewhat sharper than the coarse grid suggested**
- the **current result is still short of a clean paper-grade Fig. 2 reproduction, especially on the eDQPT side**

Therefore, Fig. 2 should currently be marked as **partially reproduced after a major canonical-fix correction**, not merely “implemented”.

## Likely next debugging targets

Based on the current audit, the highest-value follow-up checks are now:

1. treat the remaining `eDQPT` mismatch as an algorithmic or observable-definition issue before assuming it is a bond-dimension issue
2. keep the `WII` path only as a comparison baseline, not as the main Fig. 2 reproduction backend
3. cross-check the `x`-magnetization / MI mismatch against an independent evolution path before investing in broader high-cost scans
4. only after that algorithmic cross-check should a broader `chi = 200` campaign be reconsidered
