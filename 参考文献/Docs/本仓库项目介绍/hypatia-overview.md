# Hypatia 项目概述

## 项目定位
Hypatia 是一个面向低轨卫星（LEO）网络的仿真框架。它通过预先计算网络随时间变化的动态状态，结合 ns-3 进行分组级仿真，并提供可视化工具帮助理解星座拓扑、路径和时延变化。该仓库对应 IMC 2020 论文 “Exploring the "Internet from space" with Hypatia”。

## 主要组件
- `satgenpy`：用于生成 LEO 星座与网络动态状态（转发表、链路带宽等），并提供分析工具。
- `ns3-sat-sim`：基于 ns-3 的分组级仿真框架，读取 `satgenpy` 生成的状态进行网络仿真。
- `satviz`：基于 Cesium 的可视化流水线，生成交互式星座与路径可视化。
- `paper`：复现实验与论文图表的脚本与配置。
- `integration_tests`：用于集成测试。

## 核心流程（高层）
1. **生成网络状态**（`satgenpy`）：输入地面站、卫星轨道、星间链路等信息，生成随时间变化的转发状态与带宽信息。
2. **分组级仿真**（`ns3-sat-sim`）：使用 ns-3 读取动态状态，在不同时间窗口运行流量仿真。
3. **分析与可视化**（`satgenpy`/`satviz`）：对路径、拥塞、时延等进行分析，并生成可视化结果。
4. **复现实验**（`paper`）：按照论文步骤运行脚本并绘制图表。

## satgenpy 生成的关键数据
生成 LEO 网络状态时常见的输入/输出包括：
- `ground_stations.txt`：地面站位置与属性。
- `tles.txt`：卫星轨道的 TLE 数据。
- `isls.txt`：星间链路拓扑。
- `gsl_interfaces_info.txt`：地面站/卫星 GSL 接口数量与带宽。
- `description.txt`：最大链路长度等描述信息。
- `dynamic_state/`：随时间变化的转发状态与链路带宽。

## 依赖与运行环境（概览）
- 推荐 Linux（例如 Ubuntu 18+）。
- Python 3.7+。
- ns-3 相关依赖（OpenMPI、gnuplot 等）。
- `satviz` 需要 Cesium access token。

## 仓库脚本
- `hypatia_install_dependencies.sh`：安装依赖。
- `hypatia_build.sh`：构建各模块。
- `hypatia_run_tests.sh`：运行测试。

## 使用建议
- 首次使用可从 `paper/README.md` 的复现实验流程入手。
- 如果只想快速查看结果，可下载论文对应的临时数据包并解压。
- 若仅关注生成星座或网络状态，可以优先使用 `satgenpy`。

## 参考链接
- 论文与框架背景：仓库 `README.md`。
- 可视化示例：`satviz/README.md` 以及官网示例页面。
