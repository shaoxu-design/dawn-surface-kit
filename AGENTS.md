# AGENTS.md

本文件是给在这个仓库里工作的智能体（Agent）使用的项目级约束。

## 项目背景

- 这是一个名为 `DawnSurfaceKit` 的 Swift 包。
- 对外产物只有两套：`DawnSurfaceKit`（纯 SwiftUI）与 `DawnSurfaceTCA`（TCA 接入）。
- 包面向 iOS 17+ SwiftUI 项目；macOS 14+ 只用于命令行测试编译。
- `DawnSurfaceKit` 只依赖 Foundation 和 SwiftUI；`DawnSurfaceTCA` 可以依赖 The Composable Architecture。
- 任一 target 都不应引入业务项目依赖、本地化系统或宿主 App 设计系统。

## 工作规则

- 修改前先读真实文件，不要凭记忆推断公开接口。
- 改动保持外科手术式，只碰完成请求必须修改的文件。
- 优先选择能解决问题的最小实现或最短文档。
- 不要顺手重构相邻代码、格式化无关文件，或者删除无关死代码。
- README 示例里提到的接口，必须能在 `Sources/` 中找到对应实现。
- 公共 API 变更必须同步更新 README 和测试。
- 验证结果要如实汇报，包括已知失败。

## 验证要求

- 修改源码后至少运行 `swift test`。
- 修改包配置后运行 `swift package describe`。
- 测试优先覆盖纯逻辑、公开 API 编译、TCA adapter 编译映射、日期顺序、年份范围、时间提交语义。
- 不编写 SwiftUI 布局、动画帧或渲染快照测试。

## 范围控制

- 不要引入 iThings 的 `AppColors`、`Typography`、`SettingCard`、`.localized(fallback:)`、`AppLanguage` 或业务模型。
- 不要把货币、分类、渠道、单位、贵金属、计费模式等业务 picker 放进 SDK。
- 首版不承诺 macOS、tvOS、watchOS UI 使用体验。
- 如果存在多种理解，先说明取舍，再开始改。
- 每一行改动都应该能对应到用户请求。
