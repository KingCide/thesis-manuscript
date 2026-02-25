# 图 3-4：脉冲式 on-off 攻击时序图

## 一、原理（为什么需要这张图）

### 论文中的理论基础

实际攻击者常采用脉冲式 on-off 策略：周期性开关攻击流量，以逃避基于持续高速率的检测。这张图验证 MS-SatShield 在这种动态攻击模式下的检测响应和吞吐保护能力。

### 攻击模型

- 攻击流量按固定周期（on_duration=10, off_duration=10 epoch）交替出现
- 每次 on 阶段发起 M=100 的退化攻击
- warmup 阶段（5 epoch）无攻击，用于建立基线

### 持续性特征的价值

- **on 阶段**：攻击 key 迅速进入 top-k，P&#x0303; 累积增长
- **off 阶段**：攻击 key 离开 top-k，但 P&#x0303; 仍保持 k_p-1 个 epoch（窗口效应）
- **on-off 切换**：系统能更快识别"反复出现"的 key，off→on 切换时检测加速

### 队列缓解模型

链路过载时，高优先级队列保留 `high_prio_bw_ratio x capacity`（默认 80%）给检测到的良性流，低优先级队列承受丢弃。

### 位置

第三章"结果分析"节，展示系统在动态攻击下的时域响应特性。

---

## 二、预期结论（图应该呈现什么趋势）

### (a) 攻击状态+链路利用率

- on 阶段利用率 >1.0（过载），off 阶段回到正常水平
- 攻击状态用 axvspan 红色带标注

### (b) top-k 命中数

- on 阶段迅速上升至接近攻击 key 总数
- off 阶段降为 0
- 随 on-off 周期重复，上升速度可能加快（持续性记忆）

### (c) Recall

- on 阶段初期 Recall 从 0 上升到 >0.9（1~2 epoch 延迟）
- off 阶段迅速归 0
- 随着 on-off 周期重复，P&#x0303; 特征使 Recall 上升更快

### (d) 良性吞吐

- on 阶段初始下降（检测未生效），随后恢复（队列调度生效）
- off 阶段完全恢复到 1.0
- 吞吐下降的"谷"应随周期推移变浅（持续性加速检测）

---

## 三、代码流程（数据从哪来、怎么处理、如何画图）

### 核心处理步骤

```python
# fig3_4_onoff.py 主流程:

# 1. 加载 icarus 数据，生成 benign_flows 和 attack_flows (M=100)

# 2. 构建 on-off schedule
#    warmup(5) + 周期性 on(10)/off(10)，共 100 epoch
#    schedule = [False]*5 + [True,True,...,False,False,...] 循环

# 3. run_multi_epoch_sim(benign, attack, capacity, schedule, cfg):
#    每 epoch:
#      a. 按 schedule 决定是否加入攻击流
#      b. 良性流加 ±10% 速率抖动
#      c. aggregate_by_key → top-k → bitmap FO/FI → score → detect
#      d. 计算链路利用率、topk_hit_count、recall、benign_throughput_ratio
#    返回 EpochResult 列表

# 4. 提取 4 个时间序列，绘制 4 子图（共享 x 轴）
#    axvspan 标注攻击区间（红色半透明带）
```

### 绘图参数

- 4 子图垂直排列，共享 x 轴（epoch）
- 攻击 on 区间用红色半透明带标注
- 输出：`experiments/figures/ch3/fig3_4_onoff.pdf` 和 `.png`
