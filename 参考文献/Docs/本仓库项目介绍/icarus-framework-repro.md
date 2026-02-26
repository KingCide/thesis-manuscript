# Icarus Framework Analysis and Reproduction Log

Context
- Repo path: /Users/kc/Documents/Projects/icarus-framework
- Log path: /Users/kc/Documents/Projects/Docs/icarus-framework-repro.md

Component Analysis Summary
- Core engine: `icarus_simulator/icarus_simulator.py` orchestrates phases, maintains properties, and encodes dependency chains into result filenames.
- Phase abstraction: `icarus_simulator/phases/base_phase.py` defines the compute/persist contract, cache reads, timing, and result checks.
- Strategy abstraction: `icarus_simulator/strategies/base_strat.py` provides runtime-pluggable micro-tasks with naming/parameter descriptions used for provenance.
- Data model: `icarus_simulator/structure_definitions.py` centralizes typed structures (grid, coverage, routing, edges, attacks).
- Entry config: `configuration.py` expands multi-run strategy configs; `main.py` wires the full pipeline and sample plotting.

Phases (high level)
- LSN: build constellation + network topology via Walker model.
- Grid/Coverage: geodesic ground grid + coverage pruning.
- Routing: multi-process path computation for ground pairs.
- Edge/Traffic: edge centrality and bandwidth assignment.
- Link attack: geo constraints + path filtering + feasibility + detectability optimization.
- Zone attack: zone selection/build, bottleneck search, optimized attack set.

Strategies (high level)
- Routing: SSP/KSP/KDG/KDS/KLO variants (different disjointness/diversity heuristics).
- Grid weighting: GDP-weighted sampling over a geodesic grid.
- Attack: geo constraints, path filtering, LP/prob feasibility, binary-search detectability optimization.
- Zone: random selection, k-closest build, edge filters, bottleneck detection.

Reproduction Log

[Step] pipenv --version
[Result]
- zsh:1: command not found: pipenv

[Step] python3 -m pip install --user pipenv
[Result]
- Installed pipenv to /Users/kc/Library/Python/3.9/bin (not on PATH)

[Step] /Users/kc/Library/Python/3.9/bin/pipenv --version
[Result]
- pipenv, version 2025.0.4

[Step] /Users/kc/Library/Python/3.9/bin/pipenv install .
[Result]
- Warning: Python 3.6 was not found on your system...
- Suggestion: pipenv --python path/to/python

[Step] /Users/kc/Library/Python/3.9/bin/pipenv --python 3.9 install .
[Result]
- Virtualenv created at /Users/kc/.local/share/virtualenvs/icarus-framework-Cs3Iay0E
- Warning: Pipfile requires python_version 3.6, using 3.9.6
- Dependency install failed on netCDF4==1.5.4: ValueError: did not find HDF5 headers

Pending
- Decide installation path: install HDF5 headers, or use a different Python toolchain.

[Step] uv --version
[Result]
- zsh:1: command not found: uv

[Step] curl -Ls https://astral.sh/uv/install.sh | sh
[Result]
- First attempt timed out after 10s while downloading.

[Step] curl -Ls https://astral.sh/uv/install.sh | sh (retry)
[Result]
- Installed uv 0.9.24 to /Users/kc/.local/bin (uv, uvx)
- Installer hint: source $HOME/.local/bin/env to update PATH

[Step] /Users/kc/.local/bin/uv --version
[Result]
- uv 0.9.24 (0fda1525e 2026-01-09)

[Step] brew install hdf5
[Result]
- Installed hdf5 1.14.6 (and dependencies) under /opt/homebrew/Cellar/hdf5/1.14.6

[Step] /Users/kc/Library/Python/3.9/bin/pipenv lock -r > requirements.lock.txt
[Result]
- Failed: pipenv lock has no -r option (usage error).

[Step] /Users/kc/Library/Python/3.9/bin/pipenv requirements > requirements.lock.txt
[Result]
- requirements.lock.txt generated in repo root.
- Contains pinned packages plus a single local entry "." for setup.py install.

[Step] /Users/kc/.local/bin/uv venv .venv
[Result]
- Created .venv using Homebrew Python 3.11.10 (arm64).

[Step] /Users/kc/.local/bin/uv venv --python /usr/bin/python3 .venv-py39
[Result]
- Created .venv-py39 using Python 3.9.6 (arm64).

[Step] HDF5_DIR=$(brew --prefix hdf5) uv pip install -r requirements.lock.txt
[Result]
- Failed: build backend error due to multiple .egg-info directories from local package metadata.

[Step] rg -v '^\.$' requirements.lock.txt > requirements.lock.nolocal.txt
[Result]
- Generated requirements without local package line for dependency-only install.

[Step] HDF5_DIR=$(brew --prefix hdf5) uv pip install -r requirements.lock.nolocal.txt
[Result]
- Failed: shapely==1.7.0 build error, missing geos_c.

[Step] brew install geos
[Result]
- Installed geos 3.14.1 under /opt/homebrew/Cellar/geos/3.14.1.

[Step] HDF5_DIR=$(brew --prefix hdf5) GEOS_CONFIG=$(brew --prefix geos)/bin/geos-config uv pip install -r requirements.lock.nolocal.txt
[Result]
- shapely built successfully.
- netcdf4==1.5.4 failed: missing netcdf.pc in PKG_CONFIG_PATH and missing numpy in build isolation.

[Step] brew install netcdf
[Result]
- Installed netcdf 4.9.3_1 under /opt/homebrew/Cellar/netcdf/4.9.3_1.

[Step] uv pip install numpy==1.19.1
[Result]
- Failed: numpy 1.19.1 build error (missing distutils.msvccompiler).

Notes
- On Apple Silicon, several pinned 2020-era packages lack arm64 wheels and require complex source builds.

[Step] Create requirements.compat.txt (unpinned dependencies)
[Result]
- requirements.compat.txt added in repo root with unpinned package names.

[Step] HDF5_DIR=$(brew --prefix hdf5) GEOS_CONFIG=$(brew --prefix geos)/bin/geos-config uv pip install -r requirements.compat.txt
[Result]
- Success (arm64 wheels). Key versions installed: numpy 2.0.2, scipy 1.13.1, pandas 2.3.3, scikit-learn 1.6.1, shapely 2.0.7, netcdf4 1.7.2, matplotlib 3.9.4, plotly 6.5.1, networkx 3.2.1.

[Step] python setup.py install (venv)
[Result]
- Failed: setuptools missing in venv.

[Step] uv pip install setuptools
[Result]
- Installed setuptools 80.9.0 in venv.

[Step] python setup.py install (retry)
[Result]
- Success; installed icarus_simulator and sat_plotter.
- Warning: setup.py install is deprecated.

[Step] python main.py
[Result]
- Failed: ModuleNotFoundError: typing_extensions

[Step] uv pip install typing_extensions
[Result]
- Installed typing-extensions 4.15.0.

[Step] python main.py (retry)
[Result]
- Failed: result_dumps/ not found.

[Step] mkdir -p result_dumps
[Result]
- Created result_dumps directory.

[Step] python main.py (retry)
[Result]
- LSN phase succeeded and wrote result file.
- Grid phase failed when loading GDP_PPP_1990_2015_5arcmin_v2.nc (NetCDF: Unknown file format).

[Step] file GDP_PPP_1990_2015_5arcmin_v2.nc
[Result]
- File type reported as ASCII text.

[Step] git lfs install
[Result]
- Git LFS initialized.

[Step] git lfs pull
[Result]
- Failed: LFS budget exceeded for the repository; data objects not fetched.

Blockers
- Required data under icarus_simulator/data is Git LFS-managed; LFS download blocked by upstream budget limit.

———
后续记录说明
- 自此以后追加内容使用中文。

本次调整（源代码与仓库清理）
[步骤] 修改 configuration.py 使用 UniformWeightStrat
[结果]
- 已将 gweight 策略从 GDPWeightStrat 改为 UniformWeightStrat，跳过 GDP 数据依赖。

[步骤] 新增 .gitignore
[结果]
- 忽略 .venv*、build/、*.egg-info/、result_dumps/ 及本地复现产生的 requirements*.txt。
- 预计可显著减少 IDE 显示的变更数量。

[步骤] 运行 python main.py（使用 UniformWeightStrat）
[结果]
- 运行 10 分钟后超时，中断于 Routes 阶段（批处理 Batch 0）。
- 已完成并写入：LSN、Grid、Cover 三个阶段的结果文件。
- 提示：仿真规模较大，README 也说明需多核机器；本地完整跑通可能需要更长时间或缩小配置。

本次缩小规模的修改
[步骤] 调整 configuration.py
[结果]
- LSN 缩小为 6 轨道 × 6 星/轨道，f=1。
- 地面网格 repeats 调整为 3。
- 带宽采样 sampled_quanta 改为 80。
- 攻击可行性从 LPFeasStrat 改为 ProbFeasStrat（beta=0.5），避免 Gurobi 依赖。
- 检测优化 rate 调整为 0.0（减少迭代）。
- zone_select samples 改为 50，zone_build size 改为 3。

[步骤] 调整 main.py
[结果]
- CORE_NUMBER 从 30 改为 4。
- 路由/边/攻击/区域攻击的 batch 数统一为 1。

[步骤] 缩小规模后运行 python main.py
[结果]
- 计算流程（LSN/Grid/Cover/Routes/Edges/Bw/LAtk/ZAtk）全部完成。
- 进入绘图阶段时失败：攻击结果为空，min() 作用于空序列导致异常。

[步骤] 修改 main.py（绘图前增加空结果判断）
[结果]
- 当没有可攻击链路或区域攻击结果时，跳过 08_atk_viz.png 和 09_zone_atk.png 并输出提示。

[步骤] 再次运行 python main.py（绘图阶段）
[结果]
- 计算阶段全部读取缓存。
- 统计绘图阶段因空数据导致 min() 抛错（binned_line_xy）。

[步骤] 修改 main.py（统计绘图空数据保护）
[结果]
- 当攻击/区域攻击统计为空时，跳过对应图表并输出提示。

[步骤] 再次运行 python main.py（最终）
[结果]
- 计算阶段全部读取缓存并完成。
- 绘图阶段成功执行，缺失的数据图表已被跳过并打印提示。
- 运行完成（无异常退出）。

[步骤] 更新 .gitignore
[结果]
- 增加 "/.png" 忽略规则，避免根目录下生成的绘图文件出现在未跟踪列表中。

[步骤] 适度放大规模并调整参数（为产生攻击相关图表）
[结果]
- 星座规模：8 轨道 × 8 星/轨道，f=1。
- 地面网格 repeats=6，覆盖最小仰角=20。
- 带宽采样 sampled_quanta=800。
- 带宽配置：isl_bw=800、udl_bw=200。
- zone_select samples=200，zone_build size=4。

[步骤] 调整参数以避免 ZAtk 断言错误
[结果]
- zone_select samples 调整为 0（跳过区域攻击样本）。

[步骤] 降低地理绘图输出分辨率并提高 Kaleido 超时
[结果]
- GeoPlotBuilder.save_to_file 改为 1600x900, scale=1.0。
- main.py 设置 pio.kaleido.scope.default_timeout=120。

[步骤] 运行 main.py（设置 Kaleido 超时）
[结果]
- 因 plotly 版本更新，pio.kaleido.scope.default_timeout 不再有效。
- 改用 pio.defaults.default_timeout。

[步骤] 运行 main.py（放大规模后）
[结果]
- 运行成功完成。
- 产生单目标攻击相关图表（未再出现“无攻击数据”的提示）。
- 区域攻击仍为空，因此 09/13/14/15 被跳过。

[步骤] 新增 ScipyLPFeasStrat（无 Gurobi 的多边瓶颈 LP 可行性策略）
[结果]
- 新增 `icarus_simulator/strategies/atk_feasibility_check/scipy_lp_feas_strat.py`，使用 `scipy.optimize.linprog` 替代 Gurobi。
- 更新 `icarus_simulator/strategies/atk_feasibility_check/__init__.py` 导出新策略。

[步骤] 使用 ScipyLPFeasStrat + zone_select.samples>0 运行 main.py
[结果]
- 运行完成，ZAtk 阶段成功计算（无断言错误）。
- 本次运行未出现“无区域攻击数据”的跳过提示，区域攻击相关图表应已生成。

本次实验参数（摘要）
- LSN: sats_per_orbit=8, orbits=8, f=1, inclination=53, elevation=550000, epoch=2020/01/01 00:00:00
- Grid: repeats=6, gweight=UniformWeightStrat
- Cover: min_elev_angle=20
- Routing: SSPRoutStrat, desirability_stretch=2.3
- BW: sampled_quanta=800, isl_bw=800, udl_bw=200, utilisation=0.9
- Attack: atk_feas=ScipyLPFeasStrat, atk_optim.rate=0.0
- Zone: zone_select.samples=200, zone_build.size=4
- 运行设置: CORE_NUMBER=4, num_batches=1
