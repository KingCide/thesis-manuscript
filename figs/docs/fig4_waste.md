# 图 4-waste：无效带宽 W_waste 对比

## 一、原理（为什么需要这张图）

### 论文中的理论基础

不同防御方案在缓解攻击时，攻击流量在网络内部造成的"无效带宽占用"不同。W_waste 是衡量攻击流对 ISL 带宽浪费程度的核心指标。

### W_waste 定义（参考 Mew 论文）

$$W_{\text{waste}} = \sum_f f.\text{rate} \times h_f$$

其中 $h_f$ 为攻击流 $f$ 从源到丢弃点经过的跳数。

### 为什么推回能降低 W_waste

- **NoDefense**：攻击流走完全路径（h = 最大值），W_waste 最大
- **SatShield/MS-SatShield**：在受害链路处丢弃（h = 源到受害链路的跳数）
- **CoopSatShield**：推回到上游 R_up 跳处丢弃（h 更小），W_waste 最小

### 物理意义

W_waste 反映攻击流对 ISL 带宽的浪费程度。推回缓解将丢弃点前移到源头附近，释放中间链路带宽给良性流量。这是 CoopSatShield 相比本地丢弃方案的核心优势。

### 位置

第四章"结果与分析"节，论证推回缓解的带宽效率优势。

---

## 二、预期结论（图应该呈现什么趋势）

### 多 M 值渐进退化

使用 M∈{1, 10, 100, 1000} 展示碎片化程度对 W_waste 的影响：

1. **M=1~10（低退化）**：SatShield 有效（F1=0.5+），W_waste 大幅降低。SS ≈ MS-SS，因 rate-only 已足够。CoopSatShield 通过推回进一步降低。
2. **M=100（中退化）**：SatShield 失效（F1=0.017），W_waste ≈ NoDefense。MS-SatShield 仍有效（FO/FI 补偿），W_waste 降至 17%。CoopSatShield 进一步降至 11%。
3. **M=1000（高退化）**：所有方案退化，但 CoopSatShield 仍最优。

### W_waste 排序

在所有 M 值下：CoopSatShield ≤ MS-SatShield ≤ SatShield ≤ NoDefense

### 与第三章的一致性

M=1~10 时 SS ≈ MS-SS（rate-only 在低退化下足够），与第三章 fig3_2(b) 的"重叠段"分析一致。M≥100 时 SS 失效，需要多签名——与 fig3_2 的"分离段"一致。

---

## 三、当前实验数据

### W_waste (Mb/s·hop)

| M | NoDefense | SatShield | 占ND比 | MS-SatShield | 占ND比 | CoopSatShield | 占ND比 |
|---|-----------|-----------|--------|-------------|--------|--------------|--------|
| 1 | 333,990 | 23,990 | 7.2% | 23,990 | 7.2% | 10,000 | 3.0% |
| 10 | 276,760 | 54,770 | 19.8% | 54,770 | 19.8% | 39,465 | 14.3% |
| 100 | 251,005 | 248,995 | 99.2% | 42,925 | 17.1% | 27,660 | 11.0% |
| 1000 | 249,826 | 245,543 | 98.3% | 181,154 | 72.5% | 176,902 | 70.8% |

### 关键观察

1. **M=1~10：SS = MS-SS**：两者检测到的攻击 key 相同（rate-only 已能检出），W_waste 由丢弃点位置决定。CoopSatShield 推回使丢弃点更靠近源端，W_waste 额外降低。
2. **M=100：SS ≈ ND**：SatShield 的 rate-only 检测在 M=100 下完全失效（F1=0.017），几乎没有攻击流被检出和丢弃，W_waste 退化到无防御水平。
3. **M=1000：所有方案退化**：攻击 key 大量脱离 top-K（TopK_Recall=0.30），MS-SatShield 和 CoopSatShield 的 W_waste 升至 ND 的 ~71%，但仍优于 SS。

### 可在正文中补充的定量描述

> 在 M=1 时，所有检测方案均能将 W_waste 降至 NoDefense 的 7% 以下（推回方案可降至 3%）。当 M 增至 100，SatShield 的 rate-only 检测失效（F1=0.017），W_waste 退回无防御水平（99.2%）；而 MS-SatShield 凭借 FO/FI 特征保持有效检测（F1=0.909），W_waste 仅为 17.1%；CoopSatShield 通过推回进一步降至 11.0%。

---

## 四、代码流程

### 入口

`experiments/ch4_coopsatshield/fig4_waste.py` → `generate_fig4_waste()`

### 核心处理步骤

```python
# fig4_waste.py 主流程:

# 对每个 M in [1, 10, 100, 1000]:
#   a. generate_degraded_attack_flows(M=M) → 退化攻击流
#   b. 对 4 种方案 (NoDefense / SatShield / MS-SatShield / CoopSatShield):
#      - 运行检测 + 缓解
#      - 记录 W_waste
#   c. 汇总结果

# 分组柱状图: x=M, 每组 4 根柱（ND/SS/MS/CS）
```

### 关键参数

| 参数 | 值 | 说明 |
|------|---|------|
| M_values | [1, 10, 100, 1000] | 对齐表 3-3，展示渐进退化 |
| n_noise_keys | 0 | 与第三章对齐 |
| K | 自适应 | clip(0.3 × N_keys, 50, 1000) |
| R_up | 3 | 推回半径 |

### 绘图参数

- 分组柱状图，figsize=(10, 5.5)
- 4 组（M=1,10,100,1000），每组 4 根柱
- 柱顶标注数值（>=1000 显示为 "Xk"）
- 颜色：ND=灰, SS=蓝, MS=红, CS=金
- 输出：`experiments/figures/ch4/fig4_waste.{pdf,png}`

---

## 五、修改历史

### 2026-02-26：从单 M 柱状图改为多 M 分组柱状图

**问题**：
原版仅展示 M=100 下的 W_waste 对比。此时 SatShield F1=0.017（rate-only 完全失效），W_waste=248,995 ≈ NoDefense=251,005（仅差 0.8%）。但第三章表明 SatShield 在 M≤10 时检测 F1 可达 0.5+，论文 L286 也暗示其有缓解效果。单 M=100 实验无法体现这一点。

**修复**：
改为 M∈{1, 10, 100, 1000} 四组分组柱状图，展示"低退化下 SatShield 有效 → 高退化下需要多签名 → CoopSatShield 始终最优"的渐进关系。

### 2026-02-26：修复噪声 key 污染（baselines.py + coop_engine.py）

间接受益：W_waste 计算依赖检测结果的准确性。修复 `n_noise_keys=0` 和自适应 K 后，各方案的检测率更真实，W_waste 数据更准确。
