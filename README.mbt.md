# MoonLayout

纯 MoonBit 的 Unicode 17.0.0 段落布局库，支持 native、wasm-gc、JavaScript。

## 最小示例

消费包在 `moon.pkg` 中导入 `"ShiChengxu/moonlayout" @ml`，然后调用`@ml.layout(text, @ml.LayoutStyle::new(width, alignment=Center))`。
下面的根包文档测试由 `moon test` 实际编译执行：

```mbt nocheck
///|
test "README minimum layout" {
  let lines = layout("你好 MoonBit", LayoutStyle::new(8, alignment=Left))
  assert_eq(lines.map(fn(line) { line.text }), ["你好", "MoonBit"])
  assert_eq(lines.map(fn(line) { line.aligned_text }), [
    "你好    ", "MoonBit ",
  ])
  assert_eq(lines.map(fn(line) { line.source }).join(""), "你好 MoonBit")
}
```

发布后可执行 `moon add ShiChengxu/moonlayout@0.1.0`；发布前使用本地 workspace消费方式，见 [TESTING](docs/TESTING.md)。

## 能力与约定

- UAX #14 LB1–LB31：19,338 个 Unicode 17 官方断行用例。
- UAX #29：1,944 个词边界和 512 个句边界官方用例。
- 贪心换行、词／句边界偏好、超长词按完整字素强制切分。
- 左／右／居中／两端对齐；中日韩字间距分配。
- 所有公开位置均为 **UTF-8 字节偏移**，不是 MoonBit UTF-16 字符串索引。
- `Line.source` 与 `[start,end)` 精确保留原文；拼接 source 可还原输入。
- `Line.text` 去掉行尾 ASCII 空格、tab 和硬换行；内部 tab 展开为制表位。`aligned_text` 为最终显示文本，`width` 为它的显示列数。
- 空输入返回空行数组；宽度 ≤ 0 按 1 处理；超宽单字素独占一行，允许溢出。
- 对齐填充到目标宽度；不截断溢出。末行／硬换行行不拉伸两端对齐。
- `words` 仅返回含字母或数字的段；`segments(..., Word)` 保留全部段。

字素切分依赖 `kawaz/grapheme@0.10.4`；显示宽度依赖`moonbit-community/unicodewidth@0.2.1`。宽度按字素的等宽显示列相加，不是字体整形后的像素宽度。

宽度依赖内部数据版本为 Unicode 16（详见限制文档），断行／词句／字素规范为 Unicode 17。核心无文件、网络、时钟访问。

## 示例

```sh
moon run examples/wrap_terminal
moon run examples/cjk_mixed
moon run examples/justify_paragraph
moon run examples/word_boundaries
```

每条命令也可加 `--target native` 或 `--target js`。

## 本地验证

```sh
moon info
moon fmt --check
moon check --target native --deny-warn
moon test --target native --deny-warn
moon check --target wasm-gc --deny-warn
moon test --target wasm-gc --deny-warn
moon check --target js --deny-warn
moon test --target js --deny-warn
```

官方用例已嵌入测试，运行时不需要下载或读取文件。数据生成和幂等性验证见[DATA_PIPELINE](docs/DATA_PIPELINE.md)。API 以各包 `pkg.generated.mbti` 为准。

## 范围

0.1.0 实现初验 M0–M4。最优换行、连字符词典、BiDi 重排、归一化集成属于后续阶段；当前不暴露假实现。不是渲染器、正则库或 NLP 分词器。默认 UAX 规则没有语言词典 tailoring；详见 [LIMITATIONS](docs/LIMITATIONS.md)。

原始代码 Apache-2.0；Unicode 数据使用 Unicode License v3。参见 [THIRD_PARTY](THIRD_PARTY.md)、[REFERENCES](REFERENCES.md) 和 [AI_USAGE](AI_USAGE.md)。
