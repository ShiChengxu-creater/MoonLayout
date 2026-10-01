# MoonLayout

纯 MoonBit 的 Unicode 段落布局库。`0.2.0` 保留初验能力，增加最优换行、英文 Liang 连字符、BiDi／归一化集成，支持 native、wasm-gc、JavaScript。

## 使用

```sh
moon add ShiChengxu/moonlayout@0.2.0
```

在消费项目的 `moon.pkg` 导入 `"ShiChengxu/moonlayout" @ml`：

```moonbit
let style = @ml.LayoutStyle::new(16, wrap_algorithm=Optimal, alignment=Justify)
let hyphenator = @ml.Liang::english() // 编译一次，重复使用
let lines = @ml.layout_hyphenated("Hyphenation improves narrow paragraphs.", style, hyphenator)
for line in lines {
  println(line.aligned_text)
}
```

不需要连字符时使用 `@ml.layout(text, style)`；低层接口为 `@ml.wrap`、`@ml.optimal_wrap` 和 `@ml.wrap_hyphenated`。默认仍为贪心换行。`OptimalOptions::new(stretch=2, shrink=1, line_penalty=100, hyphen_penalty=50)` 可配置空格伸缩和代价，通过 `LayoutStyle::new(..., optimal=options)` 传入。

## 可选 Unicode 集成

在 `moon.pkg` 额外导入 `"ShiChengxu/moonlayout/integration"`：

```moonbit
let result = @integration.layout(
  "שלום 123 Ａ",
  @ml.LayoutStyle::new(16),
  normalization=NFKC,
  bidi=true,
)
for line in result.lines {
  println(line.aligned_text)
}
```

`normalization` 可选 `Off`（默认）、`NFC`、`NFKC`；`direction` 可选 `Auto`、`LTR`、`RTL`。集成包也提供 `layout_hyphenated(text, style, hyphenator, ...)`。先归一化，再按逻辑顺序断行，最后按整段解析出的方向级别逐行输出视觉顺序，保留字素簇。

## 能力与坐标约定

- Unicode 17 UAX #14 断行以及 UAX #29 词／句边界；21,794 个官方用例全量验证。
- 贪心与简化最优换行、可插拔 `Hyphenator`、左／右／居中／两端对齐和基础 CJK 字间距分配。
- 所有 `start/end` 和边界位置都是 UTF-8 字节偏移，不能直接用于 MoonBit UTF-16 字符串切片。
- `Line.source` 保留逻辑原文；普通布局拼接各行 `source` 等于输入。集成布局的区间和 `source` 对应 `LayoutResult.logical_text`；原始输入另存为 `original_text`，不提供归一化前后的逐字符反向映射。
- `Line.text` 为逻辑显示内容，行尾空白和硬换行已去掉，tab 已展开，选中的连字符已插入；`aligned_text` 为最终显示文本，`width` 为其显示列数。BiDi 只改变最终视觉输出。
- 空输入返回 `[]`；宽度 ≤ 0 按 1 处理；不可分割的超宽字素允许溢出；末尾硬换行保留最终空行。
- `words` 返回含字母或数字的段，`segments(..., Word)` 保留全部段。连字符插件收到完整词边界段，返回词内 UTF-8 偏移；无效或字素内部断点被过滤。

字素依赖 `kawaz/grapheme@0.10.4`（Unicode 17）。宽度、BiDi、归一化依赖使用 Unicode 16；这些原语不宣称 Unicode 17 一致性。核心布局不导入 BiDi／归一化包，但模块级依赖解析会下载它们。没有字体整形、光栅化或 NLP 分词。详见 [限制](docs/LIMITATIONS.md)。

## 八个示例

```sh
moon run examples/wrap_terminal
moon run examples/cjk_mixed
moon run examples/justify_paragraph
moon run examples/word_boundaries
moon run examples/hyphen_wrap
moon run examples/optimal_wrap
moon run examples/bidi_paragraph
moon run examples/markdown_like
```

可添加 `--target native`、`--target wasm-gc` 或 `--target js`。`markdown_like` 展示应用组合，不是 Markdown 解析器。

## 验证与基准

```sh
python scripts/verify.py
moon bench -p ShiChengxu/moonlayout/benchmarks --target native --release
```

验证涵盖三后端检查和测试、24 次示例运行、生成幂等性、Python／ICU 差分以及打包后独立消费项目。Linux 差分测试需要 `libicu-dev`，Windows 使用系统 ICU；Python 仅用于开发验证。规范测试和核心 API 不访问网络或时钟。

参见 [设计](docs/DESIGN.md)、[测试](docs/TESTING.md)、[UAX 条款矩阵](docs/UAX_SUPPORT.md)、[性能数据](docs/BENCHMARKS.md)。

原始实现采用 Apache-2.0；Unicode 数据和英文连字符模式分别保留其上游许可。参见 [THIRD_PARTY](THIRD_PARTY.md)、[REFERENCES](REFERENCES.md)、[AI_USAGE](AI_USAGE.md)。
