// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "ShiChengxu/moonlayout"

version = "0.1.0"

readme = "README.mbt.md"

repository = ""

license = "Apache-2.0"

keywords = [ "unicode", "linebreak", "text", "layout" ]

preferred_target = "wasm-gc"

description = "Unicode 17 paragraph layout, line breaking and word/sentence segmentation"

import {
  "kawaz/grapheme@0.10.4",
  "moonbit-community/unicodewidth@0.2.1",
  "moonbitlang/x@0.4.44",
}
