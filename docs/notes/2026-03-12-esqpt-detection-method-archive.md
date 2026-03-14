# ESQPT 检测方法归档（2026-03-12）

## 这份归档的目的

这份说明用于固定本仓库后续提到的 `ESQPT detection` 到底指什么，避免把不同概念混在一起。

核心约束只有一条：

- 本仓库中的 `ESQPT` 检测，优先采用**标准的能谱诊断**。
- `eDQPT` 的纠缠谱 avoided crossing、Loschmidt cusp、熵快速增长，只能作为后续对照的动力学信号，**不直接当作 ESQPT 的定义**。

## 本仓库采用的 ESQPT 检测方法

我们采用有限尺寸哈密顿量的谱分析来给出 `ESQPT` 候选能量窗口。具体看三类量：

1. `density-of-states proxy`
   - 对角化有限尺寸哈密顿量，得到本征能量 `E_n`。
   - 用局域能级间距的倒数作为 `rho(E)` 的离散代理。
   - 若某个能量窗口出现显著的能级堆积或尖锐异常，它是 `ESQPT` 候选位置。

2. `energy-resolved observables`
   - 计算各本征态中的观测量 `⟨n|O|n⟩`，并按 `E_n` 排序。
   - 看 `⟨O⟩(E)` 在候选能量附近是否出现 cusp、斜率突变、平台切换或分支重组。
   - 对 Ising/XXZ 这类模型，优先看磁化或 staggered magnetization。

3. `state-structure diagnostics`
   - 计算计算基底下的 `IPR = Σ_i |c_i|^4` 或 `PR = 1 / IPR`。
   - 若本征态结构在候选能量附近发生明显重组，这可作为附加支持证据。

## 明确不采用的做法

下面这些信号在本仓库中**不会被单独命名为 ESQPT 检测**：

- DQPT rate function 的 cusp
- `eDQPT` 的纠缠谱 avoided crossing
- 仅凭时间演化中的熵快速增长
- 仅凭某个局域观测量在淬火过程中的过零

这些量可以与 `ESQPT` 候选能量对照，但它们本身不是这里的主判据。

## 为什么这样做

原因是概念层级不同：

- `ESQPT` 是哈密顿量激发谱在临界能量附近的奇异结构。
- `eDQPT / pDQPT` 是实时间 DQPT 的机制分类，关注的是动力学态的主导机制。

因此，把 `eDQPT` 直接叫成 `ESQPT`，物理上会过头。

## 本仓库里的具体落地方式

对于 `PRL 2021` 这条复现线，我们会增加一个独立的有限尺寸扫描脚本：

- 构造 paper 相关的 Ising 或 XXZ 有限链哈密顿量
- 对角化得到 `E_n`
- 输出 `density proxy`, `energy-resolved observable`, `IPR/PR`
- 用 markdown summary 记录候选能量与判据来源

这条线的结果应该被理解为：

- `finite-size ESQPT proxy scan`

而不是：

- `proof of ESQPT`

## 与 eDQPT / pDQPT 的关系

后续可以把两类结果并排看：

1. 时间域：
   - DQPT cusp 时间
   - `pDQPT / eDQPT / hybrid` 的动力学机制指标

2. 能量域：
   - `ESQPT` 候选能量窗口
   - 对应谱诊断和态结构诊断

如果后续发现两者之间存在稳定映射，那是新的研究结论；不是这份方法定义的前提。

## 参考入口

- Caprio, Cejnar, Iachello, Ann. Phys. 323, 1106 (2008), DOI: `10.1016/j.aop.2007.06.011`
- Stránský, Macek, Cejnar, Ann. Phys. 345, 73 (2014), DOI: `10.1016/j.aop.2014.03.006`
- Cejnar et al., New J. Phys. 23, 073039 or related review line consolidated in later review discussions
- Wang and Pérez-Bernal, Phys. Rev. A 100, 062113 (2019), DOI: `10.1103/PhysRevA.100.062113`
- Niu and Wang, Phys. Rev. A 107, 033307 (2023), DOI: `10.1103/PhysRevA.107.033307`
