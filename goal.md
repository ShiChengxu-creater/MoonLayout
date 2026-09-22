# MoonLayout 项目完整计划

## 一、项目基本信息

**项目名称：** MoonLayout
**包命名空间：** `ShiChengxu/moonlayout`
**项目类型：** 原创 MoonBit 开源库；复用生态已有 Unicode 原语，补齐缺失的断行/布局层
**许可证：** Apache-2.0（Unicode 数据表遵循 Unicode License v3，记入 THIRD_PARTY.md）
**Unicode 版本：** 17.0.0（与依赖 `kawaz/grapheme` 对齐）
**目标后端：** native、wasm-gc、js
**初验版本：** `0.1.0`
**终验版本：** `1.0.0`
**目标代码规模：**

- 初验：4,500～5,500 行有效 MoonBit 代码
- 终验：7,500～9,500 行有效 MoonBit 代码

## 二、项目最终定位

> MoonLayout 是一个纯 MoonBit 的 Unicode 段落布局引擎：把逻辑文本流排布为"行"，负责断行点计算、词/句边界、按显示宽度换行、对齐与两端对齐，并可插拔连字符。

它**不重复实现**生态已有的归一化、双向文本、字素切分与宽度计算，而是组合它们：

```text
逻辑文本 String
  ↓ 归一化（可选，moonbit-community/normalization）
  ↓ 字素切分（kawaz/grapheme）
  ↓ 显示宽度（moonbit-community/unicodewidth）
  ↓ 双向解析（可选，moonbit-community/bidi）
  ↓
断行点（UAX#14） + 词/句边界（UAX#29）
  ↓
换行算法（贪心 / 最优）
  ↓
对齐 / 两端对齐
  ↓
Array[Line]（每行：原文区间、宽度、断点类型）
```

MoonLayout 不是正则引擎、不是字体/整形库、不是渲染器。

## 三、项目解决的实际问题

MoonBit 生态已具备归一化、BiDi、字素切分、宽度计算，但**没有任何包负责"把一段文本排成若干行"**。需要在 MoonBit 中做终端 UI、编辑器、文档预览、报表、富文本的应用，仍要自行解决：

- 哪些位置可以断行（UAX#14 断行类与禁则）
- 按词边界还是字素边界换行（UAX#29）
- 中日韩与拉丁混排时的断行与宽度
- 超长无空格串如何强制切分
- 左右中与两端对齐
- 行尾空格处理、软换行、连字符断词
- 每行实际显示宽度与原文区间映射

MoonLayout 的价值：

1. 补齐 MoonBit 缺失的**断行/段落布局层**（生态空白）。
2. 用 Unicode 官方 `LineBreakTest.txt`、`WordBreakTest.txt`、`SentenceBreakTest.txt` 证明正确性。
3. 组合既有原语，明确独立贡献，不重复造轮子。
4. 提供可直接用于 TUI / 编辑器 / 文档 / 报表的高层 API。
5. 为后续富文本、排版、终端库提供基础。

## 四、与现有项目的区别

### 4.1 已有能力（截至 2026-09-10，来自 mooncakes 全量索引）

| 能力 | 已有包 | 处理方式 |
|---|---|---|
| UAX#15 归一化 | `moonbit-community/normalization` | **依赖或可选调用，不重造** |
| UAX#9 双向文本 | `moonbit-community/bidi` | **依赖或可选调用，不重造** |
| UCD 属性 / 大小写 | `moonbit-community/ucd` | 复用通用属性，不重造 |
| 字符/字符串宽度 | `moonbit-community/unicodewidth`、`rami3l/unicodewidth` | **依赖** |
| UAX#29 字素簇 | `kawaz/grapheme`（Unicode 17.0.0） | **依赖** |
| 字素显示单元边界 | `moonbit-community/displaytext` | 参考，边界不同（仅显示单元） |
| emoji 切分 (UTS#51) | `fundon/emoji` | 不涉及 |
| 中文分词 / NLP | `colmugx/jieba`、`ppyq882/moonnlp` | 词典分词，与规范边界不同 |

### 4.2 MoonLayout 的差异化能力

| 已有项目主要能力 | MoonLayout 主要能力 |
|---|---|
| 字素切分 | UAX#14 断行点 |
| 宽度计算 | UAX#29 词/句边界 |
| 显示单元边界 | 按宽度换行（贪心/最优） |
| 归一化、BiDi | 对齐 / 两端对齐 / 连字符 |
| 单点原语 | 组合成"文本 → 行"的段落布局流水线 |

核心不是：

```text
graphemes("...") 或 width("...")
```

而是：

```text
给定文本、最大宽度与样式，返回符合 UAX#14/#29 的行划分与对齐结果。
```

## 五、项目设计原则

### 5.1 组合而非重造
断行/词句所需属性表自行生成（生态未提供 `Line_Break`/`Word_Break`/`Sentence_Break`）；归一化/BiDi/字素/宽度复用既有包。

### 5.2 纯函数、无 IO
核心包不读文件/网络/时钟；属性表为只读常量。

### 5.3 规范驱动
每项能力对应 UAX 章节 + 官方一致性测试 + 正常/边界/异常测试。

### 5.4 数据与算法分离
`break_data` 只读表（生成器产出）→ `linebreak`/`segment` 算法 → `wrap`/`align` → `layout` 门面。

### 5.5 跨后端一致
native、wasm-gc、js 上 `moon check`/`moon test` 通过，行为一致。

## 六、功能边界

### 6.1 项目负责
- UAX#14 断行机会（含强制断行、CJK 断行、基础禁则）
- UAX#29 词边界与句边界（字素委托 `kawaz/grapheme`）
- 按显示宽度的换行：贪心算法（初验）与最优算法（终验）
- 对齐：左 / 右 / 居中 / 两端对齐（含 CJK 字间距分配）
- 可插拔连字符（终验，先提供英文 Liang 模式）
- 段落布局门面：`layout(text, style) -> Array[Line]`
- 断点类型与原文区间映射
- UCD 断点属性生成器（native 开发工具）

### 6.2 项目不负责
- 归一化、BiDi、字素切分、宽度计算（复用既有包）
- 字体、字形整形（shaping）、OpenType、渲染、光栅化
- 正则、Markdown、富文本样式树
- 词典分词 / 自然语言处理
- 语言特定断行 tailoring 全集（仅提供可扩展接口与基础 CJK 处理）
- 网络与文件 IO

### 6.3 初期暂不支持
- 最优换行的完整 Knuth-Plass（初验用贪心；终验实现简化最优）
- 多语言连字符词典全集
- 竖排 / 复杂书写系统整形
- 双向文本的完整段落重排集成（终验按需接入 `bidi`）
- 段落级断页 / 分栏

## 七、总体架构

```text
MoonLayout/
├── moon.mod
├── README.mbt.md
├── LICENSE
├── THIRD_PARTY.md
├── REFERENCES.md
├── AGENTS.md
├── goal.md
│
├── break_data/                  # L0 断点属性表（生成）
│   ├── moon.pkg
│   ├── line_break.mbt
│   ├── word_break.mbt
│   ├── sentence_break.mbt
│   ├── extended_pictographic.mbt
│   └── *_test.mbt
│
├── linebreak/                   # UAX#14
├── segment/                     # UAX#29 word / sentence
├── wrap/                        # 贪心 + 最优换行
├── align/                       # 对齐 / 两端对齐
├── hyphen/                      # 连字符（终验）
├── layout/                      # 段落布局门面
│
├── tools/ucd_gen/               # UCD 断点属性生成器（native 开发工具）
│
├── examples/
│   ├── wrap_terminal/
│   ├── cjk_mixed/
│   ├── justify_paragraph/
│   ├── word_boundaries/
│   └── hyphen_wrap/
│
├── testdata/ucd/                # LineBreakTest / WordBreakTest / SentenceBreakTest
├── scripts/fetch_ucd.ps1
├── docs/
└── .github/workflows/ci.yml
```

### 7.1 依赖方向

```text
tools/ucd_gen ──生成──▶ break_data
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
          linebreak       segment        (grapheme/width 依赖)
              │              │
              └──────┬───────┘
                     ▼
                   wrap ──▶ align ──▶ layout
                                      ▲
                                   hyphen（可插拔）
```

`break_data` 不依赖算法包；`linebreak`/`segment` 互不依赖；`wrap` 依赖 `linebreak`+`segment`+字素+宽度；`layout` 为唯一高层门面。

### 7.2 外部依赖（计划）
- `kawaz/grapheme` — 字素簇切分（Unicode 17.0.0）
- `moonbit-community/unicodewidth` — 显示宽度
- 可选：`moonbit-community/bidi`、`moonbit-community/normalization`（仅在相应示例/集成中使用，核心不强制）

## 八、核心数据模型与 API

### 8.1 断行（UAX#14）
```moonbit
pub fn line_break_opportunities(s : String) -> Array[Int]   // 字节位置
pub fn is_breakable_at(s : String, byte_index : Int) -> Bool
```

### 8.2 词/句边界（UAX#29）
```moonbit
pub enum SegmentKind { Word; Sentence }
pub fn segments(s : String, kind : SegmentKind) -> Array[(Int, Int)] // [start, end)
pub fn words(s : String) -> Array[String]
pub fn sentences(s : String) -> Array[String]
```

### 8.3 换行
```moonbit
pub enum WrapAlgorithm { Greedy; Optimal }
pub fn wrap(text : String, max_width : Int, opts? : WrapOptions) -> Array[Line]
```

### 8.4 对齐
```moonbit
pub enum Alignment { Left; Right; Center; Justify }
pub fn align_lines(lines : Array[Line], width : Int, alignment : Alignment) -> Array[String]
```

### 8.5 门面
```moonbit
pub struct LayoutStyle {
  max_width : Int
  alignment : Alignment
  ambiguous_wide : Bool
  wrap_algorithm : WrapAlgorithm
  hyphenator : Hyphenator?
}
pub fn layout(text : String, style : LayoutStyle) -> Array[Line]
```

`Line` 携带原文区间、显示宽度、断点类型（软/硬/强制）与对齐后文本。

## 九、初验阶段计划（0.1.0）

### 9.1 初验目标
可独立安装、运行、集成：给定文本与宽度，输出符合 UAX#14/#29 的换行结果，并支持左/右/居中/两端对齐。

### 9.2 初验功能范围
**A. break_data 与生成器**：从 UCD 17.0.0 解析 `LineBreak.txt`、`auxiliary/WordBreakProperty.txt`、`auxiliary/SentenceBreakProperty.txt`、`emoji/emoji-data.txt`（Extended_Pictographic）；区间压缩表。

**B. linebreak（UAX#14）**：LB1～LB31 规则；强制断行；CJK 断行；通过 `LineBreakTest.txt`。

**C. segment（UAX#29）**：词边界 WB1～WB999、句边界 SB1～SB998；通过 `WordBreakTest.txt`、`SentenceBreakTest.txt`；字素委托 `kawaz/grapheme`。

**D. wrap（贪心）**：结合断行点、词/句与显示宽度；超长无断点串强制按字素切分；空串/宽度边界。

**E. align**：左/右/居中/两端对齐；行尾空格处理；CJK 两端对齐字间距分配。

**F. 示例（≥4）**：`wrap_terminal`、`cjk_mixed`、`justify_paragraph`、`word_boundaries`。

### 9.3 初验测试目标
- `LineBreakTest.txt`、`WordBreakTest.txt`、`SentenceBreakTest.txt` 全量通过
- 每模块正常/边界/异常测试
- 属性测试：断点单调且落在字素边界；换行不丢字符；拼接各行等于原文（忽略空白归一）
- 不访问网络、不读系统时钟

### 9.4 初验代码规模

| 模块 | 预计有效代码 |
|---|---:|
| break_data（区间压缩表） | 1,200～1,600 |
| tools/ucd_gen | 500～700 |
| linebreak | 1,200～1,600 |
| segment（word/sentence） | 900～1,200 |
| wrap（贪心） | 500～700 |
| align | 400～600 |
| 示例与测试辅助 | 300～500 |
| **合计** | **约 5,000～6,900** |

### 9.5 初验验收标准
- 项目公开可访问，MoonBit 为核心实现语言
- `moon check --deny-warn` 无警告；`moon test --deny-warn` 全通过
- 核心包在 native、wasm-gc、js 上检查通过
- 三个官方一致性测试全量通过
- mooncakes.io `0.1.0` 可安装
- README 含最小示例且可复现
- 四个示例可运行
- `THIRD_PARTY.md` 记录 Unicode License v3 与依赖来源
- Git 提交体现各里程碑

## 十、终验阶段计划（1.0.0）

### 10.1 终验目标
成为可被 TUI / 编辑器 / 文档工具依赖的段落布局引擎，支持最优换行、两端对齐与连字符，并与 BiDi/归一化集成。

### 10.2 终验新增功能
**A. 最优换行（简化 Knuth-Plass）**：badness/penalty 模型、可配置拉伸与压缩；与贪心结果对照基准。

**B. 连字符（可插拔）**：`Hyphenator` trait；内置英文 Liang 模式；与换行联动（行尾连字符）。

**C. BiDi 集成**：接入 `moonbit-community/bidi`，按逻辑序断行、视觉序输出。

**D. 归一化集成**：接入 `moonbit-community/normalization`，布局前可选 NFC/NFKC。

**E. 性能与基准**：`moon bench` 覆盖断行/切分/换行/对齐；大文本基线。

**F. 文档与稳定性**：`docs/UAX_SUPPORT.md`（条款矩阵）、`DESIGN.md`、`TESTING.md`、`LIMITATIONS.md`；API 稳定化。

### 10.3 终验示例（≥8）
在初验 4 个基础上增加：`hyphen_wrap`、`optimal_wrap`、`bidi_paragraph`、`markdown_like`。

### 10.4 终验代码规模

| 模块 | 最终预计代码 |
|---|---:|
| break_data | 1,600～2,000 |
| tools/ucd_gen | 600～800 |
| linebreak | 1,400～1,800 |
| segment | 1,000～1,300 |
| wrap（贪心+最优） | 1,100～1,500 |
| align（含两端对齐） | 600～900 |
| hyphen | 900～1,300 |
| layout 门面与集成 | 500～800 |
| 基准与测试辅助 | 300～500 |
| **合计** | **约 8,000～10,900** |

目标控制在约 9,000 行，不超过 10,000。

### 10.5 终验验收标准
- 发布 `1.0.0`，初验能力全部保留
- 全部 UAX 一致性测试通过
- 贪心与最优换行均可运行并有基准对比
- 连字符与 BiDi/归一化集成示例可运行
- `docs/UAX_SUPPORT.md` 条款矩阵完整
- 所有第三方来源与许可证清晰
- CI 在干净环境完成三后端 fmt/check/test 与示例运行

## 十一、开发里程碑

### M0：仓库与约束
`moon.mod` 改名、LICENSE、README 骨架、`AGENTS.md`、`goal.md`、`THIRD_PARTY.md`、CI 骨架、一致性测试数据。

### M1：break_data 与生成器
UCD 断点属性解析、区间压缩、查表 API、生成幂等。

### M2：linebreak（UAX#14）
规则状态机，通过 LineBreakTest。

### M3：segment（UAX#29）
词/句边界，通过 WordBreakTest / SentenceBreakTest。

### M4：wrap（贪心）+ align + 初验收口
四个示例、README、mooncakes `0.1.0`。**对应初验。**

### M5：最优换行
简化 Knuth-Plass 与基准对比。

### M6：连字符
Hyphenator trait + 英文 Liang 模式。

### M7：集成
BiDi / 归一化集成示例。

### M8：终验产品化
UAX 矩阵、差分测试、API 稳定化、mooncakes `1.0.0`。

## 十二、测试体系

### 12.1 官方一致性测试
`testdata/ucd/`：`LineBreakTest.txt`、`WordBreakTest.txt`、`SentenceBreakTest.txt`（Unicode 17.0.0）。

### 12.2 属性测试
- 断点位置单调递增且落在字素边界
- 换行不丢失字符；各行拼接可还原原文（除换行处空白归一）
- 空串、宽度 0、单字符、超长无断点串
- 对齐后显示宽度等于目标宽度（两端对齐非末行）

### 12.3 差分测试
与 Python `textwrap` / `unicodedata` 及 ICU 断行结果对照；差异归类并记入 `REFERENCES.md`。不复制对方源码。

### 12.4 快照测试
对行划分与对齐输出使用 `debug_inspect` 快照，变更时 `moon test --update` 复核。

## 十三、CI 设计

```bash
moon fmt --check
moon check --deny-warn
moon test --deny-warn
moon info
```

三后端矩阵：
```bash
moon check --target native --deny-warn
moon check --target js --deny-warn
moon check --target wasm-gc --deny-warn
moon test  --target native
moon test  --target js
moon test  --target wasm-gc
```

其他：示例运行、`.mbti` 差异、许可证检查、发布包检查、mooncakes 安装测试。

## 十四、文档目标

```text
README.mbt.md
LICENSE
CHANGELOG.md
CONTRIBUTING.md
CODE_OF_CONDUCT.md
SECURITY.md
THIRD_PARTY.md
REFERENCES.md
AI_USAGE.md
docs/
├── SCOPE.md
├── DESIGN.md
├── UAX_SUPPORT.md
├── DATA_PIPELINE.md
├── TESTING.md
├── BENCHMARKS.md
├── LIMITATIONS.md
└── RELEASE.md
```

## 十五、开源与 AI 使用方案

### 15.1 实现方式
基于 Unicode UAX#14/#29 独立实现断行与切分；复用生态既有归一化/BiDi/字素/宽度包并致谢；Unicode 数据按 Unicode License v3 使用并记录。

### 15.2 AI 使用记录
`AI_USAGE.md` 记录 AI 参与模块、人工复核方式、所用规范与公开参考、测试如何验证、是否含第三方代码、许可证检查过程、人工完成的关键设计决策。

## 十六、主要风险与应对

**风险一：与生态重叠**
应对：明确只做断行/词句/换行/对齐/连字符；复用既有原语；README 列出依赖与独立贡献。

**风险二：生成表膨胀或靠表凑行数**
应对：区间压缩；区分生成数据与算法；不逐码点堆行。

**风险三：UAX#14 规则复杂**
应对：规则逐条实现、逐条测试；以 LineBreakTest 为硬门槛；先基础规则再 CJK 与 tailoring。

**风险四：规模偏小**
应对：终验加入最优换行、连字符、对齐、集成与基准；不靠重复代码凑行。

**风险五：依赖版本漂移**
应对：锁定依赖版本；核心仅强依赖 grapheme/width；bidi/normalization 可选。

**风险六：跨后端差异**
应对：纯函数、无平台相关代码；三后端 CI。

## 十七、项目成功标准

1. 下游可用 `layout` 把文本排成指定宽度的行。
2. 中日韩与拉丁混排断行正确。
3. 支持左/右/居中/两端对齐。
4. 支持最优换行与英文连字符。
5. 官方一致性测试全量通过。
6. 复用而非重复既有 Unicode 原语，独立贡献清晰。
7. native/wasm-gc/js 行为一致。
8. 初验已实用，终验完成产品化而非重写。

## 十八、初验与终验目标摘要

### 初验 `0.1.0`
```text
break_data + ucd_gen
+ linebreak（UAX#14）
+ segment（UAX#29 word/sentence）
+ wrap（贪心）
+ align（左/右/居中/两端）
+ 4 个示例
+ 官方一致性测试
+ mooncakes.io 发布
```
目标：5,000～6,900 行；一致性测试通过；可用于实际换行与对齐。

### 终验 `0.2.0`
```text
初验全部能力
+ 最优换行（简化 Knuth-Plass）
+ 连字符（Liang，可插拔）
+ BiDi / 归一化集成
+ 性能基准
+ 差分测试
+ UAX 条款矩阵与完整文档
```
目标：8,000～10,000 行；8 个示例；全部一致性测试通过；稳定 API；mooncakes.io `1.0.0`。

## 十九、最终项目说明

> MoonLayout 是一个纯 MoonBit、跨 native/wasm-gc/js 的 Unicode 段落布局引擎，依据 Unicode 17.0.0 实现 UAX#14 断行与 UAX#29 词/句边界，提供按显示宽度的贪心与最优换行、左/右/居中/两端对齐以及可插拔连字符。项目复用生态已有的归一化、双向文本、字素切分与宽度计算，不重复实现这些基础层，专注补齐 MoonBit 生态中缺失的断行与段落布局能力。
