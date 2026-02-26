# ddosd-p4 项目概述

## 背景与目标
`ddosd-p4` 是论文“Offloading Real-time DDoS Attack Detection to Programmable Data Planes (IM 2019)”的 P4 数据平面实现。目标是把实时 DDoS 检测逻辑下沉到可编程交换机的数据平面中，在每个观测窗口内直接估计源/目的 IP 分布的熵，并基于统计阈值判断异常。该仓库面向 bmv2 的 `simple_switch`，作为可行性验证（PoC），不以生产性能为目标。

## 核心思路
- **观测窗口**：按固定窗口大小 `m=2^log2_m` 统计流量特征。`log2_m`、`training_len`、`alpha`、`k` 等参数通过控制面写入寄存器。
- **频次估计（Count Sketch）**：对源 IP/目的 IP 各维护 4 行、宽度 976 的 Count Sketch 计数器。每行使用不同哈希函数，利用中位数估计 IP 的出现次数。
- **熵估计与累积**：把估计的频次映射到预先离散化的熵项（通过 LPM 表查表得到），累加得到观测窗口的熵“范数”`S`。
- **统计检测**：窗口结束时计算源/目的 IP 的熵；维护 EWMA 与 EWMMD（指数滑动平均与指数滑动平均绝对偏差），并用阈值 `k` 判断熵的异常偏离，设置 `alarm` 标志。
- **输出与镜像**：在每个观测窗口的最后一个包上，克隆并插入自定义 `ddosd` 头（EtherType 0x6605），携带熵、EWMA/EWMMD 和告警位，便于控制面或外部采集。

## 代码结构
- `src/ddosd.p4`：主程序，包含 Count Sketch 计数、熵计算、EWMA/EWMMD 更新与告警逻辑。
- `src/headers.p4` / `src/parser.p4`：自定义 `ddosd` 头、IPv4 解析与分发。
- `scripts/run.sh`：快速启动脚本，设置 veth 端口并加载控制规则。
- `scripts/control_rules.txt`：控制面初始化规则，包含镜像会话、寄存器参数、LPM 表项等。

## 运行方式（简要）
- **构建**：`make` 使用 `p4c` 生成 `build/ddosd.json`。
- **启动**：`./scripts/run.sh` 会创建 veth 对、启动 `simple_switch`、下发默认控制规则。
- **依赖**：需要带哈希扩展的 `behavioral-model` 和 `p4c` 分支（见 README 指向的 fork）。

## 关键输入/输出
- **输入端口**：脚本默认将 `veth0` 作为输入。
- **输出端口**：IPv4 转发到 `veth2`；观测窗口最后一个包被镜像到 `veth4`，携带 `ddosd` 头。
- **输出字段**：`packet_num`、`src/dst_entropy`、`src/dst_ewma`、`src/dst_ewmmd`、`alarm` 等。

## 适用场景与限制
- **适用**：教学/研究、验证数据平面内 DDoS 检测可行性，复现论文方法。
- **限制**：依赖 bmv2 和特定哈希扩展；Count Sketch 与熵表是固定精度的近似；非生产级性能实现。

## 参考
- 论文实现背景与可复现实验请参考仓库 `README.md`。
- C++ 等价实现见 `https://github.com/aclapolli/ddosd-cpp`。
