# 消融实验：Delta 扫描（epoch 长度）

## 一、原理（为什么需要这张图）

### 论文中的理论基础

epoch 长度 Delta 决定了检测系统的时间粒度。每个 epoch 结束时，星上代理执行一次 top-k + 多签名评分 + 队列映射的完整检测周期。

### Delta 的权衡

- **Delta 越小**：检测粒度越细 → 反应时间 = 1*Delta 更短 → 但星上代理交互频率增加（计算和通信开销上升）
- **Delta 越大**：检测粒度粗 → 反应时间长 → 但开销低
- 反应时间定义：从攻击开始到首次 Recall > 0.5 的 epoch 数 x Delta

### 吞吐模型

- 第一个攻击 epoch 无防护（检测延迟 1 epoch）
- 后续 epoch 有防护（高优先级队列保护良性流量）
- 小 Delta 时，无防护时段 = 1*Delta（绝对时间短），占比小
- 大 Delta 时，无防护时段 = 1*Delta（绝对时间长），占比大

### 位置

第三章"消融实验"节，论证推荐 Delta = 0.5~1.0s 的合理性。

---

## 二、预期结论（图应该呈现什么趋势）

1. **反应时间**随 Delta 单调增长（近似线性）：Delta=0.1s 时反应时间 ~0.1s，Delta=5.0s 时反应时间 ~5s
2. **吞吐下降**随 Delta 增大而恶化：Delta 越大，无防护窗口越长，攻击造成的吞吐损失越大
3. **推荐值**：Delta = 0.5~1.0s（反应时间 1~2s，可接受；开销适中）
4. Delta=0.1s 虽反应最快，但星上计算频率过高（10次/秒）

---

## 三、代码流程（数据从哪来、怎么处理、如何画图）

### 核心处理步骤

```python
# ablation.py → ablation_delta():

# 1. 固定总攻击时长 15s

# 2. 对每个 Delta in delta_range=[0.1, 0.2, 0.5, 1.0, 2.0, 5.0]:
#    a. n_attack_epochs = max(int(15/Delta), 3)
#    b. schedule = [False]*5 + [True]*n_attack_epochs
#    c. run_multi_epoch_sim() → EpochResult 列表
#    d. reaction_time = (首次 Recall>0.5 的 epoch 序号) x Delta
#    e. throughput_drop = 1 - 加权平均吞吐

# 3. 双 y 轴图: 左=反应时间(s), 右=吞吐下降, x=Delta (log 刻度)
```

### 绘图参数

- X 轴：Delta (s)，对数刻度
- 左 Y 轴：反应时间 (s)，蓝色
- 右 Y 轴：吞吐下降比例，红色虚线
- 输出：`experiments/figures/ch3/ablation_delta.pdf` 和 `.png`
