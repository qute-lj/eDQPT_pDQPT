# PRL 2021 ESQPT 投影与稳定性扫描结果（2026-03-12）

## 这份记录做了什么

在 `PRL 2021` 这条线中，我们额外做了两步：

1. `quench-energy projection`
   - 把给定 quench 初态写到后淬火哈密顿量的本征态基底中。
   - 计算权重 `p_n = |<E_n | psi_0>|^2`。
   - 比较这些谱权重与 `ESQPT` 候选能量的相对位置。

2. `finite-size stability scan`
   - 改变 `L` 和边界条件。
   - 追踪候选能量密度 `E_c / L` 是否稳定。

## 这里的读法

第一步回答的问题是：

- 当前这个 quench 的谱权重，到底有没有压在 `ESQPT` 候选能量附近？

第二步回答的问题是：

- 某个候选能量是有限尺寸假象，还是在改 `L` 和 boundary 后仍然大体稳定？

## 本次得到的主要结论

### 1. `IPR` 候选通常比 density / observable 候选更接近 quench 的实际谱权重

对 `L = 8`, open boundary 的四个代表协议：

- `ising_p`
  - `density_nearest3_weight = 4.33e-4`
  - `observable_nearest3_weight = 3.26e-33`
  - `ipr_nearest3_weight = 1.93e-1`

- `ising_e`
  - `density_nearest3_weight = 4.70e-3`
  - `observable_nearest3_weight = 6.08e-3`
  - `ipr_nearest3_weight = 2.38e-2`

- `xxz_p`
  - `density_nearest3_weight = 2.39e-5`
  - `observable_nearest3_weight = 2.39e-5`
  - `ipr_nearest3_weight = 5.92e-2`

- `xxz_e`
  - `density_nearest3_weight = 6.79e-4`
  - `observable_nearest3_weight = 2.35e-3`
  - `ipr_nearest3_weight = 7.50e-2`

一个直接观察是：

- 在这批有限尺寸扫描里，`IPR` 候选能量附近往往承载了比 density / observable 候选更高的 quench 谱权重。

### 2. 周期边界下的 `IPR` 候选能量密度最稳定

对 `L = 4, 6, 8` 的扫描：

- `ising_e`, periodic:
  - `ipr_energy_per_site_span = 6.18e-11`

- `xxz_p`, periodic:
  - `ipr_energy_per_site_span = 1.13e-8`

- `xxz_e`, periodic:
  - `ipr_energy_per_site_span = 1.59e-5`

相比之下：

- density 候选常常有明显 boundary sensitivity
- observable 候选的漂移通常更大

因此在当前实现里，更值得优先关注的是：

- `IPR-based ESQPT proxy`

而不是先把 density 或 observable 候选直接当作最终结论。

## 解释边界

这批结果只能支持下面这种说法：

- 某些有限尺寸谱结构候选，与 quench 的谱权重分布更接近，且对 `L / boundary` 更稳

这批结果**不能**直接支持下面这种说法：

- `eDQPT = ESQPT`
- 或者 “已经证明某个 DQPT cusp 就是 ESQPT”

## 对后续工作的启发

若继续往前走，最合理的优先顺序是：

1. 先把 `IPR` 候选当作主代理量
2. 再把时间域的 `DQPT cusp`、熵增长、磁化行为与该代理量逐一对照
3. 最后再讨论是否存在 `eDQPT / pDQPT <-> ESQPT` 的稳定映射

## 对应输出文件

- `outputs/prl2021_ising_p_projection_summary.md`
- `outputs/prl2021_ising_e_projection_summary.md`
- `outputs/prl2021_xxz_p_projection_summary.md`
- `outputs/prl2021_xxz_e_projection_summary.md`
- `outputs/prl2021_ising_p_stability_summary.md`
- `outputs/prl2021_ising_e_stability_summary.md`
- `outputs/prl2021_xxz_p_stability_summary.md`
- `outputs/prl2021_xxz_e_stability_summary.md`
