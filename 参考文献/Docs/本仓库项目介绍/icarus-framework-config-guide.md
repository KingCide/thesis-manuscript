# ICARUS 可调参数说明（中文）

下面是本项目运行时常用的可调整参数与含义，重点说明如何控制是否进行区域攻击。

一、是否进行区域攻击（ZAtk）
- 最简单的开关：在 `configuration.py` 中将 `zone_select.samples` 设为 0，即不生成区域攻击样本，ZAtk 阶段会被跳过。
- 或者在 `main.py` 的 `IcarusSimulator([...])` 列表中移除 `ZAtkPhase`。
- 若要启用区域攻击：
  - `zone_select.samples` 必须 > 0。
  - `atk_feas.strat` 必须支持多目标（多条拥塞边）。当前代码里：
    - `ProbFeasStrat` 只支持单目标（内部断言 `len(congest_edges)==1`），用于区域攻击会报错。
    - `LPFeasStrat` 支持多目标，但依赖 Gurobi。

二、仿真规模与性能
- LSN（星座规模）：
  - `lsn.sats_per_orbit`、`lsn.orbits`、`lsn.f`、`lsn.inclination`、`lsn.elevation`。
  - 时间偏移：`lsn.hrs`/`lsn.mins`/`lsn.secs`/`lsn.millis`。
- 地面网格：
  - `grid.repeats`（越大越密，计算量越大）。
- 覆盖：
  - `cover.min_elev_angle`（越小覆盖越广）。
- 流量与带宽：
  - `bw_sel.sampled_quanta`（采样通信数量）。
  - `bw_asg.isl_bw`、`bw_asg.udl_bw`、`bw_asg.utilisation`。

三、算法策略选择
- 路由策略：`rout.strat` 可选 `SSPRoutStrat` / `KSPRoutStrat` / `KDGRoutStrat` / `KDSRoutStrat` / `KLORoutStrat`。
  - 常用参数：`desirability_stretch`、`k`、`esx_theta`。
  - 实现差异（基于代码）：
    - `SSPRoutStrat`：用 Dijkstra 找 1 条最短路，超过 `fiber_len` 直接无解，速度最快但无多样性。
    - `KSPRoutStrat`：用 `shortest_simple_paths` 取前 k 条最短简单路径，可能相似度高。
    - `KDGRoutStrat`：每次找到一条后把该路径上的边权设为 `inf`，再找下一条，弱不相交。
    - `KDSRoutStrat`：在 KDGR 基础上更强地“隔离”路径，禁用中间节点的更多出边，路径更分离但更难找到。
    - `KLORoutStrat`：ESX 风格多样性优化，基于相似度阈值 `esx_theta` 迭代地移除高相似路径边，结果多样性最好但计算最重。
- 地理约束：`atk_constr.strat` 可选 `NoConstrStrat` / `GeoConstrStrat` / `GridConstrStrat`。
- 攻击可行性：`atk_feas.strat` 选 `LPFeasStrat` 或 `ProbFeasStrat(beta=...)`。
- 攻击优化：`atk_optim.rate`（0~1）。
- 区域攻击细节：`zone_select.samples`、`zone_build.size`、`zone_edges.strat` 等。

四、运行与并行
- `main.py` 中每个 Phase 的 `read_persist` / `persist` 控制是否读缓存与落盘。
- `CORE_NUMBER` 与 `num_batches` 决定并行程度与任务切分。

快速建议
- 只做单目标攻击、不做区域攻击：
  - `zone_select.samples = 0`
  - `atk_feas.strat = ProbFeasStrat`
- 需要区域攻击：
  - `zone_select.samples > 0`
  - `atk_feas.strat = LPFeasStrat`（需 Gurobi）或自行实现多目标可行性策略。
