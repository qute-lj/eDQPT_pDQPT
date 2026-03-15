# De Nicola 2021 Worktree 交接总结

## 1. 这份总结覆盖什么

这份文档总结当前 worktree：

- 路径：`/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/dqpt-fig1-denicola-2021`
- 主要目标：为 De Nicola et al. 2021, *Entanglement View of Dynamical Quantum Phase Transitions* 建立可复跑的 Fig. 1 / Fig. 2 数值工作流
- 当前状态：
  - Fig. 1 已经有完整的 canonical iMPS / `o` / fidelity transfer matrix 机制链实现
  - Fig. 2 已经有可复跑的 XXZ 主工作流，默认后端已经切到 `TDVP`
  - 共享 canonical 提取逻辑已经修正为从 `svd(C)` 恢复 Schmidt 谱与 Schmidt basis，不再错误读取 `diag(C)`

这个 worktree 里仍然保留了仓库原有的其他文件，例如 Osborne 2025 相关代码；但本轮工作的主线是 De Nicola 2021 的 Fig. 1 和 Fig. 2。

## 2. 当前 worktree 主要靠哪些文件运行

### 2.1 共享核心

- `src/DeNicola2021Canonical.jl`

作用：

- 生成本地 product-state spinor
- 从 MPSKit 的 canonical 对象恢复论文所需的 `Gamma`
- 构造 overlap matrix `o`
- 构造 fidelity transfer matrix
- 读取 leading transfer eigenvalues

当前最关键的修正就在这里：

- 对 `C` 做 `svd(C)`，而不是把 `diag(C)` 当成 Schmidt 值
- 从 `AC` 和 `C` 的 Schmidt basis 恢复 `A = Lambda Gamma`

### 2.2 Fig. 1 主模块

- `src/DQPTFig1DeNicola2021.jl`

作用：

- 定义 Ising 的 `pDQPT / eDQPT` preset
- 从严格 product state 出发做时间演化
- 计算 `rate`, `s1,s2`, `lambda1,lambda2`, `|o11|`, `|ood|`, `|e1|`, `|e2|`
- 生成 Fig. 1 的 TSV 与 PNG

Fig. 1 当前使用的是 `WII` time-MPO 路线。

### 2.3 Fig. 2 主模块

- `src/DQPTFig2DeNicola2021.jl`

作用：

- 定义 XXZ 的 `pDQPT / eDQPT` preset
- 计算 `rate`
- 计算前四个 entanglement weights
- 计算 overlap audit 与 transfer eigenvalue audit
- 计算 `x`-magnetization
- 计算四个 MI 曲线：`I12`, `I13`, `I12_3`, `I12_4`
- 生成 Fig. 2 的 TSV 与 PNG

Fig. 2 当前默认使用：

- backend：`tdvp_optimal`
- 配套路径：`TDVP + OptimalExpand + env reuse`

同时还保留了 `wii_svdcut` 作为对照后端。

### 2.4 入口脚本

- `scripts/reproduce_dqpt_fig1_denicola_2021.jl`
- `scripts/plot_dqpt_fig1_denicola_2021.jl`
- `scripts/reproduce_dqpt_fig2_denicola_2021.jl`
- `scripts/plot_dqpt_fig2_denicola_2021.jl`

### 2.5 主要测试

- `test/test_denicola2021_canonical.jl`
- `test/test_dqpt_fig1_denicola_2021.jl`
- `test/test_dqpt_fig2_denicola_2021.jl`
- `test/runtests.jl`

## 3. 从这个 worktree 里怎么跑

以下命令都假设当前目录已经在这个 worktree 根目录内。

### 3.1 复现 Fig. 1

```bash
julia --project=. scripts/reproduce_dqpt_fig1_denicola_2021.jl all
julia --project=. scripts/plot_dqpt_fig1_denicola_2021.jl
```

默认会生成：

- `outputs/fig1_pdqpt_denicola_2021.tsv`
- `outputs/fig1_edqpt_denicola_2021.tsv`
- `figures/report/dqpt_fig1_pdqpt_denicola_2021.png`
- `figures/report/dqpt_fig1_edqpt_denicola_2021.png`

### 3.2 复现 Fig. 2

```bash
julia --project=. scripts/reproduce_dqpt_fig2_denicola_2021.jl all --max-bond 100 --cutoff 1e-8 --backend tdvp_optimal
julia --project=. scripts/plot_dqpt_fig2_denicola_2021.jl
```

默认会生成：

- `outputs/fig2_pdqpt_denicola_2021.tsv`
- `outputs/fig2_edqpt_denicola_2021.tsv`
- `figures/report/dqpt_fig2_denicola_2021.png`
- `figures/report/dqpt_fig2_xxz_audit_denicola_2021.png`

### 3.3 eDQPT 局部细化采样

Fig. 2 现在支持局部非均匀时间网格。命令示例：

```bash
julia --project=. scripts/reproduce_dqpt_fig2_denicola_2021.jl edqpt \
  --dt 0.05 \
  --max-bond 100 \
  --cutoff 1e-9 \
  --backend tdvp_optimal \
  --refine-start 1.0 \
  --refine-stop 1.3 \
  --refine-dt 0.005
```

这类 run 主要用于更精细地看 `eDQPT` 的 avoided crossing。

## 4. 当前产出的结果文件有哪些

### 4.1 Fig. 1 主结果

- `outputs/fig1_pdqpt_denicola_2021.tsv`
- `outputs/fig1_edqpt_denicola_2021.tsv`
- `figures/report/dqpt_fig1_pdqpt_denicola_2021.png`
- `figures/report/dqpt_fig1_edqpt_denicola_2021.png`
- `docs/notes/2026-03-14-dqpt-fig1-denicola-2021-analysis.md`

### 4.2 Fig. 2 主结果

- `outputs/fig2_pdqpt_denicola_2021.tsv`
- `outputs/fig2_edqpt_denicola_2021.tsv`
- `figures/report/dqpt_fig2_denicola_2021.png`
- `figures/report/dqpt_fig2_xxz_audit_denicola_2021.png`
- `docs/notes/2026-03-14-dqpt-fig2-denicola-2021-analysis.md`

### 4.3 Fig. 2 补充诊断结果

- `outputs/fig2_edqpt_refined_twindow_denicola_2021.tsv`
- `outputs/fig2_edqpt_backend_wii_chi100.tsv`
- `outputs/fig2_edqpt_backend_tdvp_chi100.tsv`
- `outputs/fig2_edqpt_backend_tdvp_chi150.tsv`
- `outputs/fig2_edqpt_backend_tdvp_chi200.tsv`
- `figures/report/dqpt_fig2_edqpt_backend_compare_chi50.png`
- `figures/report/dqpt_fig2_edqpt_backend_compare_chi100.svg`
- `docs/plans/2026-03-14-dqpt-fig2-backend-comparison.md`

这些补充文件主要用于：

- 比较 `WII` 和 `TDVP` 的后端差异
- 验证 `chi = 100 -> 150 -> 200` 对 `eDQPT` 的影响
- 检查 `eDQPT` 在局部时间窗中的 avoided crossing 是否被粗时间步抹宽

## 5. 这些结果现在大致是什么样子

### 5.1 Fig. 1 当前结论

Fig. 1 现在不是代理图，而是直接沿论文机制链在算：

- canonical iMPS
- entanglement spectrum
- overlap matrix `o`
- truncated fidelity transfer matrix

当前最重要的数值特征：

- `pDQPT`
  - rate 峰在 `t ≈ 1.5`
  - `s2 / s1 ≈ 0.077`
  - `|o11|` 在 `t ≈ 1.55` 附近降到约 `0.146`
  - `|ood| ≈ 0.986`
  - 这条线已经能干净支持论文的“纠缠谱仍明显分离，DQPT 主要由 overlap 变化驱动”的机制解释

- `eDQPT`
  - 最像论文 Fig. 1(e) 的事件在 `t ≈ 2.35`
  - `s1 ≈ 0.746`, `s2 ≈ 0.666`
  - `|o11| ≈ 0.719`, `|ood| ≈ 0.717`
  - `|e1|` 和 `|e2|` 出现近 avoided crossing
  - 这条线已经实现了机制级复现，但时间窗里会出现多个类似事件，因此更像机制审计图，而不是逐像素复刻论文 panel

### 5.2 Fig. 2 当前结论

Fig. 2 当前主图已经是 paper-oriented workflow，不再是纯代理观测量工作流。

当前最重要的数值特征：

- `pDQPT`
  - 主峰在 `t ≈ 1.45`
  - `rate ≈ 2.14`
  - `mx ≈ -0.93`
  - `lambda1 ≈ 0.978`, `lambda2 ≈ 0.021`
  - `|o11| ≈ 0.134`, `|ood| ≈ 0.630`
  - 结论：`pDQPT` 机制已经定性复现

- `eDQPT`
  - 粗网格主 run 下，`min |lambda1 - lambda2| ≈ 0.0368 @ t ≈ 1.10`
  - 局部细化后，`min |lambda1 - lambda2| ≈ 0.0253 @ t ≈ 1.12`
  - 主 rate 峰约为 `0.390 ~ 0.392 @ t ≈ 1.20`
  - `chi = 100 -> 150 -> 200` 基本不改变关键诊断量
  - 结论：`eDQPT` 的 avoided crossing 已经可靠出现；本 worktree 里后续讨论过的剩余偏差，更多是图像细节和观测量对齐问题，不是 canonical bug 或 bond cap 不够

用户已经确认，按 paper 原图观感来看，这一版 Fig. 2 可以接受，不需要继续深挖。

## 6. 实测时间量级

以下都是在这个 worktree 里 fresh 运行得到的实际计时。

### 6.1 Fig. 1

- 主计算：
  - `julia --project=. scripts/reproduce_dqpt_fig1_denicola_2021.jl all`
  - 实测 `134.47s`
- 出图：
  - `julia --project=. scripts/plot_dqpt_fig1_denicola_2021.jl`
  - 实测 `4.11s`
- 合计量级：
  - 约 `2.3` 分钟

### 6.2 Fig. 2

- 主计算：
  - `julia --project=. scripts/reproduce_dqpt_fig2_denicola_2021.jl all --max-bond 100 --cutoff 1e-8 --backend tdvp_optimal`
  - 实测 `327.68s`
- 出图：
  - `julia --project=. scripts/plot_dqpt_fig2_denicola_2021.jl`
  - 实测 `4.97s`
- 合计量级：
  - 约 `5.5 ~ 6` 分钟

### 6.3 全套测试

- 命令：
  - `julia --project=. test/runtests.jl`
- 实测：
  - `239.55s`
- 合计量级：
  - 约 `4` 分钟

## 7. 当前验证状态

最新 fresh 验证已经通过：

```bash
julia --project=. test/runtests.jl
```

这说明当前 worktree 下：

- shared canonical helper
- Fig. 1 workflow
- Fig. 2 workflow
- plotting helpers
- output parsers

都处于可运行状态。

## 8. 现在最值得记住的几件事

1. 这个 worktree 的主成果不是“做了几张图”，而是把 De Nicola 2021 的 Fig. 1 / Fig. 2 主链条整理成了可复跑代码。
2. 共享 canonical bug 已经修掉，关键修正是：从 `svd(C)` 恢复 `Lambda` 与 Schmidt basis，而不是读 `diag(C)`。
3. Fig. 1 当前用 `WII` 路径更稳；Fig. 2 当前必须优先用 `tdvp_optimal`，不要默认回到 `WII`。
4. Fig. 2 的 `chi` 继续往上抬到 `150` 或 `200`，对当前 `eDQPT` 关键诊断已经几乎没有改观。
5. 如果之后只是重新出图，不需要重新分析，直接跑本文件第 3 节里的命令就够了。

## 9. 英文版

英文版本在同目录：

- `docs/worktree-handoffs/dqpt-fig1-denicola-2021/README.en.md`
