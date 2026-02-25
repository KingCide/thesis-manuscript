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

1. **良性 CDF**：呈现长尾分布。大多数 key 速率低（< 10 Mb/s），少量 key 速率高（p99 约几十 Mb/s）
2. **攻击 CDF**：整体右移。攻击 key 的聚合速率集中在几百 Mb/s 到 Gb/s 量级
3. **可分性间隙**：两条曲线之间存在明显的 gap，gap 越大 top-k 检测越有效
4. **p99 标注**：良性 p99 用于后续校准可疑度的归一化基线（`scorer.calibrate_baseline()`）
5. **退化动机**：当 M 增大时，攻击 CDF 会向左移动（单 key 聚合速率降低），gap 缩小，引出多签名的必要性

---

## 三、代码流程（数据从哪来、怎么处理、如何画图）

### 数据加载路径

```
icarus-framework/result_dumps/ → IcarusDataLoader("8x8")
  → bw_data（带宽分配）
  → atk_data（攻击信息）
  → edge_data（边数据，含经过每条边的路径列表）
  → path_data（路由路径）
```

### 核心处理步骤

```python
# fig3_1_cdf.py 主流程:

# 1. 加载 icarus 数据
loader = IcarusDataLoader("8x8")
bw_data, atk_data, edge_data, path_data = loader.load()

# 2. 选取攻击最严重的链路
target_edge = find_most_attacked_edge(atk_data)

# 3. 生成良性流（从 edge_data 获取经过 e* 的路径列表）
benign_flows = generate_benign_flows(bw_data, path_data, edge_data, target_edge)

# 4. 生成攻击流（直接使用 icarus 攻击流集合）
attack_flows = generate_attack_flows_from_icarus(atk_info, path_data, target_edge)

# 5. 按 key 聚合速率，注入 5000 个 lognormal 噪声 key
agg = aggregate_by_key(benign_flows + attack_flows, n_noise_keys=5000)

# 6. 分离 benign_rates 和 attack_rates
benign_rates = sorted([v["rate"] for k, v in agg.items() if not v["is_attack"]])
attack_rates = sorted([v["rate"] for k, v in agg.items() if v["is_attack"]])

# 7. 手动计算 CDF: y = np.arange(1, len(rates)+1) / len(rates)

# 8. matplotlib: log 横轴, 标注 p99, 两条曲线

# 9. save_fig → PDF + PNG
```

### 绘图参数

- X 轴：对数刻度（log10），单位 Mb/s
- Y 轴：CDF（0~1）
- 颜色：良性蓝色，攻击红色
- 标注：良性 p99 垂直虚线 + 文字标注
- 输出：`experiments/figures/ch3/fig3_1_cdf.pdf` 和 `.png`
