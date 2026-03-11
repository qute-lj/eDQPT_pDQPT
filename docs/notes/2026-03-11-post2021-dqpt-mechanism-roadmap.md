# Post-2021 DQPT Mechanism Roadmap

## Scope update

The current repository already contains a qualitative reproduction of the 2021 PRL on `pDQPT/eDQPT`, but that is no longer the main question for this round.

The updated goal is:

- look at work published after the 2021 PRL
- keep the focus on mechanisms related to `entanglement-driven` versus `precession-driven` DQPT behavior
- allow papers that do not explicitly use the labels `eDQPT/pDQPT`, as long as they materially advance the same mechanism question

## Current local baseline

The present repo is still useful as a starting point because it already provides a simple MPS-based workflow for:

- Loschmidt-rate tracking
- entanglement entropy tracking
- local or staggered order-parameter tracking
- fast qualitative comparison between more semiclassical and more entanglement-heavy channels

What it does **not** yet provide:

- genuine two-dimensional tensor-network evolution
- scar-model dynamics
- gauge-theory or confinement-focused Hamiltonians
- scaling or transfer-spectrum diagnostics tailored to newer mechanism papers

## Three options

### Option A: mechanism mainline after 2021

Recommended.

1. Stefano De Nicola, Alexios A. Michailidis, Maksym Serbyn, *Entanglement and precession in two-dimensional dynamical quantum phase transitions* (2022)
2. Maarten Van Damme, Jean-Yves Desaules, Zlatko Papić, Jad C. Halimeh, *Anatomy of dynamical quantum phase transitions* (2023)
3. Jesse J. Osborne, Ian P. McCulloch, Jad C. Halimeh, *Probing confinement through dynamical quantum phase transitions: From quantum spin models to lattice gauge theories* (2025)

Why this is the best track:

- it stays closest to the original `eDQPT/pDQPT` mechanism question
- it shows how the 2021 language survives, changes, or gets replaced in later work
- it gives a realistic path from conceptual reading to actual follow-up reproductions

### Option B: DQPT type proliferation beyond simple order-parameter language

1. Maarten Van Damme et al., *Dynamical quantum phase transitions in spin-S U(1) quantum link models* (2022)
2. Maarten Van Damme et al., *Anatomy of dynamical quantum phase transitions* (2023)
3. Jesse J. Osborne et al., *Probing confinement through dynamical quantum phase transitions: From quantum spin models to lattice gauge theories* (2025)

Why it is interesting:

- it emphasizes that many DQPTs are not exhausted by order-parameter sign changes
- it moves quickly into gauge-theory and branch/manifold language

Why it is not my first recommendation:

- it is slightly farther from the original `precession vs entanglement` framing
- it is harder to connect directly to the current local code without new Hamiltonian work

### Option C: broader nearby extensions of DQPT criticality

1. Sebastian Stumper, Michael Thoss, Junichi Okamoto, *Interaction-driven dynamical quantum phase transitions in a strongly correlated bosonic system* (2022)
2. Ángel L. Corps, Armando Relaño, Jad C. Halimeh, *Unifying finite-temperature dynamical and excited-state quantum phase transitions* (2024)
3. R. Jafari et al., *Dynamical quantum phase transitions following a noisy quench* (2024)

Why it is useful:

- it tests how robust DQPT notions are under interactions, temperature, and noise

Why it is not the right first move here:

- these papers are more about the breadth of DQPT criticality than about the specific `entanglement/precession` mechanism split

## A track: detailed assessment

### A1. De Nicola, Michailidis, Serbyn (2022)

Paper:

- Stefano De Nicola, Alexios A. Michailidis, Maksym Serbyn, *Entanglement and precession in two-dimensional dynamical quantum phase transitions*, Phys. Rev. B 105, 165149, published 2022-04-15
- DOI: <https://doi.org/10.1103/PhysRevB.105.165149>
- ISTA record with abstract: <https://research-explorer.ista.ac.at/record/11337>
- arXiv preprint: <https://doi.org/10.48550/arXiv.2112.11273>

Why it matters:

- This is the cleanest direct continuation of the 2021 PRL.
- It asks whether the `pDQPT/eDQPT` distinction survives once one leaves strict 1D.

What the abstract says:

- The paper explicitly extends the 2021 `pDQPT/eDQPT` distinction to two-dimensional settings using semi-infinite ladders of varying width.
- On square lattices, the two mechanisms persist with similar signatures to 1D:
  - `pDQPT`: magnetization sign change plus a wide entanglement gap
  - `eDQPT`: suppressed local observables plus avoided crossings in the entanglement spectrum
- The authors also report stronger sensitivity to ladder width and to microscopic details, especially for `eDQPT`.
- On honeycomb lattices, odd coordination produces behavior beyond the 1D classification.

Mechanism takeaway:

- This paper says the 2021 split is not just a 1D accident.
- At the same time, it weakens any naive claim of universality: once coordination and geometry change, the classification becomes less rigid.

Reproduction fit:

- Physics fit: very high
- Implementation fit to the current repo: low-to-medium

Reason:

- the current repo is built around 1D infinite-MPS workflows
- this paper needs ladder or cylinder-style quasi-2D evolution, or at least a controlled ladder approximation

My recommendation:

- read this paper early because it defines the correct post-2021 continuation of the 2021 story
- do **not** make it the first new reproduction target unless we are willing to add ladder/cylinder infrastructure

### A2. Van Damme, Desaules, Papić, Halimeh (2023)

Paper:

- Maarten Van Damme, Jean-Yves Desaules, Zlatko Papić, Jad C. Halimeh, *Anatomy of dynamical quantum phase transitions*, Phys. Rev. Research 5, 033090, published 2023-08-08
- DOI: <https://doi.org/10.1103/PhysRevResearch.5.033090>
- APS page: <https://journals.aps.org/prresearch/abstract/10.1103/PhysRevResearch.5.033090>

Why it matters:

- This is the strongest post-2021 conceptual paper in the current shortlist.
- It directly tests whether periodic DQPTs are really just effective two-level Rabi physics.

What the abstract says:

- The authors study periodic DQPTs in a many-body-scar setting.
- They find that a DQPT marks a change in the dominant contribution to the wavefunction inside the degenerate initial-state manifold.
- A direct relation to an order-parameter zero exists only in a special midpoint case.
- In general, periodic DQPTs reflect many-body dynamics beyond a two-level-system picture.

Mechanism takeaway:

- This paper generalizes and sharpens the 2021 message.
- The important lesson is not merely `precession vs entanglement`, but more broadly:
  - DQPTs track reorganizations of wavefunction weight in a structured many-body manifold
  - local order-parameter zeros are only a special visible symptom

Reproduction fit:

- Physics fit: very high
- Implementation fit to the current repo: low

Reason:

- the model context is quantum many-body scarring, not the Ising/XXZ quench pair currently in the repo
- the main value of this paper for us is interpretive and classificatory, not immediate code reuse

My recommendation:

- use this paper as the conceptual lens for reading later work
- postpone direct reproduction unless we deliberately pivot toward scar models

### A3. Osborne, McCulloch, Halimeh (2025)

Paper:

- Jesse J. Osborne, Ian P. McCulloch, Jad C. Halimeh, *Probing confinement through dynamical quantum phase transitions: From quantum spin models to lattice gauge theories*, Phys. Rev. Research 7, 043076, published 2025-10-17
- DOI: <https://doi.org/10.1103/rnv5-f32k>
- APS accepted-page abstract: <https://journals.aps.org/prresearch/accepted/10.1103/rnv5-f32k>
- Open publisher-version mirror: <https://pure.mpg.de/rest/items/item_3679243_1/component/file_3679732/content>

Why it matters:

- This is the most operationally useful mechanism paper after 2021 in the current shortlist.
- It introduces a more structural distinction, `branch` versus `manifold` DQPTs, tied to confinement.

What the paper says:

- The authors use large-scale uniform MPS calculations on three model families:
  - power-law quantum Ising chain
  - two-dimensional quantum Ising model
  - spin-`S` `U(1)` quantum link model
- They find that tuning a confining parameter changes the dominant type of DQPT.
- `manifold DQPTs` are associated with an order-parameter sign change.
- `branch DQPTs` are not associated with an order-parameter sign change and can occur even when the order parameter remains strongly constrained.

Mechanism takeaway:

- This is very close in spirit to the 2021 story, but the classification language is stronger.
- In practical terms, the paper says that constrained dynamics and confinement can replace naive semiclassical precession as the key organizing principle.
- My inference: this is one of the most promising successors to the `pDQPT/eDQPT` language if the goal is to classify mechanisms across broader model classes.

Reproduction fit:

- Physics fit: very high
- Implementation fit to the current repo: medium

Reason:

- unlike the scar paper, this one still lives in a world of Ising-like and MPS-friendly models
- the easiest entry point is not the full paper but the long-range or confinement-modified Ising side

My recommendation:

- if we want one post-2021 mechanism paper to reproduce first, this is the best candidate in track `A`

## A-track supporting context

Two 2022 papers are especially useful side references even though they are not themselves the chosen `A` trio.

### Hashizume, McCulloch, Halimeh (2022)

- *Dynamical phase transitions in the two-dimensional transverse-field Ising model*, Phys. Rev. Research 4, 013250
- DOI: <https://doi.org/10.1103/PhysRevResearch.4.013250>
- APS page: <https://journals.aps.org/prresearch/abstract/10.1103/PhysRevResearch.4.013250>

Why it helps:

- It distinguishes `regular` cusps linked to order-parameter zero crossings from `anomalous` cusps that can occur without them.
- It argues that anomalous cusps arise when local spin excitations are the dominant quasiparticles.
- This is mechanistically adjacent to the `eDQPT/pDQPT` question even though it uses different language.

### Brange, Peotta, Flindt, Ojanen (2022)

- *Dynamical quantum phase transitions in strongly correlated two-dimensional spin lattices following a quench*, Phys. Rev. Research 4, 033032
- DOI: <https://doi.org/10.1103/PhysRevResearch.4.033032>
- APS page: <https://journals.aps.org/prresearch/abstract/10.1103/PhysRevResearch.4.033032>

Why it helps:

- It shows that genuine 2D DQPT detection is computationally nontrivial and motivates special numerical tools.
- This supports the practical conclusion that the 2022 De Nicola paper is conceptually central but not the easiest first reproduction target.

## Practical conclusion

If the real question is:

> what became of the `eDQPT/pDQPT` mechanism story after 2021?

then my current answer is:

1. The most direct continuation is `De Nicola et al. 2022`.
2. The strongest conceptual generalization is `Van Damme et al. 2023`.
3. The best first new reproduction target is `Osborne et al. 2025`.

## Suggested execution order

### Reading order

1. `De Nicola et al. 2022`
2. `Van Damme et al. 2023`
3. `Osborne et al. 2025`

### Reproduction order

1. `Osborne et al. 2025`
   - start from the Ising-side confinement story
   - reuse as much of the current MPS workflow as possible
2. `De Nicola et al. 2022`
   - only after deciding whether we want to build ladder/cylinder support
3. `Van Damme et al. 2023`
   - treat as a later conceptual benchmark rather than the first coding target
