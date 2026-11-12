# 工具链兼容性维护（2026-11-12）

本次使用 [MoonBit 官方下载渠道](https://www.moonbitlang.com/download/) 当日提供的当前正式工具链，隔离安装后执行源码与实际 ZIP 包的验证。原始版本输出为：

```text
moon 0.1.20261104 (940aa18 2026-11-04)
moonc v0.10.20+65efd5b93 (2026-11-05)
moonrun 0.1.20261104 (940aa18 2026-11-04)
Feature flags enabled: rr_moon_mod,rr_moon_pkg
```

官方 Windows ZIP 的 SHA-256 为 `bdff9a3b2d7c61a3adae2fe09221d3de63effc6cab28bfa0cbeb94fb0d529d79`，与官方校验文件一致。本地环境为 Windows x64 / MSVC、Python 3.13.9、Node.js 24.22.1。CI 另在 Linux 使用 Node.js 22 运行。

## 问题与修复

原始主分支 `b8202938c74c2d32c4168cfeee56a46bf262e659` 在当前工具链执行 `moon check --target native --deny-warn` 时，旧 `} derive(...)` 语法触发弃用诊断，严格检查失败。

使用当前 `moon fmt` 迁移至前置 `#derive(...)`，并同步可选参数声明和 `Int32` 的规范写法；`Int32` 对应原有 32 位 `Int`。Unicode 表生成器也改为生成当前语法，避免重新生成时带回弃用写法。`moon info` 已同步全部接口，公开函数和布局行为约定保留。

依赖解析成功，保留已验证的版本：`kawaz/grapheme@0.10.4`、`unicodewidth@0.2.1`、`bidi@0.5.0`、`normalization@0.5.0`、`moonbitlang/x@0.4.44`；间接依赖为 `moonbit-community/ucd@0.5.0`。数据版本限制继续见 [LIMITATIONS.md](LIMITATIONS.md)。

## 验证结果

| 目标后端 | check / build / test（均含 `--deny-warn`） | 测试块 | 示例 | ZIP 包公开 API 测试 |
| --- | --- | --- | --- | --- |
| native | 通过 | 66 / 66 | 8 / 8 | 1 / 1 |
| wasm-gc | 通过 | 63 / 63 | 8 / 8 | 1 / 1 |
| js | 通过 | 63 / 63 | 8 / 8 | 1 / 1 |

全部 21,794 个 Unicode 官方用例通过；UCD 和连字符数据 SHA-256、代码生成幂等性、公开接口同步及格式检查通过。24 次示例的显示结果跨后端一致。差分验证通过 15 次 ICU 断行比较、30 次 Python 归一化比较和 ASCII 换行对照。独立消费模块使用 `moon package` 生成的真实 ZIP，覆盖核心布局、分段、最优换行、连字符、BiDi 和 NFKC。

机器可读的步骤、结果及日志哈希见 [maintenance/2026-11-12.json](maintenance/2026-11-12.json)。日志保存在 `.agent-workplace/verification/`；维护会话另归档一份。测试块数量不代表覆盖率。

## 复验与持续维护

安装官方当前工具链后，在仓库根目录运行：

```sh
moon version --all
moon update
moon info
moon fmt --check
python scripts/verify.py
```

`verify.py` 现在显式执行三后端 build，并记录实际工具链和依赖树。native 需要 C 编译器；JS 需要 Node.js；完整脚本需要 Python 3 和 ICU，Linux 安装 `libicu-dev`，Windows 使用系统 ICU。Linux CI 在每次推送、PR、手动触发及每周一北京时间 10:23 安装官方当前正式版本，运行同一脚本并保存日志附件，包括失败运行的版本日志。

本次结果针对维护后的仓库源码与本地打包产物；模块版本仍为 0.2.0。旧工具链不在本次验证范围内；后续工具链以 CI 实际记录的版本和结果为准。现有 Mooncakes 0.2.0 的发布记录与本次源码维护分别保留，本次未发布新版本。
