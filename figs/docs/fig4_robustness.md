# 图 4-robustness：碎片化攻击鲁棒性

## 一、原理（为什么需要这张图）

### 论文中的理论基础

碎片化攻击（退化攻击）是 LFA 的高级变种：攻击者将流量分散到更多 decoy 目的地（M 增大），使每个 key 的聚合速率降低，混入良性流量长尾。这张图评估各方案在碎片化攻击下的鲁棒性。

### 碎片化的影响

- 每个 decoy 的聚合速率降低 → rate-only 检测失效
- 攻击证据分散到多个节点 → 单星检测困难
- 但攻击的 FO/FI 和持续性特征不变 → 多签名方案仍有效
- 协同聚合可整合分散证据 → CoopSatShield 最鲁棒

### 位置

第四章"对碎片化攻击证据的鲁棒性"节，论证 CoopSatShield 的鲁棒性优势。

---

## 二、预期结论（图应该呈现什么趋势）

### (a) F1 vs M

- **SatShield**：M>10 后 F1 急剧下降（rate-only 检测失效）
- **MS-SatShield**：下降缓慢（FO/FI + persist 补偿速率稀释）
- **CoopSatShield**：最高且最稳定（协同整合碎片证据）

### (b) 良性吞吐 vs M

- CoopSatShield 在高 M 下仍保持 >0.9
- SatShield 在高 M 下吞吐明显下降（检测失效→无法保护良性流）

### (c) W_waste vs M

- CoopSatShield 的 W_waste 始终最低（推回减少跳数）
- 所有方案的 W_waste 随 M 增大变化较小（总攻击量不变）

### M 范围

M_list 对齐论文：`[1, 5, 10, 50, 100, 500, 1000]`

---

## 三、代码流程（数据从哪来、怎么处理、如何画图）

### 核心处理步骤

```python
# fig4_robustness.py 主流程:

# 对每个 M in M_range=[1,5,10,50,100,500,1000]:
#   a. generate_degraded_attack_flows(M=M) → 退化攻击流
#   b. 对 3 种方案 (SatShield / MS-SatShield / CoopSatShield):
#      - 运行检测 + 缓解
#      - 记录 F1, throughput, W_waste
#   c. 汇总结果

# 3 子图 (1x3): 每子图 3 条曲线, x=M (log 刻度)
```

### 关键实现细节

- M_list 已对齐论文表 3-3：`[1, 5, 10, 50, 100, 500, 1000]`
- 与 SensitivityConfig.M_robustness_range 同步
- 每个 M 值独立运行完整检测+缓解流程
- 输出：`experiments/figures/ch4/fig4_robustness.pdf` 和 `.png`
