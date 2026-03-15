# Osborne 2025 的 `branch/manifold` 和 De Nicola 2021 的 `pDQPT/eDQPT` 对照

## 这份 note 在做什么

这份笔记专门比较两套很容易混在一起的 DQPT 分类语言：

- Osborne, McCulloch, Halimeh (2025): `branch DQPT` 和 `manifold DQPT`
- De Nicola, Michailidis, Serbyn (2021): `pDQPT` 和 `eDQPT`

先给结论：

- 这两套语言在物理直觉上有联系
- 但它们**不是同一个分类**
- 不能直接写成 `branch = pDQPT`，也不能直接写成 `manifold = eDQPT`

## 一张表看差别

| 比较维度 | Osborne 2025: `branch/manifold` | De Nicola 2021: `pDQPT/eDQPT` |
| --- | --- | --- |
| 核心问题 | confinement / deconfinement 会怎样改变主导的 DQPT 类型？ | 一个 DQPT 到底是由什么机制驱动的？ |
| 分类对象 | total return rate 里的非解析结构 | 触发 DQPT 的动力学机制 |
| 主要诊断量 | `lambda_1^+`, `lambda_1^-`, `lambda_2^+`, `lambda_2^-` 这些 return-rate branch 的交叉 | overlap matrix 的变化，加上 entanglement spectrum 的结构 |
| 经典二分法 | `manifold crossing` 对比 `branch crossing` | `precession` 驱动对比 `entanglement` 驱动 |
| 序参量的角色 | 很核心。`manifold DQPT` 直接和序参量过零联系在一起；`branch DQPT` 可以在序参量不过零时出现 | 不是主分类标准。局域观测量可以帮助解释，但关键仍然是 overlap 和 entanglement spectrum |
| 纠缠谱的角色 | 不是这篇文章的主分类依据 | 是核心依据。`pDQPT` 对应大的纠缠谱隙；`eDQPT` 对应领先奇异值的 avoided crossing |
| 文章强调的物理图像 | confinement 会约束动力学并偏向 `branch DQPT`；deconfinement 更容易出现 `manifold DQPT` | 低纠缠、近半经典的 precession 偏向 `pDQPT`；更强的纠缠重组偏向 `eDQPT` |
| 作者特别强调的模型条件 | 他们故意选了全局对称性没有被显式打破的模型，这样 `branch/manifold` 才定义得清楚 | 不要求同样的条件；最典型的 `pDQPT` 例子之一就是带 longitudinal field 的 Ising 模型 |
| 最稳妥的简称 | 一套按 return-rate 分支结构来分的分类，用来探测 confinement | 一套按动力学机制来分的分类，用来区分半经典型和纠缠驱动型 DQPT |
| 最安全的一句话关系 | 和 `pDQPT/eDQPT` 在精神上有关，但组织方式不同、范围也不同 | 和 `branch/manifold` 在精神上有关，但绝不等价 |

## 它们哪里有联系

还是有联系的，不是完全无关。

- 在 Osborne 2025 里，`manifold DQPT` 往往和序参量过零绑在一起。
- 在 De Nicola 2021 里，`eDQPT` 对应更强的纠缠重组，不是简单的半经典自旋进动。
- 两篇文章其实都在反对一种过于简单的理解：不是所有 DQPT 都能被“序参量过零”一句话说完。

如果只看很粗的物理味道，那么 Osborne 的 `branch DQPT` 这套语言，确实和后续一些强调“超出简单序参量图像”的工作比较接近。

## 为什么不能把它们当成同一个东西

### 1. 它们分类的不是同一个对象

Osborne 2025 分的是：

- `return-rate` 非解析性是怎么组织的
- 是 `manifold crossing` 主导，还是 `branch crossing` 主导

De Nicola 2021 分的是：

- 这个 DQPT 到底是由什么机制驱动的
- 是 overlap/precession 主导，还是 entanglement 主导

所以它们不是同一个坐标轴。

换句话说，即使你已经知道一个事件是 `branch DQPT`，你也**还不知道**它在 2021 的语言里是不是更像 `pDQPT` 还是更像 `eDQPT`。你还需要额外诊断。

### 2. Osborne 2025 没有用 2021 的纠缠谱判据

2021 那篇区分 `pDQPT/eDQPT` 的核心判据是：

- 如果纠缠谱隙很大，DQPT 更像 `pDQPT`
- 如果领先奇异值在 DQPT 附近出现 avoided crossing，DQPT 更像 `eDQPT`

而 Osborne 2025 的主诊断量不是这个。

它主要看的是：

- return-rate branch 的交叉
- 序参量是否过零
- confinement 参数改变后，哪一类 DQPT 占主导

所以从定义上讲，Osborne 2025 不是在复述 `pDQPT/eDQPT`。

### 3. 两篇文章对“对称性条件”的要求不一样

Osborne 2025 明确说了，他们故意选的是全局对称性没有被显式打破的模型。原因很简单：

- 只有这样，初态才是一个真正的 manifold
- 也只有这样，`branch/manifold` 的区分才是干净可定义的

这点非常重要，因为 2021 最经典的 `pDQPT` 例子之一，正是带 transverse field 和 longitudinal field 的 Ising 模型。

而 Osborne 2025 也明确指出：

- 像这种显式打破全局对称性的模型里
- 初态 manifold 不再简并
- 于是 `branch/manifold` 这套语言就没法像他们文中那样清楚地定义

所以，最标准的 `pDQPT` 原型，本身就不自然地落在 Osborne 2025 的框架里。

## 对我们这个 repo 的直接含义

如果我们接下来是想更认真地复现 Osborne 2025，那么最稳妥的做法是：

- 主要使用 `branch/manifold` 这套语言
- 把 `pDQPT/eDQPT` 当作背景参考，而不是直接拿来贴标签
- 除非我们补上 2021 风格的诊断量，否则不要把结果直接叫成 `pDQPT` 或 `eDQPT`

最安全的工作规则可以写成两句：

- `branch/manifold` 告诉我们 return-rate 奇点是怎么组织的，以及它怎样反映 confinement
- `pDQPT/eDQPT` 告诉我们这个奇点更像是哪一种动力学机制在驱动

这两套语言可以比较，但不能默认等同。

## 如果以后想把两篇文章真正桥接起来

缺的不是一句解释，而是更多诊断量。

至少还需要：

- entanglement spectrum
- 2021 风格的 overlap 或 transfer-matrix 诊断
- 对单个 Osborne 风格事件做更细的机制分析，判断它到底更偏半经典还是更偏纠缠驱动

在这些东西没有补上之前，最诚实的表述应该是：

- Osborne 2025 和 `pDQPT/eDQPT` 这条线是相邻的
- 但它不是把旧术语换个名字重新说一遍
