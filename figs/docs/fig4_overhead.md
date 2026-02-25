# 图 4-overhead：控制开销敏感性

## 一、原理（为什么需要这张图）

### 论文中的理论基础

CoopSatShield 的协同通信依赖 EG（Evidence Gossip）和 PT（Pushback Trigger）消息。这张图验证协同开销是否可控，论证"无信令风暴"。

### 三重控制机制

1. **事件驱动**：仅拥塞时发送 EG（不是每 epoch 广播）
2. **ROI 限制**：EG 最多传播 R 跳（不全网广播）
3. **抑制**：每个节点在 k 条等价消息后停止转发

### 参数影响

- **R（ROI 半径）**：R 越大 → 覆盖范围越广（检测越好）→ 但消息数增长
- **k（抑制参数）**：k 越大 → 允许更多冗余（可靠性上升）→ 但消息数增多

### 位置

第四章"协同开销与无信令风暴验证"节。

---

## 二、预期结论（图应该呈现什么趋势）

### (a) 消息数 vs R

- EG 消息数随 R 增长但受抑制约束（不呈指数增长，而是亚线性/线性增长）
- PT 消息数较少且稳定（PT 仅沿推回路径发送）

### (b) 控制带宽 vs R

- 控制带宽 = EG 数 x L_eg(512B) + PT 数 x 64B
- 占 ISL 容量（20 Gb/s）极小比例（< 0.1%）
- 论证"无信令风暴"

### (c) 抑制率

- k=1 时抑制率最高（>80%）：每个节点收到 1 条 EG 后立即停止转发
- k=10 时抑制率降低但消息仍受控
- **推荐值**：R=4, k=3（兼顾覆盖与开销）

---

## 三、代码流程（数据从哪来、怎么处理、如何画图）

### 核心处理步骤

```python
# fig4_overhead.py 主流程:

# --- R 扫描 ---
# 对每个 R in [1, 2, 3, 4, 5, 6]:
#   a. CoopSimEngine(coop_cfg.R=R) → init → calibrate
#   b. run_epoch(all_flows, epoch=0, attack=True)
#   c. 记录 eg_messages, pt_messages, eg_suppressed
#   d. ctrl_bw = eg x L_eg(512B) + pt x 64B

# --- k 扫描 ---
# 对每个 k in [1, 2, 3, 5, 10]:
#   a. CoopSimEngine(coop_cfg.k_suppress=k) → run_epoch
#   b. supp_rate = eg_suppressed / (eg_messages + eg_suppressed)

# 3 子图: (a)消息数 vs R, (b)控制带宽 vs R, (c)抑制率柱状图
```

### 绘图参数

- 子图 (a)：x=R, 双柱（EG/PT 消息数）
- 子图 (b)：x=R, 控制带宽（KB/s 或 Mb/s），右 y 轴标注占 ISL 容量百分比
- 子图 (c)：x=k, 柱状图（抑制率 %）
- 输出：`experiments/figures/ch4/fig4_overhead.pdf` 和 `.png`
