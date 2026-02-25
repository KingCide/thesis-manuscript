# 消融实验：K 扫描（top-k 候选规模）

## 一、原理（为什么需要这张图）

### 论文中的理论基础

top-k 候选规模 K 是 MS-SatShield 检测器的核心超参数。K 决定了每个 epoch 中多少个 key 被选为"候选可疑 key"进行进一步的多签名评分。

### 理论依据

Space-Saving 算法保证 top-K 中包含所有计数 > N/K 的 key（N 为总计数）。在退化设定下（M 个 decoy），每个攻击 key 的聚合速率 = A/M，而总流量 N = 良性总量 + 攻击总量 + 噪声。当 A/M < N/K 时，攻击 key 可能不在 top-K 中。

### K 的权衡

- **K 过小**：攻击 key 漏选 → Recall 低
- **K 过大**：噪声 key 涌入候选集 → Precision 略降，且星上计算开销增加（每个候选 key 需维护 FO/FI 位图）
- **目标**：找到 Recall 饱和的最小 K（推荐默认值）

### 位置

第三章"消融实验与参数敏感性分析"节。

---

## 二、预期结论（图应该呈现什么趋势）

1. **Recall** 随 K 增大单调上升，直到 K 足以覆盖所有攻击 key（饱和点）
2. **F1** 先升后可能微降（K 过大时 Precision 略降，但 Recall 饱和后 F1 趋于稳定）
3. **饱和点**即为推荐的默认 K 值
4. K 扫描范围：`[100, 500, 1000, 2000, 5000, 10000, 20000]`
5. 在 M=100 退化设定下，预期饱和点在 K=1000~2000 附近

---

## 三、代码流程（数据从哪来、怎么处理、如何画图）

### 核心处理步骤

```python
# ablation.py → ablation_K():

# 1. _prepare_data() → 加载 icarus 数据 + 生成 M=100 的退化攻击流

# 2. 对每个 K in K_range=[100,500,1000,2000,5000,10000,20000]:
#    _compute_f1_with_params(benign, attack, K, m=256, cfg):
#      - 3 warmup epoch（仅良性 + 速率抖动）
#      - k_p attack epoch（含攻击 + 速率抖动，累积持续性）
#      - 最终 epoch: top-k → FO/FI → score → detect → P/R/F1
#    记录 Recall 和 F1

# 3. 折线图: x=K (log 刻度), 两条曲线(Recall 和 F1)
```

### 绘图参数

- X 轴：K（对数刻度）
- Y 轴：Recall / F1（0~1）
- 两条曲线：Recall（虚线）和 F1（实线）
- 输出：`experiments/figures/ch3/ablation_K.pdf` 和 `.png`
