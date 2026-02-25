# 图 3-2：F1 对比图（退化攻击下的检测性能）

## 一、原理（为什么需要这张图）

### 论文中的理论基础

当攻击者采用退化策略（多 decoy 分摊）时，总攻击量不变但分散到 M 个目的 key 上，导致每个 key 的聚合速率降低。这张图验证：仅凭聚合速率（rate-only）是否足以检测？多签名方案能否恢复检测能力？

### 退化攻击模型（表 3-3）

固定参数：总攻击量 A=10Gb/s，B=2000 个 bot，r=5Mb/s/bot。当 M 增大时：
- 每个 decoy 聚合速率 = A/M
- M=1 时：10 Gb/s（远超良性 p99）
- M=1000 时：10 Mb/s（混入良性长尾，rate-only 失效）

### 三种检测方案

| 方案 | 公式 | 含义 |
|------|------|------|
| S0 (rate-only) | S(a) = R&#x0303;(a) | 仅归一化速率 |
| S1 (+FO/FI) | S(a) = 0.5R&#x0303; + 0.5F&#x0303; | 加入 fan-in/fan-out 特征 |
| S2 (+persist) | S(a) = 0.4R&#x0303; + 0.4F&#x0303; + 0.2P&#x0303; | 加入持续性特征 |

### FO/FI 的检测原理

即使攻击速率被分摊到低于良性 p99，攻击 decoy 仍有异常多的不同源地址。因为 B=2000 个独立 bot 分配给 M 个 decoy，每个 decoy 的 FI = B/M。当 M=100 时 FI=20，仍远高于良性 key 的典型 FI（1~5）。

### 位置

这是第三章的核心实验图，位于"评价指标与绘制方式"节，论证多签名方案的必要性和有效性。

---

## 二、预期结论（图应该呈现什么趋势）

### 图 3-2(a)：top-k 原始性能

- top-k Recall 和 F1 随 M 增大而下降
- 原因：攻击 key 速率不再足以进入 top-K 候选集

### 图 3-2(b)：三种方案对比

- **S0 (rate-only)**：F1 随 M 增大急剧下降。M=100 时趋近 0，因为攻击速率混入良性长尾
- **S1 (+FO/FI)**：F1 下降缓慢。FO/FI 在 M <= 100 时仍有效（FI=B/M >= 20）
- **S2 (+persist)**：F1 在所有 M 值下保持最高。持续性特征补偿速率稀释
- **关键拐点**：M=10~100 区间，rate-only 失效但多签名仍有效 → 论证多签名的必要性

---

## 三、代码流程（数据从哪来、怎么处理、如何画图）

### 图 3-2(a) 流程

```python
# 对每个 M in M_list=[1,5,10,50,100,500,1000]:
#   1. generate_degraded_attack_flows(e*, grid, path, M) → 退化攻击流
#   2. aggregate_by_key(benign + attack) → 含噪声聚合
#   3. batch_topk_detect(key_rates, K) → top-k 候选
#   4. Recall = |attack_keys ∩ candidates| / |attack_keys|
#   5. F1 = 2PR/(P+R)
# 柱状图: x=M, y=[Recall, F1]
```

### 图 3-2(b) 流程

```python
# 对每个 M × 每种方案 (S0, S1, S2):
#   _run_detection(benign, attack, K, alpha, beta, gamma, cfg):
#     - 3 epoch warmup（仅良性 + 速率抖动）→ 建立持续性基线
#     - 5 epoch attack（含攻击 + 速率抖动）→ 累积攻击 key 持续性
#     - 最终 epoch: aggregate → top-k → bitmap FO/FI → score → detect
#     - 关键: 持续性跟踪排除噪声 key (n_noise_keys=0)
# 折线图: x=M, 三条曲线(S0/S1/S2)
```

### 关键实现细节

- M_list 对齐论文表 3-3：`[1, 5, 10, 50, 100, 500, 1000]`
- 持续性跟踪必须排除噪声 key（`aggregate_by_key(..., n_noise_keys=0)`），否则噪声 key 持续性恒为 1.0
- warmup 阶段仅注入良性流 + 速率抖动，不注入攻击流
- 输出：`experiments/figures/ch3/fig3_2a_topk_f1.pdf` 和 `fig3_2b_degrade_f1.pdf`
