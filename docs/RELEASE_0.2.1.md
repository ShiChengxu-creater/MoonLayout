# 0.2.1 工具链兼容性补丁

2026-11-14（Asia/Shanghai）。本版本将 11 月 12 日的兼容性维护打包为新的补丁版本，保留原有布局 API 和 Unicode 数据。使用 `moon 0.1.20261104`、`moonc v0.10.20+65efd5b93`；旧的 9 月编译器不支持本版本的 `#derive` 和 `Int32` 写法。

发布前已通过三后端 check/build/test（native 66、wasm-gc/JS 各 63 个测试块），21,794 个 Unicode 官方用例、24 次示例、生成幂等性、ICU/Python 差分及独立 ZIP 消费者。完整脚本为 `python scripts/verify.py`，工具链与依赖背景见 [TOOLCHAIN_COMPATIBILITY.md](TOOLCHAIN_COMPATIBILITY.md)。

注册表发布后，用全新消费者验证确切版本：

```sh
python scripts/verify_published.py --version 0.2.1 --out docs/evidence/registry-0.2.1.json
```

该脚本拒绝本地 workspace 替代，从 Mooncakes 安装指定版本，在 native、wasm-gc、JS 分别运行严格 check/build/test，验证布局、UTF-8 原文、分段、最优换行、连字符、BiDi 和 NFKC 公开 API。
