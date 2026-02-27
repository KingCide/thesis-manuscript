# 第四章同行评审报告（第二轮）

> **评审对象**：[ch4_coop.tex](file:///Users/kc/Documents/论文原稿/chapters/ch4_coop.tex)（修订后，445 行）  
> **对照**：第一轮评审 16 项意见

---

## 一、第一轮意见逐项核查结果

| # | 意见 | 状态 | 核查依据 |
|---|------|:----:|---------|
| P1 | $\omega_v$ 归一化、$\Theta_\text{pb}$ 选取、$\lambda,\mu$ 网格搜索 | ✅ 已修 | L212 显式归一化；L217 ROC 选取原则 + 网格搜索范围 |
| P2 | 基线 LEO 适配策略 | ✅ 已修 | L349–357 五条 itemize 逐基线说明 |
| P3 | Aggregate / rank TODO | ✅ 已修 | L197（max+OR+截断）；L245（三级映射+冲突解决）；TODO=0 |
| P4 | $M=1$ 推回收益因果脱节 | ✅ 已修 | L365 "纯粹来自 pushback 路径缩短" 澄清 |
| P5 | 架构描述过长 | ✅ 已修 | L48–68 拆为数据面/控制面两段 + enumerate |
| P6 | $W_\text{waste}$ 近似式适用条件 | ✅ 已修 | L30 "上界估计"声明 |
| P7 | F1 不变与引言矛盾 | ✅ 已修 | L9 改为缓解定位；L428 明确协同价值在缓解层面 |
| P8 | CAIDA 数据集不明 | ✅ 已修 | L300 补充 CAIDA 2018 OC-192 Equinix-Chicago + 缩放方法 |
| P9 | Trickle 未引用、$I$ 未定义 | ✅ 已修 | L105 引用 `\cite{levis2004trickle}` + 差异说明；L159 $I=\Delta/4$ |
| P10 | $\Delta$ 未给具体值 | ✅ 已修 | L300 $\Delta=1$s；表 4-3 参数总表 |
| P11 | 128-bit BF 在 $n=100$ 时 FPR | ✅ 已修 | L147 动态选取 $m$，给出 $n\leq10$ 时 FPR |
| P12 | 未提仿真平台 | ✅ 已修 | L300 "自研 Python 仿真框架" |
| P13 | $r$ 取值未说明 | ✅ 已修 | L222 $r=\min(2,d-1)=2$ |
| L3 | TTL 重置无限传播 | ✅ 已修 | L190 `min(ttl_received-1, R)`；L199 收敛性证明 |
| C5 | PT 无独立字段表 | ✅ 已修 | L130–145 新增表 `tab:pt_format` |
| D6 | 缺 Limitations | ✅ 已修 | L444 三条局限 + 未来方向 |

> **结论**：第一轮提出的全部 16 项意见均已得到有效回应，无遗漏。

---

## 二、修订后新发现的问题

### [N1] 交叉引用标签错误（编译会报 Warning）
- **类别**：技术错误
- **严重程度**：高（编译输出 `??`）
- **定位**：[L284](file:///Users/kc/Documents/论文原稿/chapters/ch4_coop.tex#L284)
- **问题描述**：`\ref{subsec:ch4_eval}` 引用了不存在的标签。实际定义的标签为 `subsec:ch4_results`（L360）和 `sec:ch4_eval`（L295）。
- **修改建议**：根据上下文（"见第 X 节"），应改为 `\ref{subsec:ch4_results}`（指向"结果与分析"小节）或 `\ref{sec:ch4_eval}`（指向"仿真与分析"大节）。

---

### [N2] 残留注释（非 TODO 但属 WIP 痕迹）
- **类别**：清晰性不足（排版规范）
- **严重程度**：低
- **定位**：[L127](file:///Users/kc/Documents/论文原稿/chapters/ch4_coop.tex#L127)
- **问题描述**：`% header 若实现中采用自定义header，请补充header比特布局图（见图~\ref{fig:ch4_header}）。` 该注释属于写作过程中的提醒，已有 fig4_header 图，注释可删除。
- **修改建议**：删除该行。

---

### [N3] TTL 收敛性说明引用行号偏移
- **类别**：清晰性不足
- **严重程度**：低
- **定位**：[L199](file:///Users/kc/Documents/论文原稿/chapters/ch4_coop.tex#L199)
- **问题描述**：文中说"算法第15行中$\texttt{ttl}\leftarrow...$"，但实际在算法伪代码中该语句位于第**12**行（`\begin{algorithmic}[1]` 从第1行编号，`\STATE 设置...ttl` 对应伪代码第12步）。
- **修改建议**：核实算法伪代码行号并修正引用，或改用不依赖行号的表述，如"Aggregate 后的发送步骤中"。

---

### [N4] L217 $\lambda,\mu$ 敏感性实验结果引用缺失
- **类别**：细节不足
- **严重程度**：中
- **定位**：[L217](file:///Users/kc/Documents/论文原稿/chapters/ch4_coop.tex#L217)
- **问题描述**：该段声称"实验表明 $\lambda=1.0, \mu=0.5$ 在多组碎片化设定下均能取得稳定的 F1 和低误推回率（详见第 X 节）"，但在 §4.3.2 的四个子实验中，**未找到 $\lambda,\mu$ 的参数扫描结果**。如果实验确实做过但因篇幅未放入正文，应至少在 §4.3.2 某处以一两句话概括结论并标注"详细数据见补充材料"；如果尚未做该实验，则"实验表明"的措辞构成结论先行。
- **修改建议**：
  1. 若有数据，在 §4.3.2 补充一小段（3–5 句）描述 $\lambda,\mu$ 扫描的主要发现。
  2. 若暂无数据，将"实验表明"改为"初步调参观察到"或"经验选取"，避免暗示存在已完成的系统实验。

---

### [N5] Trickle 引用的 bib 条目不完整
- **类别**：严谨性不足（引用规范）
- **严重程度**：低
- **定位**：[ref.bib L221–228](file:///Users/kc/Documents/论文原稿/ref.bib#L221-L228)
- **问题描述**：Trickle 发表于 NSDI 2004，属 `@inproceedings` 而非 `@article`。当前条目缺少 `booktitle` 字段（应为 `USENIX NSDI`）。
- **修改建议**：
```bibtex
@inproceedings{levis2004trickle,
  title={Trickle: A Self-Regulating Algorithm for Code Propagation and Maintenance in Wireless Sensor Networks},
  author={Levis, Philip and Patel, Neil and Culler, David and Shenker, Scott},
  booktitle={USENIX NSDI},
  pages={15--28},
  year={2004}
}
```

---

## 三、总体评价

修订后的章节质量**显著提升**：

1. **完整性**：所有 TODO 已补齐，Aggregate 策略、rank 映射、基线适配描述完备，参数总表清晰。
2. **逻辑自洽**：引言动机（L9）已精准定位于"缓解层面"，与 §4.3.2(4) 的"F1 不变但缓解显著提升"结论形成闭环。
3. **学术规范**：Trickle 引用已补，BF 参数修正合理，TTL 收敛性有证明。
4. **可复现性**：CAIDA 数据集、仿真平台、全套参数列表均已补充。

新发现的 5 个问题中，**N1（交叉引用错误）** 会导致编译输出 `??`，属高优先级修复；N4（$\lambda,\mu$ 敏感性数据）属中优先级；其余为低优先级排版细节。

---

## 四、修改路线图

| 优先级 | 编号 | 修改内容 | 工作量 |
|:------:|:----:|---------|:-----:|
| 🔴 高 | N1 | 修正 `\ref{subsec:ch4_eval}` → `\ref{subsec:ch4_results}` | <1 min |
| 🟡 中 | N4 | 补充 $\lambda,\mu$ 敏感性数据或修正措辞 | ~30 min |
| 🟢 低 | N2 | 删除 L127 残留注释 | <1 min |
| 🟢 低 | N3 | 修正"算法第15行"行号引用 | <1 min |
| 🟢 低 | N5 | 修正 Trickle bib 条目类型 | <1 min |
