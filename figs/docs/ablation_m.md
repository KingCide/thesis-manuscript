# 消融实验：m 扫描（FO/FI 位图长度）

## 一、原理（为什么需要这张图）

### 论文中的理论基础

FO/FI（fan-out/fan-in）特征通过 bitmap 数据结构估计每个 key 的唯一源/目的数量。位图长度 m 决定了估计精度与内存开销的权衡。

### 理论依据

线性计数公式：

$$\hat{F} = -m \cdot \ln(Z/m)$$

其中 Z 为位图中 0 的个数。当实际 FO/FI > m*ln(2) 时位图饱和，所有位置 1，Z=0，估计值趋于上界 m*ln(m)。

### m 的权衡

- **m 过小**（如 m=32）：hash 碰撞频繁 → 估计误差大（MAPE 高）。但上界 m*ln(m) ≈ 111 仍远大于良性 FO/FI（1~5），检测仍可行但精度不佳
- **m 过大**（如 m=4096）：估计几乎精确 → 但每个候选 key 需 m bit 内存，总内存 = K x m bit
- **目标**：MAPE < 5% 的最小 m

### 位置

第三章"消融实验"节，论证推荐 m=256 的合理性。

---

## 二、预期结论（图应该呈现什么趋势）

1. **MAPE** 随 m 增大单调下降：
   - m=32: MAPE 可能 >50%
   - m=128: MAPE ~10%
   - m=256: MAPE <5%（推荐值）
   - m=1024: MAPE <1%
2. **内存**随 m 线性增长：内存 = m x |candidates| / 8 / 1024 KB
3. **推荐值**：MAPE < 5% 的最小 m = 256
4. 即使 m=32 饱和，上界仍远大于良性值，检测可行但精度不佳

---

## 三、代码流程（数据从哪来、怎么处理、如何画图）

### 核心处理步骤

```python
# ablation.py → ablation_m():

# 1. _prepare_data() → M=100 退化攻击流

# 2. 对所有真实 key 计算实际 FO/FI（unique peer count，ground truth）
#    ground_truth[key] = len(agg[key]["peers"])

# 3. 对每个 m in m_range=[32, 64, 128, 256, 512, 1024]:
#    a. BitmapFOFIEstimator(m) → init_epoch → record_peer → estimate
#    b. 对每个真实 key 计算 |estimated - actual| / actual → APE
#    c. 汇总 MAPE = mean(APE) 和最大误差
#    d. 计算内存 = m x |candidates| / 8 / 1024 KB

# 4. 双 y 轴图: 左=MAPE(%), 右=内存(KB), x=m (log2 刻度)
```

### 绘图参数

- X 轴：m（log2 刻度，标注 32/64/128/256/512/1024）
- 左 Y 轴：MAPE (%)，蓝色
- 右 Y 轴：内存 (KB)，红色虚线
- MAPE=5% 处画水平参考线
- 输出：`experiments/figures/ch3/ablation_m.pdf` 和 `.png`
