## Entanglement view of dynamical quantum phase transitions

Stefano De Nicola, Alexios A. Michailidis, and Maksym Serbyn

IST Austria, Am Campus 1, 3400 Klosterneuburg, Austria

(Dated: February 2, 2021)

The analogy between an equilibrium partition function and the return probability in many-body unitary dynamics has led to the concept of dynamical quantum phase transition (DQPT). DQPTs are defined by non-analyticities in the return amplitude and are present in many models. In some cases DQPTs can be related to equilibrium concepts such as order parameters, yet their universal description is an open question. In this work we provide first steps towards a classification of DQPTs by using a matrix product state description of unitary dynamics in the thermodynamic limit. This allows us to distinguish the two limiting cases of precession and entanglement DQPTs, which are illustrated using an analytical description in the quantum Ising model. While precession DQPTs are characterized by a large entanglement gap and are semiclassical in their nature, entanglement DQPTs occur near avoided crossings in the entanglement spectrum and can be distinguished by a complex pattern of non-local correlations. We demonstrate the existence of precession and entanglement DQPTs beyond Ising model, discuss observables that can distinguish them and relate their interplay to complex DQPT phenomenology.

Introduction.The rapid development of different quantum simulation platforms [1, 2] fuels the exploration of new non-equilibrium phenomena that can be probed in isolated interacting quantum systems. Due to experimental limitations, phenomena observable at short times in quantum quenches are of particular interest. Dynamical quantum phase transitions (DQPTs) have recently emerged as an interesting phenomenon within this regime [3, 4]. Since the early work of Heyl et al. [3], who introduced the notion of DQPT considering the quantum Ising model, DQPTs have attracted great interest [5-28]. Moreover, they were experimentally observed in trapped ion quantum simulators [29], superconducting qubits [30] and other platforms [31-34].

In the framework of DQPTs, one considers quantum quenches from an initial state | ψ 0 〉 and monitors the normalized logarithm of the return probability in the process of unitary evolution under a Hamiltonian H ,

<!-- formula-not-decoded -->

where we restrict to one dimensional cases and denote system size as L . This quantity is identified as the nonequilibrium analogue of the free energy density, with DQPTs corresponding to non-analyticities in the behavior of f ( t ) at early times [3]. However, f ( t ) corresponds to the free energy at complex temperature, and a precise relation between the behavior of f ( t ) and the equilibrium phase diagram was not established [28]. Phenomenologically, quenches from a state | ψ 0 〉 that realizes a different phase compared to the ground state of H often give rise to DQPTs [3-5, 10, 18]; however, there are exceptions from this rule [6, 7, 14, 15, 27, 28].

In order to connect DQPTs to equilibrium concepts, such as order parameters, the behavior of local observables was explored [22, 26, 35]. A direct correspondence was established for systems with broken symmetries, involving a generalized notion of DQPTs [11, 17, 20, 36]. Recently, local string observables capable of revealing

DQPTs were introduced [37, 38]. However, the general relation between DQPTs and local expectation values remains elusive. Connections to the entanglement entropy were also explored: DQPTs may correspond to regions of rapid growth [29] or peaks [21] in the entanglement entropy, and, for certain quenches in integrable models, they occur at crossings in the entanglement spectrum [9, 10, 39]. Nonetheless, the underlying mechanism and the conditions under which DQPTs may be related to entanglement signatures are not clearly understood. Thus, in spite of many advancements, the rich phenomenology of DQPTs and their relation to other physical quantities still call for a more general understanding [28].

In this manuscript, we utilize the matrix product state (MPS) [40] language for DQPTs that was applied in numerical studies [5, 10, 11, 14, 18, 26]. We show that in the low-entanglement regime it is possible to distinguish between precession and entanglement DQPTs, which correspond to different physics, as highlighted by analytical MPS ans¨ atze. We illustrate the existence of entanglement and precession DQPTs in different models, discuss ways to distinguish them experimentally and suggest how their interplay may lead to the rich phenomenology reported in the literature.

MPS description of DQPTs.DQPTs are typically studied at short times for quenches from area-law entangled initial states. In this regime, the time-evolved state | ψ ( t ) 〉 = e -iHt | ψ 0 〉 has area-law entanglement due to Lieb-Robinson bounds [41, 42] and admits an MPS description [40]. For translation-invariant initial states (possibly with a finite-size unit cell), infinite MPS (iMPS) [43] provides an efficient representation of | ψ ( t ) 〉 . In Fig. 1(a) we show a iMPS in the canonical form [43, 44], where the standard building block of MPS, the tensor A σ ij ( t ), is decomposed as A σ ij ( t ) = Λ ii ( t )Γ σ ij ( t ). Here σ = ↑ , ↓ is the physical and i, j = 1 , . . . , χ are bond indices. The diagonal matrix Λ ii ( t ) = √ λ i contains the ordered, λ i &gt; λ i -1 , singular values of the

Figure 1. (a) Representation of the fidelity density transfer matrix T f obtained from the iMPS canonical form when the initial state is a product state. The evolution of the two leading eigenvalues of T f in the complex plane, the fidelity density, the entanglement spectrum and the overlaps are illustrated for a pDQPT in panels (b) and (d) and for an eDQPT in (c) and (e). Red circles in panels (b)-(c) correspond to times where DQPTs occur. Panels (d)-(e) compare fidelity density, entanglement spectrum and overlaps. Solid lines show iTEBD data obtained with χ ≤ 8 (truncating √ λ i &lt; 10 -9 ), and dashed lines correspond to the analytical ans¨ atze; quench parameters are listed in the main text.

<!-- image -->

Schmidt decomposition across a bond. λ i determine the entanglement spectrum, so that the bipartite entanglement entropy is S = -∑ i λ i log λ i . The tensor Γ σ ( t ) carries a physical index and together with Λ satisfies a set of canonical conditions, ∑ ijσ Λ 2 ij Γ σ jk Γ σ ∗ il = ∑ ijσ Λ 2 ij Γ σ kj Γ σ ∗ li = δ kl [44].

Using the iMPS representation, the fidelity density is expressed directly in thermodynamic limit via the spectrum of the fidelity transfer matrix, T f ( t ), { e i } , as [7, 45]

<!-- formula-not-decoded -->

The transfer matrix T f ( t ) is defined in Fig. 1(a) as a contraction of the time-evolved MPS tensor with its conjugate at t = 0. Thus, T f (0) coincides with the conventional transfer matrix and has | e 1 | = 1 and all other | e i | &lt; 1, as follows from normalization of | ψ 0 〉 . At later times the eigenvalues of T f ( t ) perform complicated evolution in the complex plane. As illustrated in Fig. 1(b)-(c), singularities in f ( t ) emerge from the initially subleading eigenvalue, e 2 , surpassing in magnitude the largest one.

Two limiting cases of DQPTs.To distinguish between different physical mechanisms that drive the crossing between transfer matrix eigenvalues, we use the canonical form of the MPS tensor and focus on the case when the initial state | ψ 0 〉 = ⊗ i | v 〉 i is a product state. The contraction of the time-evolved MPS with the product state does not affect bond indices, see Fig. 1(a), resulting in

<!-- formula-not-decoded -->

where we retained the leading 2 × 2 part of the MPS virtual space, corresponding to the two largest singular values. For initial product states, the elements of the overlap matrix o are obtained via contraction of the tensor Γ σ ij with the single-site spinor wave function v σ .

Equations (2)-(3) single out the contribution of the entanglement spectrum, encoded in the diagonal of the matrix Λ, to the transfer matrix T f ( t ) and DQPTs. When the entanglement spectrum features a large gap, λ 1 glyph[greatermuch] λ 2 , the switch in magnitude between eigenvalues of T f is necessarily driven by the evolution of the overlap matrix. This is a precession DQPT (pDQPT) that is of semiclassical nature, as we explain below. In the opposite limit, when the two leading singular values λ 1 and λ 2 exhibit an avoided crossing, the system features entanglement of order ln 2. DQPTs happening near such points are dubbed entanglement DQPTs (eDQPTs). We illustrate these two limits of DQPTs in the quantum Ising model using analytical MPS ans¨ atze.

Precession DQPTs in the Ising model.In order to illustrate pDQPTs, we study the dynamics under the transverse and longitudinal-field Ising model

<!-- formula-not-decoded -->

The initial state | ψ 0 〉 = ⊗ i |↓〉 i is the ground state of the Hamiltonian (4) in the ferromagnetic phase, J → -∞ , h z &gt; 0. The evolution is performed with J = 0 . 1, h x = 1, h z = 0 . 15, so that single-spin terms are dominant.

The top panel of Fig. 1(d) shows the fidelity density calculated using infinite time-evolving block decimation (iTEBD) [43]. It exhibits a cusp at t ≈ 1 . 5, signaling a DQPT. By bringing the MPS to the canonical form we extract the entanglement and overlap contributions. The middle plot shows the evolution of the two leading singular values, which remain very well separated at the

time when the DQPT occurs. At the same time, | o 11 | exhibits a minimum near the DQPT, while the off-diagonal component | o 12 | = | o 21 | ≡ | o od | shows a clear maximum. Thus, the overlap matrix is predominantly responsible for the switch of the transfer matrix eigenvalues, providing a prototypical example of pDQPT.

Analytical pDQPT ansatz.The precession nature of pDQPTs can be illustrated by analytically constructing a suitable χ = 2 MPS ansatz. In the limit when J glyph[lessmuch] h x , h z we split the Hamiltonian (4) into an interacting part V = J ∑ i σ z i σ z i +1 and a free-precessing part H 0 = ∑ i [ h x σ x i + h z σ z i ] that contains only single-spin terms. Then, we move to the rotating frame with respect to H 0 , rewriting the time evolution as | ψ ( t ) 〉 = e -iH 0 t T e -i ∫ t 0 ˜ V ( t ′ )d t ′ | ψ 0 〉 . The interaction term in the rotating frame reads: ˜ V ( t ) = e itH 0 V e -itH 0 = ∑ i ∑ α,β s α ( t ) s β ( t ) σ α i σ β i +1 , where α, β ∈ { x, y, z } , the time-dependent coefficients are s x ( t ) = 2 h x h z sin 2 ( ht ) /h 2 , s y ( t ) = h x sin(2 ht ) /h , s z ( t ) = [ h 2 x cos(2 ht ) + h 2 z ] /h 2 , and h = √ h 2 x + h 2 z is the magnitude of the applied field. Finally, we exploit the slow initial buildup of entanglement along the z axis to replace the σ x and σ z operators in ˜ V ( t ) by their expectation values under free precession, -s x and -s z respectively. This allows us to approximately write ˜ V ( t ) as a matrix product operator (MPO) of χ = 2 [46] [47] [48]. Acting by this MPO on the initial |↓〉 -product state gives an MPS ansatz for | ψ ( t ) 〉 . Bringing this ansatz to canonical form [46], we obtain the singular values as √ λ 1 = | cos[ Ja ( t )] | , √ λ 2 = | sin[ Ja ( t )] | , where a ( t ) = h 2 x [4 ht -sin(4 ht )] / 8 h 3 . The middle panel of Fig. 1(d) reveals an excellent agreement between our analytical results and iTEBD predictions for the singular values. The Γ matrix in the canonical form reads:

<!-- formula-not-decoded -->

where ¯ Λ = diag( sign[cos( Ja ( t ))] , sign[sin( Ja ( t ))]) and b ( t ) = h x [ h 2 x cos(6 ht ) + 3 ( h 2 +3 h 2 z ) cos(2 ht ) -4 ( h 2 +2 h 2 z ) ] / 12 h 4 [46]. The matrix of overlaps o is obtained by contracting all entries of Γ( t ) with the 〈↓| state on the left. The behavior of o 11 and o od obtained from (5) agrees with numerically exact iTEBD results, Fig. 1(d). Since λ 1 glyph[greatermuch] λ 2 within the range of considered times, the precession of spins in Γ( t ) induced by exponentials of Pauli matrices plays the main role in driving the pDQPT.

The dominant component of the MPS corresponds to the top diagonal entry in Eq. (5), and it coincides with the initial state |↓〉 at t = 0. The off-diagonal entries in Eq. (5) give subleading contributions suppressed by powers of √ λ 2 /λ 1 , as follows from Eq. (3). However, as both the dominant component |↓〉 and its correction |↑〉 precess, see Eq. (5) and [46], the overlap of the dominant contribution decreases while the subleading state rotates closer to the |↓〉 state. A pDQPT occurs when the formerly subleading contribution becomes important enough to flip the magnitude of the eigenvalues of T f , which happens when | o 11 /o od | ∼ √ λ 2 /λ 1 glyph[lessmuch] 1. The

DQPT is then closely associated with the minimum of o 11 , with corrections given by off-diagonal terms; see Fig. 1(d). Note that, although free precession dominates the dynamics for the present quench, a minimal χ = 2 is required to capture DQPTs due to Eq. (2), reflecting the quantum nature of such phenomena.

Entanglement DQPTs in the Ising model.We consider a quench from the initial state | ψ 0 〉 = ⊗ i |→〉 i , corresponding to the free paramagnet ground state of (4) for h x →-∞ . The dynamics is governed by the Ising Hamiltonian with J = 1, h x = 0 . 1, h z = 0 . 15. Figure 1(e) shows that a DQPT happens near an avoided crossing in the entanglement spectrum. The overlaps | o 11 | and | o od | also display the evolution characteristic of an avoided crossing. This provides an example of eDQPT.

Analytical eDQPT ansatz.The smallness of all but the first two singular values for this quench allows us to analytically construct a χ = 2 MPS ansatz describing eDQPTs, which agrees well with numerically exact iTEBD. To this end, we approximate the timeevolution operator by a second-order Trotter decomposition, splitting the Hamiltonian into a single-spin term, H 0 , and a two-spin term V . The decomposition reads: e -iHt ≈ e -iH 0 t/ 2 e -iV t e -iH 0 t/ 2 , where e -iV t admits an exact MPO representation with χ = 2, see [46]. Applying the resulting MPO to the initial state we obtain the analytical MPS ansatz

<!-- formula-not-decoded -->

where |↑ ( t ) 〉 = exp[ -it ( h x σ x + h z σ z ) / 2)] |↑〉 and c ↑ ( t ) = 〈↑ |→ ( t ) 〉 , and likewise for ↓ .

Casting the ansatz (6) in canonical form yields the tensor Γ, which generally has a complicated expression but can be simplified in certain limits [46], and the entanglement spectrum λ 1 , 2 = [4 ± √ f ( t ) + 13] / 8, whose avoided crossings are expected to drive the DQPT. Here f ( t ) = 4 cos(4 θ ( t )) -cos(8 θ ( t )) + 8sin 4 (2 θ ( t )) cos(4 Jt ) is expressed in terms of a time-dependent angle 2 cos 2 θ ( t ) = 1 + [1 -cos( ht )] h x h z /h 2 . The special cases when either h x or h z vanishes correspond to classical [12, 22] or integrable [3, 9, 10, 39, 49] Ising models, discussed in [46].

glyph[negationslash]

In the generic case with h x , h z = 0, the top and middle panels of Fig. 1(e) show that the ansatz (6) accurately captures the dynamics of the rate function, singular values, and overlaps. The avoided crossing of the singular values leads to a much faster growth of entanglement compared to pDQPTs and drives the switch of the transfer matrix eigenvalues: near the DQPT the quantum state undergoes a rearrangement whereby the initially off-diagonal component, which for λ 2 glyph[lessmuch] λ 1 provides a correction to the leading top-diagonal component, becomes the dominant contribution. Thus eDQPTs manifest a change in the leading component of the quantum state and can be revealed by the structure of non-local correlations, as we discuss below.

DQPTs in the XXZ model.To demonstrate the existence of pDQPTs and eDQPTs beyond the Ising chain,

Fig 2 with labels - new Figure 2. The qualitative behavior of the fidelity density is very similar for the pDQPTs in (a) and the eDQPTs in (b) that occur in the XXZ spin chain. In contrast, x -magnetization and MI have qualitatively different behavior for pDQPTs [panels (c) and (e)] and eDQPTs [panels (d) and (f)]. Simulations are performed using iTEBD with χ = 200.

<!-- image -->

we consider quenches from the fixed initial product state | ψ 0 〉 = ⊗ i |→〉 i . The dynamics is governed by the XXZ model with a field, H = ∑ i,α [ J α σ α i σ α i +1 + h α σ α i ] , where J x = J y and we set h y = 0. Figure 2(a) shows dynamics for J x = J y = 0 . 9, J z = 1, h x = 0 . 1, h z = 1, which displays pDQPTs, as it can be seen from the behavior of the entanglement spectrum in the inset. In Fig. 2(b) we consider the same initial state evolved with J x = J y = 0 . 3, J z = 1, h x = 0 . 3, h z = 0 . 1. In this case, cusps in f ( t ) are close to avoided crossings in the entanglement spectrum (see inset), suggesting eDQPTs. The behavior of the overlaps shown in [46] confirms these expectations.

Experimental signatures.pDQPTs and eDQPTs have very different physical mechanisms, yet the fidelity density behaves qualitatively similarly, cf. Fig. 1(d)-(e) or Fig. 2(a)-(b). An immediate distinction between different DQPTs is provided by the bipartite entanglement entropy S : pDQPTs are of semiclassical nature and occur in low-entanglement regions, whereas eDQPTs are triggered by avoided crossings in λ i at early times, reflected in rapid entanglement growth.

While local expectation values evolve smoothly and cannot indicate the precise location of DQPTs, they provide an additional test for the underlying physical mechanisms. Namely, near pDQPTs the dominant component of the state is maximally far away from the initial state, thus the local magnetization along the orientation of the initial state has opposite sign compared to its value at t = 0, see Fig. 2(c). Near eDQPTs, which are characterized by larger entanglement, local expectation values are expected to be small; this is indeed confirmed by Fig. 2(d), where the magnetization along the x -direction assumes its minimal magnitude near an eDQPT.

The mutual information (MI) can be used to reveal the non-trivial entanglement pattern near eDQPTs. The MI between two regions A and B is defined as I A ; B = S ( A ) + S ( B ) -S ( A ∪ B ), where S ( · ) is the von Neumann entropy of a given region. Regions A , B are chosen to contain one or two spins. Due to translational invariance only relative distances between regions is important. MI provides a basis-independent upper bound on connected correlation functions, which could reveal qualitatively similar behavior provided an appropriate basis is chosen. Figure 2(e) shows that the MI for all choices of regions A and B undergoes slow monotonic growth in the case of a pDQPT. In contrast, eDQPTs correspond to complex oscillatory dynamics of the MI; this is demonstrated in Fig. 2(f), where DQPTs correspond to broad maxima in the MI I 1 , 2;3 between spins { 1 , 2 } and { 3 } .

In [46] we show a similar pattern for the DQPTs of Fig. 1(d)-(e) in the Ising model. The quick growth and non-monotonic behavior of the MI for eDQPTs signal a change in the dominant component of the wave function. The MI can be probed by the connected correlation functions between the two subsystems, which are typically accessible in experiments.

Discussion.We introduced the notions of precession and entanglement DQPTs as two limiting cases, which have different underlying mechanisms and are associated to different physics. pDQPTs can be understood analytically by relying on the large entanglement gap λ 1 glyph[greatermuch] λ 2 and the dynamics being driven by single-spin terms in the Hamiltonian. In contrast, eDQPTs happen near avoided level crossings in the entanglement spectrum λ 1 ∼ λ 2 glyph[greatermuch] λ 3 and can also be analytically described by ignoring λ i with i ≥ 3.

We demonstrated that pDQPTs and eDQPTs exist in different models. These two limits illustrate different physical mechanisms that cause DQPTs, whose relative importance can be qualitatively assessed from the behavior of local observables. Approximations with small bond dimension can then capture DQPTs, provided they incorporate the relevant physics; see [46]. However, more complicated dynamics emerges when both precession and entanglement production are significant; for instance, in [46] we deform eDQPTs into pDQPTs and show complicated hybrid behavior at intermediate couplings. This suggests that DQPTs are generically the outcome of a combination of factors; the interplay of different mechanisms may then be at the root of the rich phenomenology reported in the literature [4]. Our work shows that focusing on the underlying mechanisms is a fruitful path to understanding DQPTs. It would then be interesting to develop analytical ans¨ atze to characterize situations with more than one dominant mechanism, as well as longrange interacting models [16, 19, 20, 29] and other cases that violate typical phenomenology [4, 19, 50].

The connection between DQPTs and the spectrum of the fidelity transfer matrix, which is generically non-Hermitian, calls for exploring the relation between DQPTs and the theory of non-Hermitian matrices [51, 52] that may allow a classification of DQPTs. Tensor

network description could also be used to establish a notion of p- and eDQPTs in higher dimensions and understanding implications for string observables [37, 38].

Acknowledgments.SDN acknowledges funding from the Institute of Science and Technology (IST) Austria,

- [1] T. Langen, R. Geiger, and J. Schmiedmayer, Ultracold atoms out of equilibrium, Annu. Rev. Condens. Matter Phys. 6 , 201 (2015).
- [2] C. Gross and I. Bloch, Quantum simulations with ultracold atoms in optical lattices, Science 357 , 995 (2017).
- [3] M. Heyl, A. Polkovnikov, and S. Kehrein, Dynamical quantum phase transitions in the transverse-field Ising model, Phys. Rev. Lett. 110 , 135704 (2013).
- [4] M. Heyl, Dynamical quantum phase transitions: a review, Rep. Prog. Phys. 81 , 054001 (2018).
- [5] C. Karrasch and D. Schuricht, Dynamical phase transitions after quenches in nonintegrable models, Phys. Rev. B 87 , 195104 (2013).
- [6] S. Vajna and B. D´ ora, Disentangling dynamical phase transitions from equilibrium phase transitions, Phys. Rev. B 89 , 161105 (2014).
- [7] F. Andraschko and J. Sirker, Dynamical quantum phase transitions and the Loschmidt echo: A transfer matrix approach, Phys. Rev. B 89 , 125120 (2014).
- [8] E. Canovi, P. Werner, and M. Eckstein, First-order dynamical phase transitions, Phys. Rev. Lett. 113 , 265702 (2014).
- [9] E. Canovi, E. Ercolessi, P. Naldesi, L. Taddia, and D. Vodola, Dynamics of entanglement entropy and entanglement spectrum crossing a quantum phase transition, Phys. Rev. B 89 , 104303 (2014).
- [10] G. Torlai, L. Tagliacozzo, and G. D. Chiara, Dynamics of the entanglement spectrum in spin chains, J. Stat. Mech.: Theory Exp. 2014 (6), P06001.
- [11] M. Heyl, Dynamical quantum phase transitions in systems with broken-symmetry phases, Phys. Rev. Lett. 113 , 205701 (2014).
- [12] M. Heyl, Scaling and universality at dynamical quantum phase transitions, Phys. Rev. Lett. 115 , 140602 (2015).
- [13] S. Vajna and B. D´ ora, Topological classification of dynamical phase transitions, Phys. Rev. B 91 , 155127 (2015).
- [14] S. Sharma, S. Suzuki, and A. Dutta, Quenches and dynamical phase transitions in a nonintegrable quantum Ising model, Phys. Rev. B 92 , 104306 (2015).
- [15] M. Schmitt and S. Kehrein, Dynamical quantum phase transitions in the Kitaev honeycomb model, Phys. Rev. B 92 , 075114 (2015).
- [16] J. C. Halimeh and V. Zauner-Stauber, Dynamical phase diagram of quantum spin chains with long-range interactions, Phys. Rev. B 96 , 134427 (2017).
- [17] S. A. Weidinger, M. Heyl, A. Silva, and M. Knap, Dynamical quantum phase transitions in systems with continuous symmetry breaking, Phys. Rev. B 96 , 134313 (2017).
- [18] C. Karrasch and D. Schuricht, Dynamical quantum phase transitions in the quantum Potts chain, Phys. Rev. B 95 , 075143 (2017).

and from the European Union's Horizon 2020 research and innovation programme under the Marie Skglyph[suppress] lodowskaCurie grant agreement No. 754411. A.M. and M.S. were supported by the European Research Council (ERC) under the European Union's Horizon 2020 research and innovation programme (grant agreement No. 850899).

- [19] I. Homrighausen, N. O. Abeling, V. Zauner-Stauber, and J. C. Halimeh, Anomalous dynamical phase in quantum spin chains with long-range interactions, Phys. Rev. B 96 , 104436 (2017).
- [20] B. ˇ Zunkoviˇ c, M. Heyl, M. Knap, and A. Silva, Dynamical quantum phase transitions in spin chains with long-range interactions: Merging different concepts of nonequilibrium criticality, Phys. Rev. Lett. 120 , 130601 (2018).
- [21] M. Schmitt and M. Heyl, Quantum dynamics in transverse-field Ising models from classical networks, SciPost Phys. 4 , 013 (2018).
- [22] D. Trapin and M. Heyl, Constructing effective free energies for dynamical quantum phase transitions in the transverse-field Ising chain, Phys. Rev. B 97 , 174303 (2018).
- [23] V. Gurarie, Dynamical quantum phase transitions in the random field Ising model, Phys. Rev. A 100 , 031601 (2019).
- [24] S. De Nicola, B. Doyon, and M. J. Bhaseen, Stochastic approach to non-equilibrium quantum spin systems, J. Phys. A: Math. Theor. 52 , 05LT02 (2019).
- [25] Y.-P. Huang, D. Banerjee, and M. Heyl, Dynamical quantum phase transitions in U(1) quantum link models, Phys. Rev. Lett. 122 , 250401 (2019).
- [26] M. Lacki and M. Heyl, Dynamical quantum phase transitions in collapse and revival oscillations of a quenched superfluid, Phys. Rev. B 99 , 121107 (2019).
- [27] R. Jafari, Dynamical quantum phase transition and quasi particle excitation, Sci. Rep. 9 , 2871 (2019).
- [28] M. Heyl, Dynamical quantum phase transitions: A brief survey, EPL 125 , 26001 (2019).
- [29] P. Jurcevic, H. Shen, P. Hauke, C. Maier, T. Brydges, C. Hempel, B. P. Lanyon, M. Heyl, R. Blatt, and C. F. Roos, Direct observation of dynamical quantum phase transitions in an interacting many-body system, Phys. Rev. Lett. 119 , 080501 (2017).
- [30] X.-Y. Guo, C. Yang, Y. Zeng, Y. Peng, H.-K. Li, H. Deng, Y.-R. Jin, S. Chen, D. Zheng, and H. Fan, Observation of a dynamical quantum phase transition by a superconducting qubit simulation, Phys. Rev. Applied 11 , 044080 (2019).
- [31] N. Fl¨ aschner, D. Vogel, M. Tarnowski, B. S. Rem, D.-S. L¨ uhmann, M. Heyl, J. C. Budich, L. Mathey, K. Sengstock, and C. Weitenberg, Observation of dynamical vortices after quenches in a system with topology, Nat. Phys. 14 , 265 (2018).
- [32] T. Tian, Y. Ke, L. Zhang, S. Lin, Z. Shi, P. Huang, C. Lee, and J. Du, Observation of dynamical phase transitions in a topological nanomechanical system, Phys. Rev. B 100 , 024310 (2019).
- [33] K. Wang, X. Qiu, L. Xiao, X. Zhan, Z. Bian, W. Yi, and P. Xue, Simulating dynamic quantum phase transitions in photonic quantum walks, Phys. Rev. Lett. 122 , 020501

(2019).

- [34] X.-Y. Xu, Q.-Q. Wang, M. Heyl, J. C. Budich, W.-W. Pan, Z. Chen, M. Jan, K. Sun, J.-S. Xu, Y.-J. Han, C.F. Li, and G.-C. Guo, Measuring a dynamical topological order parameter in quantum walks, Light Sci. Appl. 9 , 7 (2020).
- [35] C. Rylands and V. Galitski, Dynamical quantum phase transitions and recurrences in the non-equilibrium BCS model, arXiv:2001.10084 [cond-mat.supr-con] (2020).
- [36] J. Feldmeier, F. Pollmann, and M. Knap, Emergent glassy dynamics in a quantum dimer model, Phys. Rev. Lett. 123 , 040601 (2019).
- [37] J. C. Halimeh, D. Trapin, M. V. Damme, and M. Heyl, Local measures of dynamical quantum phase transitions (2020), arXiv:2010.07307 [cond-mat.quant-gas].
- [38] S. Bandyopadhyay, A. Polkovnikov, and A. Dutta, Observing dynamical quantum phase transitions through quasi-local string operators (2020), arXiv:2011.03906 [cond-mat.stat-mech].
- [39] J. Surace, L. Tagliacozzo, and E. Tonni, Operator content of entanglement spectra in the transverse field Ising chain after global quenches, Phys. Rev. B 101 , 241107 (2020).
- [40] S. Paeckel, T. K¨ ohler, A. Swoboda, S. R. Manmana, U. Schollw¨ ock, and C. Hubig, Time-evolution methods for matrix-product states, Ann. Phys. (N. Y). 411 , 167998 (2019).
- [41] E. H. Lieb and D. W. Robinson, The finite group velocity of quantum spin systems, Comm. Math. Phys. 28 , 251 (1972).
- [42] J. Eisert and T. J. Osborne, General entanglement scaling laws from time evolution, Phys. Rev. Lett. 97 , 150404 (2006).
- [43] G. Vidal, Classical simulation of infinite-size quantum lattice systems in one spatial dimension, Phys. Rev. Lett. 98 , 070201 (2007).
- [44] R. Or´ us and G. Vidal, Infinite time-evolving block decimation algorithm beyond unitary evolution, Phys. Rev. B 78 , 155117 (2008).
- [45] L. Piroli, B. Pozsgay, and E. Vernier, Non-analytic behavior of the Loschmidt echo in XXZ spin chains: Exact results, Nucl. Phys. B. 933 , 454 (2018).
- [46] See Supplemental Material, which cites Refs. [47] and [48].
- [47] G. M. Crosswhite and D. Bacon, Finite automata for caching in matrix product algorithms, Phys. Rev. A 78 , 012356 (2008).
- [48] G. Mussardo, Statistical Field Theory: An Introduction to Exactly Solved Models in Statistical Physics , Oxford Graduate Texts (OUP Oxford, 2009).
- [49] P. Calabrese, F. H. L. Essler, and M. Fagotti, Quantum quench in the transverse field Ising chain: I. time evolution of order parameter correlators, J. Stat. Mech.: Theory Exp. 2012 (07), P07016.
- [50] D. Trapin, J. C. Halimeh, and M. Heyl, Unconventional critical exponents at dynamical quantum phase transitions in a random Ising chain, arXiv:2005.06481 [condmat.stat-mech] (2020).
- [51] E. J. Bergholtz, J. C. Budich, and F. K. Kunst, Exceptional topology of non-Hermitian systems, arXiv:1912.10048 [cond-mat.mes-hall] (2019).
- [52] Y. Ashida, Z. Gong, and M. Ueda, Non-Hermitian physics (2020), arXiv:2006.01837 [cond-mat.mes-hall].

## Supplementary material for 'Entanglement view of dynamical quantum phase transitions'

In this supplement we present further details on the analytical iMPS ans¨ atze for p- and eDQPTs discussed in the main text, as well as additional results for the Ising and XXZ models. We also demonstrate the deformation of eDQPTs into pDQPTs upon varying the parameters of the quench Hamiltonian and explore quenches where both precession and entanglement generation are significant, revealing the complex phenomenology which arises in the intermediate regime between the contrasting pDQPT and eDQPT limits.

## I. CANONICAL FORM OF MPS

The iMPS representation of a many-body state is encoded in a tensor A σ ij carrying a physical index σ = ↑ , ↓ and bond indices i, j = 1 , . . . , χ . Such representation is non-unique due to gauge invariance : for any invertible χ × χ matrix G , the matrix ˜ A σ ij = [ GA σ G -1 ] ij provides an equivalent representation of the state. This gauge freedom may be fixed by imposing additional conditions on the matrix A . A particularly convenient gauge fixing is given by the canonical form, which requires the tensor A to be represented as A σ ij = Λ i Γ σ ij [43, 44]: the diagonal matrix Λ ii contains the singular values { √ λ i } of the Schmidt decomposition across a bond, whose squares yield the entanglement spectrum, while the tensor Γ σ ij carries a physical index, so that its elements can be seen as (not necessarily normalized) spinors. The canonical form tensors Λ and Γ satisfy a set of constraints given in the main text.

As discussed in the main text, the canonical form reveals the contributions of entanglement and precession, providing a tool to understand the driving physical mechanisms of DQPTs and how these are reflected in the behavior of other quantities. The structure encoded in a canonical form iMPS can be conveniently visualized by means of an automaton picture [47], shown in Fig. S1 for a χ = 2 iMPS state.

Each circle in Fig. S1(a) corresponds to a site and carries a physical vector Γ σ ij , denoted as | Γ ij 〉 in the figure. The arrows give the allowed choices for the vector at the following site, weighted by the singular values √ λ i . In the case when λ 1 glyph[greatermuch] λ 2 that will be relevant for pDQPTs below, the dominant contribution is given by the | Γ 11 〉 state, as each inclusion of | Γ 12 〉 and other components is suppressed by at least a factor √ λ 2 /λ 1 glyph[lessmuch] 1. Thus in this limit the cartoon picture of the quantum state can be visualized as a dilute set of inclusions of | Γ 12 〉 , | Γ 21 〉 , and | Γ 22 〉 into the dominant product state ⊗ i | Γ 11 〉 . (Due to the orthogonality catastrophe, the overlap of the MPS state with the ⊗ i | Γ 11 〉 state vanishes in thermodynamic limit provided λ 1 &lt; 1.)

In contrast, if one has λ 1 ≈ λ 2 (recall that λ 1 &gt; λ 2 by assumption), which is the relevant case for eDQPTs, the automaton provides a very different picture of the quantum state. The closeness of two singular values entails that a large number of excitations on top of the product state ⊗ i | Γ 11 〉 i can be created at a small cost. Moreover, the avoided crossing in λ 's implies that the formerly sub-

Figure S1. (a) Automaton representation of an iMPS with χ = 2 written in the canonical form. Dark solid arrows carry a weight √ λ 1 whereas light dashed arrows carry a weight √ λ 2 ≤ √ λ 1 . (b) The iMPS can be seen as a linear superposition of all possible product states generated by the automaton.

<!-- image -->

leading component of the MPS state will become dominant after such avoided crossing. Thus, at the points of avoided crossings a broad rearrangement of the quantum state is happening, whereby formerly subleading components become dominant.

## II. ANALYTICAL pDQPT ANSATZ

## A. Effective Hamiltonian

To illustrate pDQPTs, we construct an analytical ansatz capable of capturing the relevant physics. We consider quenches in the Ising model; the time-evolved state in the Schr¨ odinger picture is then

<!-- formula-not-decoded -->

with H given by (4). Since pDQPTs are dominated by single-spin terms, it is convenient to split the Hamiltonian between the free-precessing part, H 0 = ∑ i [ h x σ x i + h z σ z i ], and the interaction, V = J ∑ i σ z i σ z i +1 . To account for the leading role of precession, we rewrite the dynamics in the rotating frame with respect to H 0 . In the rotating frame, operators evolve according to

<!-- formula-not-decoded -->

where O is the (time-independent) Schr¨ odinger picture operator. Enforcing that expectation values be invariant upon switching to the rotating frame, 〈 ˜ ψ ( t ) | ˜ O ( t ) | ˜ ψ ( t ) 〉 = 〈 ψ ( t ) | O | ψ ( t ) 〉 , defines the rotating-frame state,

<!-- formula-not-decoded -->

in terms of the Sch¨ odinger picture state | ψ ( t ) 〉 . The equation of motion satisfied by | ˜ ψ ( t ) 〉 is readily obtained by differentiating (9):

<!-- formula-not-decoded -->

where

<!-- formula-not-decoded -->

The coefficients s x ( t ) , s y ( t ) , s z ( t ) are provided in the main text. One then has | ˜ ψ ( t ) 〉 = U ˜ V ( t ) | ψ 0 〉 , where U ˜ V ( t ) = T e -i ∫ t 0 ˜ V ( t ′ )d t ′ , so that the time-evolved state in the Schr¨ odinger picture can be rewritten as

<!-- formula-not-decoded -->

As it stands, Eq. (12) is an exact reformulation of the dynamics and is not amenable to direct evaluation. In order to obtain a closed-form approximation, we restrict our attention on quenches from the |↓〉 product state, which is the ferromagnetic ground state for h x = 0 , h z &gt; 0 , J &lt; 0. We consider the precession-dominated regime h x glyph[greatermuch] h z , J , relevant for pDQPTs. In this regime, the entanglement growth along the z -axis is initially small, as demonstrated by comparing the connected correlations C xx , C yy , C zz defined as C ab = 〈 σ a i σ b i +1 〉-〈 σ a i 〉〈 σ b i 〉 . Furthermore, terms featuring σ y are dominant with respect to those featuring σ x due to | s y | &gt; | s x | . We take advantage of these observations to replace the operators σ x , σ z in (11) by their expectation values, which in the present regime are well-approximated by free precession:

<!-- formula-not-decoded -->

This approximation yields ˜ V ( t ) ≈ ˜ V eff ( t ) = ∑ i [ J eff ( t ) σ y i σ y i +1 + h eff ( t ) σ y i ] up to an unimportant constant term, with

<!-- formula-not-decoded -->

<!-- formula-not-decoded -->

The approximate form of the operator ˜ V ( t ) obtained above is still time-dependent, but is now made up of commuting terms, such that

<!-- formula-not-decoded -->

where tH eff ( t ) = Ja ( t ) ∑ i σ y i σ y i +1 + Jb ( t ) ∑ i σ y i , and Ja ( t ) = ∫ t 0 J eff ( t ′ )d t ′ , Jb ( t ) = ∫ t 0 h eff ( t ′ )d t ′ are explicitly given in the main text. At each time t , the time-evolved state can thus be equivalently obtained from an effective classical Hamiltonian H eff ( t ).

## B. Exponentiation of the effective Hamiltonian

The effective Hamiltonian H eff is made up of commuting terms, so that its matrix exponential can be trivially factorized as a product over sites,

<!-- formula-not-decoded -->

One then inserts resolutions of the identity over pairs of neighboring sites, ✶ i,i +1 = ✶ i ⊗ ✶ i +1 with ✶ i = P y i + P -y i , where we introduced the projectors on the y -eigenstates, P ± y i ≡ |± y 〉 i 〈± y | i , σ y |± y 〉 = ±|± y 〉 . This yields

<!-- formula-not-decoded -->

The sum of terms resulting from (18) can be reproduced by the χ = 2 MPO e -itH eff = ∏ i U i with

<!-- formula-not-decoded -->

The exponentiation of the effective classical Hamiltonian H eff is reminiscent of the transfer matrix method used to solve classical Ising models [48], with the difference that the matrix elements in the present case are operators rather than scalars.

Substituting the above in Eq. (12) and applying it to the ↓ initial state leads to the pDQPT MPS ansatz discussed in the main text. To bring this to canonical form, one computes the transfer matrix T ( ik )( jl ) = ∑ σ A σ ij A σ ∗ kl , where ( a, b ) denotes a merging of the a, b virtual indices. From the transfer matrix we compute the leftand rightdominant eigenvectors V L , V R that correspond to the eigenvalue with largest magnitude. These eigenvectors are reshaped as χ × χ matrices and decomposed as V L = Y † Y , V R = XX † [44]. Finally, the matrix Λ is obtained from the singular value decomposition of the matrix Y T X = U Λ V . The explicit calculation yields Λ = diag( | cos( Ja ( t )) | , | sin( Ja ( t )) | ). The tensor Γ given in Eq. (5) is then obtained from Γ σ ij = ∑ kl [ V X -1 ] ik A σ kl [( Y T ) -1 U ] lj [44].

## C. Evolution of the overlaps

In the present regime, one has λ 2 glyph[lessmuch] λ 1 when the DQPT occurs (see Fig. 1), so that the crossing of the transfer matrix eigenvalues is predominantly driven by the precession of the elements of Γ. The MPS ansatz shows that, to an excellent approximation, Γ σ ij are normalized spinors; thus, the precession nature of pDQPTs can further understood by considering their evolution on the Bloch sphere, shown in Fig. S2. The dominant

Figure S2. Evolution of the vectors Γ σ 11 (blue line), Γ σ 12 = e iφ Γ σ 21 (red line), obtained from the analytical pDQPT ansatz (5), on the Bloch sphere. Since λ 1 glyph[greatermuch] λ 2 , Γ σ 11 provides the dominant contribution to the MPS, with Γ σ 12 , Γ σ 21 giving subleading corrections (see Fig. S1). The vector Γ σ 11 is initialized as |↓〉 , while Γ σ 12 initially corresponds to |↑〉 . In the dynamics of Fig. 1(b)-(d), these vectors perform simultaneous precession on the Bloch sphere. The precession of the dominant component away from the initial state gives rise to a pDQPT; the position of each vector on the respective trajectory at the time of the DQPT is marked by a red dot. In the vicinity of a pDQPT, Γ σ 11 is nearly orthogonal to the initial state, so that | o 11 | approaches a minimum, while Γ σ 12 is closest to the initial state and | o 12 | = | o od | achieves a maximum.

<!-- image -->

component Γ σ 11 , which at t = 0 corresponds to the initial |↓〉 product state, and the excitations Γ σ 12 = e iφ Γ σ 21 , which initially correspond to the |↑〉 state (orthogonal to the initial state), perform simultaneous precession, with DQPTs occurring when Γ σ 11 ∼ |↑〉 , Γ σ 12 ∼ |↓〉 . The semiclassical nature of this driving mechanism and the role of excitations can be further understood by means of the automaton picture discussed in Fig. S1.

## III. ANALYTICAL eDQPT ANSATZ

## A. MPO form of the time evolution operator

To construct an ansatz for eDQPTs, where interactions are expected to play a dominant role, we approximate the time-evolution operator by the second-order Trotter slicing U ( t ) ≈ U L ( t/ 2) U I ( t ) U L ( t/ 2) with

<!-- formula-not-decoded -->

where U L captures local rotations while U I describes interactions. The interaction term is diagonal in the σ z basis, so that it admits the exact χ = 2 MPO represen- tation

<!-- formula-not-decoded -->

similarly to the case discussed for the pDQPT ansatz. The full state can be readily obtained by applying the rotations U L ( t/ 2) to the local states in (21), leading to the MPS ansatz (6). The corresponding canonical form for general J, h x , h z can then be analytically obtained as discussed for the pDQPT ansatz. The analytical form of the tensor Γ reveals a complicated structure, reflecting the involved behavior of the overlaps observed in Fig. 1(e), while the entanglement spectrum { λ i } , obtained by squaring the diagonal of Λ, takes the relatively simple form provided in the main text.

## B. Canonical form of the MPS ansatz for the classical Ising model

The tensor Γ for the eDQPT ansatz can be greatly simplified in the limit h x = 0, which yields

<!-- formula-not-decoded -->

where the rotation e -ith z σ z is applied to each of the spinor states in the matrix. In this limit, the singular values reduce to √ λ 1 , 2 = {| cos( Jt ) | , | sin( Jt ) |} and the MPS ansatz becomes an exact representation of the timeevolved state. Contraction with the complex-conjugated initial state |→〉 gives the overlap matrix

<!-- formula-not-decoded -->

In spite of its apparent simplicity, this special case provides useful insights into e- and pDQPTs. In this limit, the dynamics of the state is fully factorized into the harmonic oscillations of the entanglement spectrum, with frequency J , and the free precession of the states in Γ, with frequency h z . The eigenvalues of the fidelity transfer matrix are given by

<!-- formula-not-decoded -->

DQPTs arise whenever the difference in magnitude between e 1 and e 2 vanishes, ∆ e = | e 1 | - | e 2 | = 0. This corresponds to the condition

<!-- formula-not-decoded -->

This condition is satisfied at the times t = ( n + 1 / 2) π/ (2 J ) when cos(2 h z t ) + 2 e 4 iJt -1 is real-valued and negative. It can be readily seen that these times

Figure S3. Local magnetization in the direction of the initial state and mutual information for DQPTs in the quantum Ising model. DQPTs are marked by a dashed vertical line. Panel (a) shows a pDQPTs for the quench of Fig. 1(b)(d); in agreement with the discussion of the main text, this is accompanied by 〈 σ z ( t DQPT ) 〉 ≈ -〈 σ z (0) 〉 , since the dominant vector Γ σ 11 at this time has precessed maximally away from the initial state, while the mutual information shows a simple pattern of slow, approximately monotonic growth. In contrast, at the eDQPTs of panel (b), corresponding to the quench of Fig. 1(c)-(e), the magnetization takes a value closest to zero, while the mutual information displays a complex pattern of correlations where two-body terms and I 1 , 2;4 reach a minimum while I 1 , 2;3 attains a plateau. Moreover, all MIs at the eDQPT are an order of magnitude larger compared to the pDQPT case.

<!-- image -->

corresponds to crossings in the entanglement spectrum, a hallmark of eDQPTs. However, Eq. (25) is also satisfied whenever cos( h z t ) = 0. This condition corresponds to points of vanishing overlap | o 11 | , given in (23), which are associated to pDQPTs. It can then be shown that there are no further solutions to Eq. (25). Thus, in the present limit, DQPTs can be individually attributed to either precession or entanglement crossings, providing quintessential examples of p- and eDQPTs respectively.

This sheds light on the more general behavior observed when adding a finite h x such that the model is no longer solvable. In this case, the dynamics of overlaps and entanglement does not factorize into independent oscillations and depends on the values of all couplings. However, while smooth evolution of entanglement without particular signatures is still observed for pDQPTs, the entanglement avoided crossings which drive eDQPTs also affect the overlaps, inducing a complex behavior associated with a global rearrangement of the quantum state; see Fig. S1 and Fig. S5 below for further details.

Figure S4. Entanglement spectrum and overlaps for DQPTs in the XXZ model. Panel (a) corresponds to Fig. 2(a) and shows pDQPTs; these are accompanied by a minimum of | o 11 | , while the entanglement spectrum displays a gap and no particular signatures at DQPTs. Panel (b) shows the eDQPTs of Fig. 2(b); in this case, DQPTs occur in the vicinity of an avoided crossing in the entanglement spectrum, with the overlaps also displaying avoided crossing behavior.

<!-- image -->

## IV. CONTRASTING AND CONNECTING eDQPTs AND pDQPTs

## A. Experimental Signatures in the Ising Model

The different nature of pDQPTs and eDQPTs was first illustrated in Fig. 1 by contrasting the behavior of entanglement and overlaps in the quantum Ising model. We then discussed how this difference is reflected in experimentally measurable quantities considering the XXZ model. In Fig. S3 we additionally show that the same features can also be observed for the Ising model, considering the quenches of Fig. 1; the behavior of the magnetization in the direction of the initial state and of the mutual information between different subsystems shows pronounced differences in the two cases, which can be understood in light of the proposed physical pictures.

## B. Entanglement and Overlaps in the XXZ Model

The patterns in the entanglement spectrum and overlaps corresponding to p- and eDQPTs are not restricted to the Ising model. To illustrate this, in Fig. S4 we show the entanglement spectrum and overlaps for the XXZ model, considering the quenches of Fig. 2. The observed behavior is in agreement with the general discussion of the main text, with pDQPTs corresponding to minima in | o 11 | while eDQPTs are associated with entanglement avoided crossings.

Figure S5. Deformation of eDQPTs into pDQPTs. We choose the initial state |→〉 and consider dynamics under the Ising Hamiltonian (4), keeping h x = 0.1 constant and varying the values of h z , J . We perform iTEBD truncating √ λ i &lt; 10 -9 , which leads to a maximum bond dimension χ = 12 for the present quenches. (a) h z = 0 . 15, J = 1; this is the same quench as Fig. 1(c)-(e), but here we show the full entanglement spectrum and extend the time range so as to include a second DQPT. We observe two eDQPTs, characterized by entanglement avoided crossings and a complex behavior of the overlaps | o 11 | , | o od | , which approach each other at the DQPTs. This is also reflected in the magnetization 〈 σ x 〉 approaching zero and the complex pattern displayed by the mutual information. (b) h z = 0 . 35, J = 0 . 9; as h z is increased and J is reduced, the second entanglement avoided crossing is widened and the behavior of the second DQPT shifts away from the avoided crossing in entanglement spectrum. (c) h z = 1 . 15, J = 0 . 5; precession plays now an important role, and DQPTs manifest features of both e- and pDQPTs: they are associated with minima in | o 11 | , which are however far from zero, and occur to the two sides of an entanglement avoided crossing, with observables suggesting a predominance of eDQPT nature. (d) h z = 1 . 65, J = 0 . 25; as the field begins to dominate the dynamics, the entanglement gap widens and DQPTs start to acquire a pDQPT character, occurring near the minima of | o 11 | . (e) h z = 1 . 95, J = 0 . 1; in the strong-field regime, one retrieves two clean examples of pDQPTs: these are revealed by deep minima in | o 11 | and the large gap in the entanglement spectrum. Furthermore, in agreement with the general features of pDQPTs, the magnetization at DQPTs is approximately opposite to its initial value and the mutual information shows slow, featureless growth.

<!-- image -->

## C. Deforming eDQPTs into pDQPTs

The concepts of pDQPTs and eDQPTs introduced in the main text provide two limiting cases in which DQPTs can be clearly ascribed to different physical mechanisms. For generic DQPTs, the situation can however be more involved, as both precession and entanglement production mechanisms might play a significant role. Part of the complex phenomenology reported in the literature might thus originate from the interplay of the discussed classes of DQPTs.

To illustrate this, we show how eDQPTs can be deformed into pDQPTs as a function of the Hamiltonian parameters by considering the Ising model. In Fig. S5(a), we begin by considering the same quench as in Fig. 1(c)-

(e) using the initial state |→〉 . As the longitudinal field h z is increased at the expense of the interaction strength J , precession also becomes important and DQPTs shifts away from the avoided crossing in the entanglement spectrum, see panel (b). After a complex intermediate regime where DQPTs show a hybrid behavior, panel (c), they gradually acquire the characteristics of pDQPTs, as shown in panel (d). Finally, pDQPT features become very pronounced in the strong-field regime, as demonstrated in panel (e).

## D. Reversing the Quench Direction

Below we consider the sensitivity of the nature of DQPTs to a reversal in the quench direction. We use

Figure S6. The panels show, top to bottom: fidelity density f , x -magnetization 〈 σ x 〉 and mutual information I for the quench from the |→〉 product state evolved with the Ising Hamiltonian with J = 0 . 1, h x = 0 . 15, h z = 1. The inset further shows the entanglement spectrum. The observed phenomenology is consistent with a pDQPT.

<!-- image -->

a pDQPT example for the Ising model discussed in the main text. The system is initialized in the |↓〉 product state, corresponding to the ground state of the Ising Hamiltonian [Eq. (4) in the main text] with J &lt; 0, h x = 0, h z &gt; 0. The time evolution is performed using the Ising Hamiltonian with J = 0 . 1, h x = 1, h z = 0 . 15.

The initial state in the above quench corresponds to the ferromagnetic phase of the Ising model with Z 2 symmetry being broken by the longitudinal field, while the Hamiltonian that governs the time evolution has a paramagnetic ground state. In order to reverse the quench direction, we start with a ground state of paramagnettype, the |→〉 product state. (Note that we checked that using the ground state of the Hamiltonian with finite but small values of J , h z does not not lead to qualitative differences.)

One option is to quench to the ferromagnetic phase with weak Z 2 symmetry breaking. This amounts to performing the time evolution with a classical Hamiltonian where J is dominant, for instance J = -1, h x = 0, h z = 0 . 1. Such quench leads to eDPQTs, as we demonstrated in the main text and above. Another possibility is to quench into the ferromagnetic phase with strongly broken Z 2 symmetry, when h z glyph[greatermuch] J is the dominant term in the Hamiltonian. Such quench results in pDQPT physics, see Fig. S6.

Thus, we conclude that reversing the quench direction can result in either eDQPT or pDQPT physics, depending on the relative strength of spin-spin interactions and single-spin terms in the Ising model; this is in agreement with the general picture discussed in the main text.

Figure S7. Extended time evolution for the quenches of Fig. 1(d) [panels (a)-(c)] and Fig. 1(e) [panels (d)-(f)]. We perform iTEBD time evolution truncating √ λ &lt; 10 -9 , which leads to a maximal bond dimension χ = 19 and χ = 28 respectively. The analytical ans¨ atze introduced in the main text (dashed blue lines), in spite of their much smaller bond dimension χ = 2, qualitatively capture the behavior of the DQPTs, predicting their occurrence and location with good accuracy. This shows that in the present cases, which provide prototypical examples of p- and eDQPTs respectively, it is sufficient to well-approximate the behavior of the dominant two components of the entanglement spectrum (b), (e) and the dominant and off-diagonal overlaps (c), (f) to capture the behavior of DQPTs.

<!-- image -->

Figure S8. Comparison of the fidelity density obtained from the full time evolved state (full lines) and truncating the timeevolved state to a χ = 2 MPS (dashed lines) for the quenches shown in (a) Fig. 1(d) and (b) Fig. 1(e). The fidelity obtained from the truncated state is in good agreement with the numerically exact result and correctly captures the occurrence of DQPTs, approximately predicting their location. This shows that in the present cases, where either precession or entanglement production dominates, a χ = 2 approximation of the state is capable of capturing DQPTs.

<!-- image -->

## V. DQPTS OF STRONGLY ENTANGLED STATES

Considering the quantum Ising model, we have shown how χ = 2 analytical ans¨ atze can be used to reveal the physics underlying DQPTs, leading to the definition of the limiting cases of p- and eDQPTs. The ans¨ atze are capable to correctly capture DQPTs even though the numerics we benchmark them against have larger bond di-

Figure S9. Dynamics of the initial product state ⊗ i |↓〉 evolved with the Ising Hamiltonian (4) with couplings J = h x = h z = 1. We perform iTEBD truncating √ λ i &lt; 10 -9 , which results in a maximum bond dimension χ = 24 at t = 2. In this regime, precession and entanglement production are both significant, so that pDQPT and eDQPT characters are blurred. (a) A DQPT occurs in the fidelity density (full line); however, in contrast with Fig. S8, the approximate fidelity obtained by truncating the time-evolved state to χ = 2 (dashed line) fails to predict a DQPT, showing that for this quench it is necessary to retain λ i with i &gt; 2. The DQPT occurs (b) following an avoided crossing in the entanglement spectrum, and (c) at a minimum of | o 11 | and maximum of | o od | ; these findings illustrate that both p- and eDQPT driving mechanisms are simultaneously at play. In contrast to the pure pDQPT case, the overlaps show a complicated time-evolution. In contrast to the pure eDQPT case, the DQPT occurs when | o 11 | and | o od | are maximally different, rather than comparable. The behavior of both (d) the magnetization in the direction of the initial state and (e) the mutual information suggest a prevalence of eDQPT character. The entanglement entropy (f) shows rapid, nearly featureless growth.

<!-- image -->

mension. The question then naturally arises as to the range of applicability of χ = 2 approximations. We conjecture this is closely related to the existence of a dominant driving mechanism for DQPTs for a given quench.

In Fig. S7, we show that the ans¨ atze are capable to capture DQPTs for the quenches in Fig. 1(d) and (e), which provide prototypical examples of p- and eDQPTs, also at later times. In spite of the numerically exact iTEBD dynamics having even larger bond dimension [ χ = 19 for (a), (b), (c) and χ = 28 for (e), (f), (g)], the χ = 2 ans¨ atze introduced in the main text still approximately predict the location of DQPTs. This can be attributed to the good approximation the ans¨ atze yield to the dominant elements of the entanglement spectrum, (b) and (e), and the dominant overlaps, (c) and (f). The fact that for the quenches of Fig. 1(d)-(e) DQPTs are predominantly determined by the top 2 × 2 component of the state can be further demonstrated by truncating the full iTEBD time-evolved state to χ = 2, which is equivalent to discarding λ i for i &gt; 2 and renormalizing the state. Fig. S8 shows that this approximate state is sufficient to capture DQPTs, even though the full time-evolution requires significantly larger bond dimension.

Finally, in Fig. S9 we consider a parameter range where both mechanisms are comparable, so that the distinction between pDQPTs and eDQPTs is blurred. In this case, a truncation of the MPS state obtained from iTEBD evolution with χ = 24 to χ = 2 leads to a disappearance of the DQPT. In contrast, in Fig. S7(b), where the eDQPT mechanism dominates, we saw a χ = 2 approximation correctly capturing DPQTs for a state with χ = 28. Thus, we attribute the failure of the truncated χ = 2 state in capturing the DQPT to the intermediate character of the DQPT, which is driven by both precession and entanglement mechanisms.