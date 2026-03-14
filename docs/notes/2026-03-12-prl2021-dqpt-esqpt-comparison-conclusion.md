# PRL 2021 协议下 DQPT 与 ESQPT 是否对位（2026-03-12）

## 直接结论

在当前这套有限尺寸实现里，`DQPT` 与 `ESQPT proxy` **没有表现出统一、稳健的一一对位关系**。

更准确地说：

- 四个协议都能给出明显的有限尺寸 `DQPT` rate peak。
- 但把这些协议的 quench 谱权重投影到 `ESQPT` 候选能量后，只有 `ising_p` 显示出相对强的局部重叠。
- 其余三个协议虽然也有 `DQPT` 峰，但和 `ESQPT` 候选的重叠明显更弱。

因此当前最稳妥的说法是：

- `DQPT` 和 `ESQPT proxy` 在这里存在**协议依赖的、部分性的联系**
- 但**不存在一个普适的“DQPT cusp 就对应 ESQPT”结论**

## 支撑这条结论的最关键数字

以下结果都来自 `L = 8`, open boundary 的 finite-size comparison：

### `ising_p`

- `dqpt_peak_time = 1.5`
- `best_esqpt_overlap = ipr`
- `best_esqpt_nearest3_weight = 0.1926`
- `best_esqpt_energy = -0.4723`
- `mean_energy = -0.5000`

这是四个协议里最接近“对位”的一个：

- DQPT 峰清楚
- quench 平均能量和最佳 ESQPT proxy 能量很接近
- 邻域谱权重也显著更大

### `ising_e`

- `dqpt_peak_time = 1.1`
- `best_esqpt_overlap = ipr`
- `best_esqpt_nearest3_weight = 0.0238`
- `best_esqpt_energy = 8.2227`
- `mean_energy = 0.8000`

这里 DQPT 明确存在，但 ESQPT proxy 对位明显弱：

- 最佳 proxy 能量远高于 quench 平均能量
- 附近谱权重也不大

### `xxz_p`

- `dqpt_peak_time = 1.5`
- `best_esqpt_overlap = ipr`
- `best_esqpt_nearest3_weight = 0.0592`
- `best_esqpt_energy = 15.0340`
- `mean_energy = 7.1000`

### `xxz_e`

- `dqpt_peak_time = 2.9`
- `best_esqpt_overlap = ipr`
- `best_esqpt_nearest3_weight = 0.0750`
- `best_esqpt_energy = 8.0882`
- `mean_energy = 4.5000`

这两个 XXZ 协议都显示：

- DQPT 峰存在
- 但最佳 ESQPT proxy 与 quench 平均能量并不贴合
- 对位强度明显弱于 `ising_p`

## 进一步观察

另一个重要结果是：

- 对 `L / boundary` 最稳定的 ESQPT 候选几乎总是 `IPR` 候选

所以若后续继续讨论 `DQPT <-> ESQPT`，最合理的路线是：

- 不去追 density 候选或单个 observable 候选
- 优先拿 `IPR-based ESQPT proxy` 与时间域 DQPT 现象对照

## 当前最稳妥的物理论断

在这套实现里，`PRL 2021` 的 DQPT 现象更像是：

- 可以在某些协议上与稳定的谱结构代理量产生联系
- 但这种联系不是普适的一一映射

换句话说：

- **有关系，但不是严格对位**
- **最强的局部证据出现在 `ising_p`**
- **`eDQPT` 协议并没有显示出更强的 ESQPT 对位**

## 对应输出文件

- `outputs/prl2021_ising_p_comparison_summary.md`
- `outputs/prl2021_ising_e_comparison_summary.md`
- `outputs/prl2021_xxz_p_comparison_summary.md`
- `outputs/prl2021_xxz_e_comparison_summary.md`
