# 图 3-1：良性 vs 攻击的 per-key 聚合速率 CDF

## 一、原理（为什么需要这张图）

### 论文中的理论基础

链路洪泛攻击（LFA）中，大量 bot 向少数 decoy 目的地发送低速率流量，这些流量在目标链路上汇聚，导致链路拥塞。MS-SatShield 的检测思路是：按目的地址 key 聚合流量后，攻击 key 的聚合速率 R(a) 远高于良性 key。

### 对应的公式

$$R_t(a) = \frac{\text{bytes}_t(a)}{\Delta}$$

其中 $\Delta$ 为 epoch 长度，$R_t(a)$ 为 key $a$ 在第 $t$ 个 epoch 的聚合速率。

### 这张图在论文论证链中的位置

这是第三章的**第一张实验图**，位于"可分性分析与退化动机"节。它为后续 top-k 检测方法提供**可行性依据**：如果良性和攻击的 CDF 完全重叠（无可分性间隙），则基于速率排序的 top-k 方法不可行。同时，这张图也为退化攻击（图 3-2）提供动机——当 M 增大时，攻击 CDF 左移，间隙缩小。

---

## 二、预期结论（图应该呈现什么趋势）

1. **良性 CDF**：呈现长尾分布。大多数 key 速率低（< 10 Mb/s），少量 key 速率高（p99 约几百 Mb/s）
2. **攻击 CDF**：整体右移。攻击 key 的聚合速率集中在几百 Mb/s 到 Gb/s 量级
3. **可分性间隙**：两条曲线之间存在明显的 gap，gap 越大 top-k 检测越有效
4. **退化趋势**：M 增大 → 单 key 速率降低 → 攻击 CDF 左移 → gap 缩小甚至消失
5. **p99 标注**：良性 p99 用于后续校准可疑度的归一化基线（`scorer.calibrate_baseline()`）

---

## 三、当前实现（2×2 多 M 子图）

### 图布局

2×2 子图，分别展示 M=1, 10, 100, 1000 下的 CDF 对比，形成"可分性随 M 退化"的完整视觉证据链，直接衔接图 3-2 的 F1 退化实验。

### 关键设计决策

#### 少量攻击 key 的可视化方式

M=1 时只有 1 个攻击 key，M=10 时只有 10 个。`ax.plot([单点], [1.0])` 无 marker 时在图上完全不可见。

**解决方案**：当攻击 key 数 ≤10 时，使用 `axvline`（红色垂直虚线）+ `scatter`（菱形散点）代替 CDF 曲线；当攻击 key 数 >10 时，使用 `ax.step()` 绘制阶梯 CDF。

#### 噪声 key 的处理

聚合时使用 `n_noise_keys=0`，不注入背景噪声 key，保持良性与攻击的对比干净。噪声 key 的影响在检测实验（图 3-2）中体现。

#### gap 标注

- 存在 gap 时：绿色阴影区 + "gap ×N" 倍数标注 + 两端数值（p99=X, min=Y）
- 无 gap（重叠）时：红色"重叠"标注框

### 当前实验数据（22×72 合成拓扑）

| M | 良性 key 数 | 攻击 key 数 | 攻击速率范围 (Mb/s) | gap 倍数 |
|---|------------|------------|-------------------|---------|
| 1 | 376 | 1 | [10024, 10024] | ×31 |
| 10 | 374 | 10 | [1000, 1025] | ×3 |
| 100 | 354 | 100 | [100, 538] | 重叠 |
| 1000 | 54 | 1000 | [10, 616] | 重叠 |

- 良性 p99 ≈ 321 Mb/s
- M=1 时间隙最大（良性 p99=321 vs 攻击=10024，约 31 倍）
- M=100 起攻击 key 低端（100 Mb/s）已融入良性分布
- M=1000 时良性 key 数骤降至 54（大量目的地被攻击 key 占据）

### 可在正文中补充的定量描述

> M=1 时，良性 p99=321 Mb/s 与攻击聚合速率 10024 Mb/s 之间存在约 31 倍的可分性间隙；M=100 时攻击 key 速率下探至 100 Mb/s，与良性分布出现重叠，top-K 检测开始退化。

---

## 四、代码流程

### 入口

`experiments/ch3_ms_satshield/fig3_1_cdf.py` → `generate_fig3_1()`

### 核心处理步骤

```python
# 1. 加载合成拓扑数据
loader = create_data_loader()  # → SyntheticDataLoader(22×72, 4000 地面点)
bw_data, atk_data, edge_data, path_data = ...

# 2. 选取攻击最严重的链路
target_edge, atk_info = loader.find_most_attacked_edge(atk_data)

# 3. 生成良性流（所有子图共用，max_flows=800）
benign_flows = generate_benign_flows(bw_data, path_data, edge_data, target_edge)

# 4. 对每个 M 值循环：
for M in [1, 10, 100, 1000]:
    # 生成退化攻击流（B=2000 bot, 链路容量 50% 作为攻击总量）
    attack_flows = generate_degraded_attack_flows(..., M=M)

    # 按 key 聚合（不注入噪声）
    agg = aggregate_by_key(all_flows, n_noise_keys=0)

    # 分离 benign_rates / attack_rates
    # 自适应可视化：≤10 key 用 vline+scatter，>10 key 用 step CDF
    # 标注 gap 区间或重叠提示
```

### 辅助函数

- `_plot_attack_on_ax(ax, attack_arr)` — 自适应选择攻击流可视化方式
- `_annotate_gap(ax, benign_arr, attack_arr)` — 标注 gap 区间或重叠

### 绘图参数

- 画布：2×2，figsize=(12, 9)
- X 轴：对数刻度（log10），单位 Mb/s
- Y 轴：CDF（0~1.05）
- 颜色：良性蓝色 `#008fd5`，攻击红色 `#fc4f30`，gap 绿色 `#2ca02c`
- 输出：`experiments/figures/ch3/fig3_1_cdf.pdf` 和 `.png`

---

## 五、修改历史

### 2026-02-25：修复攻击曲线不可见问题（P0）

**问题**：原版图 3-1 只有一条良性 CDF（蓝色），攻击曲线（红色虚线）在图例中存在但图上完全不可见。

**根因**：
1. 使用 `M=1` 生成攻击流 → 聚合后只有 1 个攻击 key
2. `ax.plot([10024.2], [1.0])` 画的是无 marker 的单点，不可见
3. 第 107 行 `if len(attack_arr) > 1` 同时跳过了 p99 标注

**修复**：
1. 少量攻击 key（≤10）改用 `axvline` + `scatter` 代替单点 CDF
2. 改为 2×2 多 M 值子图（M=1,10,100,1000），展示可分性退化全貌
3. 添加 gap 区间阴影 + 倍数标注 / "重叠"提示
4. 聚合时 `n_noise_keys=0`，保持对比干净
