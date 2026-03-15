# De Nicola 2021 Fig. 1 Analysis Note

This note documents the new reproduction path for Stefano De Nicola et al., *Entanglement View of Dynamical Quantum Phase Transitions* (PRL 126, 040602, 2021), restricted to the Ising Fig. 1 mechanism chain.

## What is implemented

The new workflow lives in [`src/DQPTFig1DeNicola2021.jl`](../../src/DQPTFig1DeNicola2021.jl) and targets the two Ising quenches discussed in Fig. 1:

- `pDQPT`: initial state `|↓⟩^{⊗}`, evolution with `J = 0.1`, `hx = 1`, `hz = 0.15`
- `eDQPT`: initial state `|→⟩^{⊗}`, evolution with `J = 1`, `hx = 0.1`, `hz = 0.15`

The critical basis convention is that MPSKit uses `σᶻ = diag(1, -1)`, so the local `|↓⟩` spinor is `[0, 1]`, not `[1, 0]`. Correcting this convention was necessary to recover the expected pDQPT timing.

## Numerical construction

The implementation keeps the paper's canonical-form logic explicit.

For a one-site canonical iMPS in MPSKit notation:

- `AL = Λ Γ`
- `C = Λ`
- `Γ = AL / Λ` on the left virtual index

The code uses:

- `psi.AL[1]` as the left-canonical tensor `AL`
- `psi.C[1]` as the Schmidt-value tensor `Λ`
- `s1, s2` for the leading two singular values, with `λ1 = s1^2`, `λ2 = s2^2`

For an initial product state with local spinor `v`, the overlap matrix is built as

- `o_ij = <v | Γ_ij>`

and the leading `2 x 2` fidelity transfer matrix used for the mechanism analysis is

- `T_f^(2) = Λ^(2) o^(2)`

This is implemented by:

- recovering `Γ` from `AL` and `C`
- contracting `Γ` with the initial-state bra to obtain `o`
- multiplying by the leading Schmidt values to obtain the truncated transfer matrix
- diagonalizing that `2 x 2` matrix to track `e1, e2`

The full time evolution is performed from the strict product state using a `WII` time-MPO plus `SvdCut` truncation path. This replaced the earlier `changebonds + TDVP` route, which was unstable when starting from a strict `χ = 1` product state.

## Generated artifacts

Fresh outputs were generated in:

- [`outputs/fig1_pdqpt_denicola_2021.tsv`](../../outputs/fig1_pdqpt_denicola_2021.tsv)
- [`outputs/fig1_edqpt_denicola_2021.tsv`](../../outputs/fig1_edqpt_denicola_2021.tsv)
- [`figures/report/dqpt_fig1_pdqpt_denicola_2021.png`](../../figures/report/dqpt_fig1_pdqpt_denicola_2021.png)
- [`figures/report/dqpt_fig1_edqpt_denicola_2021.png`](../../figures/report/dqpt_fig1_edqpt_denicola_2021.png)

The plots are four-panel diagnostic figures:

1. rate function
2. `|e1|, |e2|` from the truncated fidelity transfer matrix
3. `s1, s2`
4. `|o11|, |ood|`

This is slightly more explicit than the paper's Fig. 1(d)-(e), because the transfer-matrix eigenvalue relation is shown directly instead of only being inferred.

## Reproduction audit

### pDQPT

After correcting the `|↓⟩` basis convention, the pDQPT line now reproduces the expected precession-dominated mechanism.

Key observed values from [`outputs/fig1_pdqpt_denicola_2021.tsv`](../../outputs/fig1_pdqpt_denicola_2021.tsv):

- local rate peak at `t = 1.5` with `rate ≈ 2.598`
- minimum transfer-eigenvalue gap at `t = 1.55`
- `s1 ≈ 0.9970`, `s2 ≈ 0.0773` at `t = 1.5`, so `s2 / s1 ≈ 0.077`
- `o11` minimum at `t = 1.55` with `|o11| ≈ 0.146`
- at the same point `|ood| ≈ 0.986`

This matches the paper's pDQPT interpretation:

- the entanglement spectrum remains strongly gapped
- the DQPT is tied to a minimum of `|o11|`
- the off-diagonal overlap becomes dominant while `s2` stays much smaller than `s1`

### eDQPT

The eDQPT line shows multiple low-gap transfer events in the `t in [0, 4]` window. The event that best matches the paper's Fig. 1(e) mechanism is the one near `t = 2.35`.

Key observed values from [`outputs/fig1_edqpt_denicola_2021.tsv`](../../outputs/fig1_edqpt_denicola_2021.tsv):

- local rate peaks at `t = 0.8`, `2.35`, and `3.75`
- transfer-eigenvalue gap minima at `t = 0.8`, `2.35`, and `3.8`
- at `t = 2.35`, `s1 ≈ 0.746`, `s2 ≈ 0.666`
- at `t = 2.35`, `|o11| ≈ 0.719`, `|ood| ≈ 0.717`
- the transfer gap there is `|e1| - |e2| ≈ 0.0163`

This is the clearest avoided-crossing-style event in the generated window:

- the two leading singular values are close
- the two relevant overlaps become comparable
- the transfer-matrix eigenvalues nearly exchange dominance

So the new workflow does recover the eDQPT mechanism qualitatively. The caveat is that the chosen time window also contains additional eDQPT-like events, so the output should be read as a mechanism-resolving audit rather than a pixel-level recreation of the exact panel bounds used in the PRL figure.

## Bottom line

For Fig. 1, the new implementation succeeds at the level that was missing before:

- it explicitly reconstructs `Γ`, `o`, and the truncated fidelity transfer matrix from the canonical iMPS
- it numerically links `s1, s2`, `|o11|, |ood|`, and `|e1|, |e2|`
- it reproduces the expected pDQPT mechanism cleanly
- it reproduces the eDQPT mechanism qualitatively, with the clearest paper-like event near `t ≈ 2.35`

What it is not claiming:

- this is not a pixel-exact clone of the PRL plotting layout
- this is not yet the paper's dashed `χ = 2` analytical overlay
- the eDQPT time window still benefits from manual interpretation because multiple near-crossing events appear
