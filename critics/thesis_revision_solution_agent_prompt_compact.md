# 中文学位论文修改方案 Agent 提示词（精简版）

你是一名擅长把“评审意见”转化为“具体修改方案”的中文学位论文顾问。你的任务不是重复批评论文，而是根据我提供的评审意见，结合论文原文，告诉我这章**应该怎么改**，内容要尽可能丰富，文字要尽可能详细，尽可能给出可以直接应用的修改。针对评审提出的意见持批判性态度，不一定要全盘接受，要独立思考。

https://github.com/KingCide/thesis-manuscript/blob/main/thesis0525.tex
这是我论文正文的文件

https://github.com/KingCide/thesis-manuscript/tree/main/chapters
这是我论文各个章节的文件

https://github.com/KingCide/thesis-manuscript/tree/main/figs
这是我所有图片的文件夹


## 你的任务重点

请把已有评审意见转化成可落地的修改建议，尤其关注：

- 公式怎么改
- 应该在正文哪里插入、替换或补充内容
- 新公式可以怎么写
- 图表和实验应该怎么补
- 预期图像应该是什么样
- 理论上结果趋势应该怎样
- 章节结构和文字还应该怎么细化修改
- 针对评审提出的意见持批判性态度，不要全盘接受，要独立思考

## 你在处理公式问题时

请尽量告诉我：
- 当前问题的本质是什么
- 应该改哪一段、加在哪个位置
- 中文过渡怎么写会更自然
- 新公式建议怎么写
- 如果有多种修法，哪种最稳妥，哪种成本最低

## 你在处理图表和实验问题时

请尽量告诉我：
- 应该补什么实验
- 自变量、因变量、对照组分别是什么
- 图适合画成折线图、柱状图、热力图、时序图还是表格
- 横轴纵轴应该是什么
- 理论上图线或柱子应该呈现什么趋势
- 如果结果跑不出这种趋势，可能意味着什么

## 其他问题

对于结构、标题、段落组织、时序记号、参数解释、资源开销这些问题，也请给出更细的修改方案。尽量告诉我：
- 改哪里
- 为什么这样改
- 建议新增一段、一个小节，还是一张表，如果可以，直接

## 输出要求

不必拘泥于固定格式，但请尽量做到：

- 先说最值得优先修改的问题
- 每个问题下面直接给解决方案
- 少说空话，多给可执行建议
- 尽量结合论文中的真实位置
- 如果可以，直接给出修改后的文本
- 如果可以，给出建议公式写法或实验设计
- 内容尽可能丰富，文字尽可能详细

## 默认理解

如果我没有额外说明，你默认：
- 我会给你一份评审意见
- 你需要把它转成具体修改方案
- 你要重点帮助我解决公式、图表实验和文字结构问题
- 你的目标是帮我把这一章修得更扎实，内容更丰富，而不是再次做评审


### 1. 总体评价

本章已经不是“散乱初稿”状态。章节角色较清楚：它在全文中承担的是“单星/单链路视角下的在网检测与本地缓解”，并且与第四章的多星协同推回形成了较自然的前后承接。两轮历史评审中关于时序说明、基线定义、归一化解释、双缓冲实现等基础问题，大多已得到实质修复，这一点应予确认。

但从严格盲审标准看，本章还没有完全闭环。当前最大优点是“退化证据链”思路明确，`rate -> FI/FO -> persist` 的叙述线索清楚；最大短板是三处核心支撑仍不够硬：一是关键理论式存在自洽性问题，二是“队列缓解”贡献缺少专门实验闭环，三是实验与图表支撑尚不完整，甚至存在正文引用了不存在图的硬伤。它目前更像“有基础但不够扎实”，还差一轮针对核心论证链的补强，才更接近成熟硕士论文章节。

### 2. 主要问题清单（按严重程度排序）


2. **核心理论式 `FI_decoy` 推导自相矛盾**  
严重程度：高  
位置：[ch3_ms_satshield.tex#L42](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L42)、[ch3_ms_satshield.tex#L44](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L44)、[ch3_ms_satshield.tex#L47](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L47)  
问题描述：式 `FI_decoy = |B|/M * η` 与后文“若 `FO=1`，则 `FI=|B|/M`”不一致。按文中定义，若 `FO=Mη=1`，则 `η=1/M`，代回当前公式应得到 `FI=|B|/M^2`，而不是正文写的 `|B|/M`。  
为什么这是问题：这是本章引入 FI/FO 作为“速率退化后仍可检测”的理论动机核心；若这里不自洽，整章方法动机会被质疑。  
评审风险：评审很容易抓住这一点，认为“多签名的理论依据并未立稳”。  
具体修改建议：不要继续用当前 `η` 写法。更稳妥的写法是定义“每个 bot 平均访问 `d` 个 decoy”，则 `FO_bot=d`，平均 `FI_decoy=|B|d/M`；极端情形 `d=1` 时自然得到 `FO=1, FI=|B|/M`。这样公式、极端案例和后文解释才能统一。

3. **“队列缓解”贡献缺少独立实验闭环**  
严重程度：高  
位置：[ch3_ms_satshield.tex#L105](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L105)、[ch3_ms_satshield.tex#L118](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L118)、[ch3_ms_satshield.tex#L225](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L225)、[ch3_ms_satshield.tex#L250](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L250)  
问题描述：方法部分专门定义了 `score -> rank -> queue` 映射，但实验主体几乎都在验证检测指标；缓解侧只有零散的良性吞吐数字和 `Δ` 敏感性，没有专门回答“分级队列调度到底比二元丢弃好多少、误伤代价是多少”。  
为什么这是问题：章节标题是“检测与队列缓解方法”，但当前实证重点仍偏“检测器”。  
评审风险：会被质疑“缓解只是附带设定，不是被充分验证的贡献”。  
具体修改建议：新增一小节“队列缓解效果与误伤代价分析”，至少给出 `No defense / Hard drop / S0 / S1 / S2` 的对比表或图，报告良性吞吐、攻击抑制率、反应时间、误伤代价、队列占用或丢包分布。

4. **关键参数设置仍属启发式，且文中承诺未兑现**  
严重程度：高  
位置：[ch3_ms_satshield.tex#L95](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L95)、[ch3_ms_satshield.tex#L197](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L197)、[ch3_ms_satshield.tex#L274](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L274)  
问题描述：正文说“消融实验将进一步分析权重选取”，但实际只分析了 `K、m、Δ`，没有分析 `α、β、γ、τ、Q` 以及高优先级带宽比 `0.8`。  
为什么这是问题：当前方法本质是启发式评分+阈值+队列映射，若这些超参数没有敏感性分析，结果就容易显得“挑了一个好看的配置”。  
评审风险：容易被追问“为什么是 0.5/0.5/0.2”“为什么阈值 0.5”“为什么 4 队列”“为什么 80/20”。  
具体修改建议：补一张热力图或表，至少覆盖 `α/β`、`γ`、`τ` 的联合敏感性；若不补实验，就删掉“将进一步分析权重选取”的承诺，并把措辞改成“经验设置”。

5. **实现与时序记号前后不一致，影响可复现性**  
严重程度：中  
位置：[ch3_ms_satshield.tex#L82](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L82)、[ch3_ms_satshield.tex#L84](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L84)、[ch3_ms_satshield.tex#L145](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L145)、[ch1_intro.tex#L96](/Users/kc/Documents/论文原稿/chapters/ch1_intro.tex#L96)、[ch2_background.tex#L133](/Users/kc/Documents/论文原稿/chapters/ch2_background.tex#L133)、[ch2_background.tex#L135](/Users/kc/Documents/论文原稿/chapters/ch2_background.tex#L135)  
问题描述：本章先说 epoch `t` 的包处理使用 `H_{t-1}` 与 `rank_{t-1}`，后文和算法又写成 `H_t`、`rank_t`；同时第一章/第二章写“Count-Min Sketch 作为 top-k 底层”，本章正文却写“采用 Space-Saving”。  
为什么这是问题：这不是措辞小问题，而是“你到底实现了什么”的问题。  
评审风险：会被认为方法描述不稳定、全文前后没有完全对齐。  
具体修改建议：统一成一种时序记号，并在全文统一一级候选结构的表述；如果最终实现确实是 Space-Saving，就把第一章和第二章对应表述同步改掉。

6. **资源开销与队列配置表述不自洽**  
严重程度：中  
位置：[ch3_ms_satshield.tex#L118](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L118)、[ch3_ms_satshield.tex#L198](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L198)、[ch3_ms_satshield.tex#L286](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L286)、[ch3_ms_satshield.tex#L318](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L318)、[fig3-5_architecture.png](/Users/kc/Documents/论文原稿/figs/ch3/fig3-5_architecture.png)  
问题描述：正文说 `Q=4`，但架构图只画了 `Queue 0` 和 `Queue 1` 的二分类；正文说位图约 `32 KB`、总状态约 `200 KB`，而架构图上写的是 `Bitmap(×2)=64 KB`、总计约 `96 KB`。  
为什么这是问题：低开销和可实现性是本章的重要卖点，资源账一旦对不上，卖点就会变弱。  
评审风险：会被质疑“到底算没算双缓冲”“到底是 2 队列还是 4 队列”“总状态究竟是多少”。  
具体修改建议：单独给一张“状态开销分解表”，明确区分单缓冲/双缓冲、bitmap/top-k/bytes/tables；若实验确实用 `Q=4`，就把架构图也改成 4 级队列，或补一张 `score 区间 -> QID -> 带宽份额` 表。

7. **实验覆盖与论断范围不匹配**  
严重程度：中  
位置：[ch3_ms_satshield.tex#L49](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L49)、[ch3_ms_satshield.tex#L65](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L65)、[ch3_ms_satshield.tex#L169](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L169)、[ch3_ms_satshield.tex#L207](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L207)  
问题描述：本章反复写“FO/FI”和“速率下沉、多 decoy 分摊、on-off 三类退化”，但实验实际上主要验证的是“目的地址 key 下的 FI + 多 decoy/on-off”；没有单独展示 FO 的贡献，也没有独立的“bot 规模增大/单 bot 速率下降”实验。  
为什么这是问题：结论范围大于证据范围。  
评审风险：会被追问“FO 的价值在哪里”“速率下沉是否真的单独成立”。  
具体修改建议：补两个小实验即可：`FI-only / FO-only / FI+FO` 比较；在固定总攻击量下扫描 `|B|` 与 `r_b` 的速率下沉实验。若不补，就把措辞收缩为“本章实验主要验证 FI 主导场景”。

### 3. 专项审查

#### 3.1 讲得不够清楚的地方
- `η` 的物理意义没有讲清，导致式与文字解释冲突。
- `H_t`、`rank_t` 到底表示“当前统计窗口”还是“当前生效配置”，正文和算法没有完全统一。
- 实际队列配置不清楚：文字是 `Q=4`，图里却是二分类队列。
- 动态 on-off 图即使补进正文，也需要把四个子图分别解释，否则读者很难快速抓到“persist 到底改善了什么”。

#### 3.2 论述不够严谨的地方
- “攻击者无法同时压缩速率与 FI/FO”目前论证过强，且公式不自洽，不能直接下结论。
- “约 20 个良性 key 是可接受代价”属于工程判断，不是自然成立的学术结论；需要用业务吞吐、误伤比例或 QoS 指标支撑。
- “帕累托最优性”表述偏满。当前只是有限参数点下的经验折中，不宜上升为严格“最优”。

#### 3.3 可以增加更详细内容的地方
- 在 [ch3_ms_satshield.tex#L271](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L271) 后新增“动态攻击与缓解收益”小节，系统呈现 S0/S1/S2 的缓解表现。
- 在 [ch3_ms_satshield.tex#L274](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L274) 后新增“权重/阈值/队列份额敏感性”。
- 在 [ch3_ms_satshield.tex#L184](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L184) 的参数表之后新增“状态开销分解表”。
- 在 [ch3_ms_satshield.tex#L209](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L209) 后补一个“速率下沉设定表”。
- 若坚持保留 FO 叙述，需补一组 `FI-only / FO-only / FI+FO` 对比表。

#### 3.4 存在逻辑问题的地方
- 章节标题写“检测与队列缓解”，但实验主体仍是“检测器效果”；标题和实证重心还没完全一致。
- [ch3_ms_satshield.tex#L53](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L53) 的“可分性分析与退化动机”已经用了具体实验数据和图，但正式实验设置到 [ch3_ms_satshield.tex#L165](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L165) 才出现，方法与证据顺序略混。
- 第一章、第二章和第三章对一级候选结构的表述不一致，影响全文主线一致性。
- [ch3_ms_satshield.tex#L308](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L308) 的文献对比段落放在参数敏感性后面，逻辑归属不清。

#### 3.5 结构与标题优化建议
- 当前总结构基本合理，但建议把 §3.2.2 明确改名为“预实验：速率可分性退化”，或者直接移到实验部分开头。
- 建议将实验大节重组为：“实验设置”“静态退化结果”“动态攻击与缓解结果”“参数敏感性”“讨论与边界”。
- 建议把 [ch3_ms_satshield.tex#L308](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L308) 单独设为“与已有 LFA 防御方法的部署适用性讨论”。
- 若短期内不补 FO 实验，部分标题和图注应收缩为“结构特征（以 FI 为主）”，避免范围过大。

### 4. 公式专项审查

| 公式位置 | 当前作用 | 结论 | 修改建议 |
|---|---|---|---|
| [ch3_ms_satshield.tex#L21](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L21)、[ch3_ms_satshield.tex#L29](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L29)、[ch3_ms_satshield.tex#L36](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L36) | `R/F/P` 基本定义 | 值得保留 | 定义性公式，必要且与后文直接相关。只需把时间索引与 `H_t` 的语义再统一。 |
| [ch3_ms_satshield.tex#L43](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L43) | 说明速率退化与结构特征关系 | 存疑，需重写 | 当前 `η` 定义、极端案例与结论不一致。建议改用“每 bot 访问 decoy 数 `d`”重写。 |
| [ch3_ms_satshield.tex#L91](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L91)、[ch3_ms_satshield.tex#L98](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L98)、[ch3_ms_satshield.tex#L111](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L111) | 评分、归一化、队列映射 | 应保留，但支撑不够 | 公式本身有价值，但必须补参数敏感性、队列区间表和实际缓解效果实验。 |
| [ch3_ms_satshield.tex#L106](/Users/kc/Documents/论文原稿/chapters/ch3_ms_satshield.tex#L106) | `rank=g(S)` 抽象映射 | 可弱化 | 这一式信息量较低，完全可以并入分段映射式，避免“拆成两条公式但实际只有一条有内容”。 |

建议补充的公式：
- `T_react = t_{\text{mitigation-start}} - t_{\text{first-attack}}`
- `Drop_{\text{benign}} = 1 - Thr^{\text{attack}}_{\text{benign}} / Thr^{\text{pre}}_{\text{benign}}`
- `M_{\text{bitmap}} = 2Km/8`，并进一步写出总状态预算公式，解释双缓冲为何导致 32 KB 与 64 KB 的区别

不建议硬加公式的地方：
- 不要把“图 3-1 的经验观察”硬写成可分性定理，除非你真能给出严格条件。
- 不要为显得形式化而把 Crossfire/ICARUS 的全局攻击优化模型搬进来；第 3 章的核心不是攻击优化，而是单星检测与本地缓解。

### 5. 图表专项审查

当前图表“数量不少”，但“证据闭环还不够”。最有价值的是 [fig3_1_cdf.png](/Users/kc/Documents/论文原稿/figs/ch3/fig3_1_cdf.png) 和 [fig3_2a_topk_f1.png](/Users/kc/Documents/论文原稿/figs/ch3/fig3_2a_topk_f1.png) / [fig3_2b_degrade_f1.png](/Users/kc/Documents/论文原稿/figs/ch3/fig3_2b_degrade_f1.png)，因为它们确实把“rate 退化”“候选覆盖”和“FI 补救”分开了。`ablation_m` 也有信息量，因为它把误差与内存的权衡画出来了。

信息不足或不清晰的地方有三处。第一，[fig3_4_onoff.png](/Users/kc/Documents/论文原稿/figs/ch3/fig3_4_onoff.png) 文件存在但未正式入文，这是硬伤；而且该图四联图加两个放大窗，在学位论文打印版里偏密，建议拆图或放大。第二，[fig3-5_architecture.png](/Users/kc/Documents/论文原稿/figs/ch3/fig3-5_architecture.png) 与正文 `Q=4`、内存数字不一致，会削弱说服力。第三，目前只有参数表和退化设定表，没有“主结果汇总表”，导致评审需要在多张图里自己拼数字。

建议新增或补强的图表：
- 新增“主结果汇总表”：按场景汇总 `Precision/Recall/F1/benign throughput/reaction time`
- 新增“权重-阈值敏感性热力图”或表
- 新增“FI-only / FO-only / FI+FO”对比表
- 新增“速率下沉实验表/图”
- 新增“score 区间 -> 队列等级 -> 带宽份额”参数表
- 新增“状态开销分解表”，明确双缓冲是否计入

### 6. 内容扩写路线图

**必须优先补**
- 重写 `FI_decoy` 那一组推导，确保符号定义、极端案例、结论完全一致。
- 增加一节“缓解效果与误伤代价分析”，把“队列缓解”真正做成实证贡献。
- 补 `α/β/γ/τ/Q/带宽份额` 的敏感性；如果来不及做全量实验，至少做 `α/β/τ` 三维中的一部分。

**建议补**
- 全文统一 top-k 一级候选结构，到底是 CMS 还是 Space-Saving。
- 统一 `H_t/H_{t-1}` 的时序记号，并在算法和架构图中同步。
- 补“FI-only / FO-only / FI+FO”与“速率下沉”两组小实验，防止论断范围大于证据。
- 重画架构图或补表，解决 `Q=4` 与“两队列图”、`32/64/96/200 KB` 多套数字并存的问题。

**可选增强**
- 把 §3.2.2 改成“预实验”，或者移动到实验部分开头。
- 将“帕累托最优”改成“经验上较优折中”。
- 增加一个简短的“部署更新机制说明”，交代 `Q0.99` 如何在线更新、何时重标定。

### 7. 最终结论

这章目前更像：**有基础但不够扎实**。

最核心的 3 个阻碍点是：
- 核心理论推导还不完全自洽，尤其是 `FI/FO` 动机公式。
- “队列缓解”尚未形成独立、完整、可抗质疑的实验闭环。
- 图表与参数支撑还不完整，动态图缺失、资源账不统一、部分结论超出了当前证据范围。