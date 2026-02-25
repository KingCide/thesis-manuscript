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

1. **W_waste 排序**：NoDefense > SatShield >= MS-SatShield > CoopSatShield
2. **CoopSatShield 优势来源**：pushback 将攻击检测和丢弃推到上游（减少 h_f）
3. **SatShield 和 MS-SatShield 的 W_waste 接近**：两者都在受害链路本地丢弃，区别仅在检测准确率（漏检的攻击流仍走完全路径）
4. **量级对比**：CoopSatShield 约为 NoDefense 的 40~60%

---

## 三、代码流程（数据从哪来、怎么处理、如何画图）

### 核心处理步骤

```python
# fig4_waste.py 主流程:

# 1. 加载数据，生成 M=100 的退化攻击流
# 2. build_link_capacities(bw_data) → 各链路容量字典

# 3. 对 4 种方案各调用 baselines.py 的对应函数:
#    - run_no_defense:
#        W_waste = sum(f.rate x len(f.edges)) for all attack flows
#    - run_satshield:
#        检测后，检出的攻击流 W_waste = f.rate x hops_to_target
#        漏检的攻击流 W_waste = f.rate x len(f.edges)
#    - run_ms_satshield:
#        同 satshield 但多签名检测（检出率更高）
#    - run_coopsatshield:
#        CoopSimEngine → pushback 将 h 减小至 min(len(edges), R_up)

# 4. 柱状图: x=方案名, y=W_waste (Mb/s*hop)
```

### 绘图参数

- X 轴：方案名称（NoDefense / SatShield / MS-SatShield / CoopSatShield）
- Y 轴：W_waste（Mb/s*hop）
- 柱状图，不同方案用不同颜色
- 输出：`experiments/figures/ch4/fig4_waste.pdf` 和 `.png`
