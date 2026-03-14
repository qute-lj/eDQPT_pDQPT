# eDQPT / pDQPT 与 ESQPT 的关系调研（2026-03-12）

## 问题

你关心的问题是：已有文献是否不仅讨论 `DQPT <-> ESQPT`，还更细化到 `eDQPT / pDQPT <-> ESQPT` 的对应关系。

## 快速结论

1. `DQPT <-> ESQPT` 的联系已经有较系统的理论与实验工作，尤其在集体模型（LMG/fully-connected Ising）和 spinor BEC 方向。
2. 但在我检索到的一手论文中，尚未看到把 De Nicola 2021 的 `pDQPT/eDQPT` 分类，直接嵌入或一一映射到 ESQPT 框架的“标准共识论文”。
3. 当前最接近的桥接路径是：
   - 先用 `DPT-I / DPT-II` 与 ESQPT 建立对应（Corps/Relaño/合作者系列），
   - 再尝试把 `pDQPT/eDQPT` 投影到这些动力学相区（这一步目前更像研究机会，而非已有定论）。

## 关键文献与信息

### A. eDQPT / pDQPT 的来源（分类基线）

- De Nicola, Michailidis, Serbyn, PRL 126, 040602 (2021): 提出 precession vs entanglement DQPT 的分类框架。
  - DOI: `10.1103/PhysRevLett.126.040602`
  - 链接: <https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.126.040602>

### B. DQPT 与 ESQPT 的直接联系（主干文献）

- Corps & Relaño, PRB 106, 024311 (2022): 明确提出并分析 DPT-I / DPT-II 与 ESQPT 的联系（集体系统）。
  - DOI: `10.1103/PhysRevB.106.024311`
  - 链接: <https://journals.aps.org/prb/abstract/10.1103/PhysRevB.106.024311>

- Corps, Pérez-Fernández, Relaño, PRB 108, 174305 (2023): 通过双淬火和“relaxation time”扫描动力学相图，强调 ESQPT 将谱区分成不同动力学相。
  - DOI: `10.1103/PhysRevB.108.174305`
  - 链接: <https://doi.org/10.1103/PhysRevB.108.174305>

- Corps et al., PRR 6, 043080 (2024): 标题即“Unifying finite-temperature dynamical and excited-state quantum phase transitions”，给出更统一的连接框架。
  - DOI: `10.1103/PhysRevResearch.6.043080`
  - 链接: <https://journals.aps.org/prresearch/abstract/10.1103/PhysRevResearch.6.043080>

### C. 实验/模型侧“DQPT 对应 excited-state phase diagram”

- Tian et al., PRL 124, 043001 (2020): 实验上观察 DQPT，并与 excited-state phase diagram 对应（spinor condensate）。
  - DOI: `10.1103/PhysRevLett.124.043001`
  - 链接: <https://pubmed.ncbi.nlm.nih.gov/32058743/>

- Zhou et al., PRR 5, 013087 (2023): 在 spin-1 BEC 中讨论基态和激发态 QPT 与 DQPT 的诊断关系。
  - DOI: `10.1103/PhysRevResearch.5.013087`
  - 链接: <https://journals.aps.org/prresearch/abstract/10.1103/PhysRevResearch.5.013087>

### D. ESQPT 动力学签名（补充）

- Niu & Wang, PRA 107, 033307 (2023): 用 Loschmidt-echo spectrum 作为 ESQPT 动力学探针。
  - DOI: `10.1103/PhysRevA.107.033307`
  - 链接: <https://journals.aps.org/pra/abstract/10.1103/PhysRevA.107.033307>

- Cejnar et al., J. Phys. A 54, 133001 (2021): ESQPT 综述（含动力学后果讨论）。
  - DOI: `10.1088/1751-8121/abdfe8`
  - 链接（可访问条目）: <https://edoc.unibas.ch/entities/publication/5090e2ea-85aa-4600-afff-c55e660932b7>

## 目前“有没有直接 eDQPT/pDQPT <-> ESQPT”判断

### 已有（可以明确说有）

- 有不少工作把 DQPT（尤其 DPT-I/DPT-II、order-parameter 动力学、Loschmidt 非解析性）与 ESQPT 的临界能量或相区边界建立联系。

### 尚缺（检索中未见明确一手定论）

- 尚未检索到“以 De Nicola 2021 的 pDQPT/eDQPT 为主角，并给出与 ESQPT 一一对应、可普适复现”的主流代表论文。
- 换句话说：`DQPT <-> ESQPT` 已经有体系；`(pDQPT,eDQPT) <-> ESQPT` 目前更像 open direction。

## 对你们项目最直接的可落地思路

1. 在你们已有 `pDQPT/eDQPT` 数值通道（Ising vs XXZ/Osborne）上，定义一个“能量分辨”的后处理层，显式追踪是否跨越 ESQPT 临界能区。
2. 参考 Corps/Relaño 的做法，把动力学相区先按对称性/常数守恒结构分区，再看 `p/e` 标签在这些区中的分布与可分性。
3. 若发现稳定对应，可形成你们自己的“p/eDQPT-ESQPT bridge”贡献，这个方向现在文献空位还比较明显。

## 说明

- 本文优先使用 APS/PR 系列与 PubMed 条目做一手核对；部分补充来源用于 DOI/题录可访问性。
- 关于“pDQPT/eDQPT 与 ESQPT 已有统一定理”的表述，目前我没有找到足够证据支持，故未做正向断言。
