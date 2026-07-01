# DawnSheetKit

DawnSheetKit 是一个轻量级 SwiftUI Sheet 组件库，提供单选、多选、网格选择、操作菜单、日期选择、时间选择等可复用弹层内容。组件只依赖 SwiftUI，不依赖业务项目、TCA、本地化系统或应用内设计系统。

## 环境要求

- iOS 17+
- Swift 6.0+

> 包内声明 macOS 14+ 仅用于本机 `swift test` 编译与逻辑测试；首版公开使用场景以 iOS 17+ 为准。

## 安装方式

在 Xcode 中添加依赖：

1. 打开 **File > Add Package Dependencies**（文件 > 添加包依赖）。
2. 输入仓库地址。
3. 将 `DawnSheetKit` 产物添加到你的 App 目标。

也可以在 `Package.swift` 中添加：

```swift
.package(url: "https://gitee.com/shaoxu0904/dawn-sheet-kit.git", from: "0.1.0")
```

然后在目标里依赖这个产物：

```swift
.product(name: "DawnSheetKit", package: "dawn-sheet-kit")
```

## 基础用法

### 单选

```swift
import DawnSheetKit
import SwiftUI

struct CategoryPickerHost: View {
    @State private var selectedCategory = "生活"

    var body: some View {
        DawnOptionPickerSheet(
            title: "选择分类",
            options: ["工作", "生活", "学习"],
            displayText: { $0 },
            isSelected: { $0 == selectedCategory },
            onTap: { selectedCategory = $0 }
        )
    }
}
```

### 多选

```swift
DawnOptionPickerSheet(
    title: "显示筛选",
    options: ["资产", "维护", "心愿"],
    displayText: { $0 },
    isSelected: { selectedItems.contains($0) },
    onTap: { item in
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    },
    multiSelect: true,
    resetAction: { selectedItems.removeAll() }
)
```

多选模式会保留选择过程，用户点击右上角“完成”后关闭；`resetAction` 和 `managementAction` 会作为轻量次操作出现。

### 网格选择

```swift
DawnGridSelectionSheet(
    title: "排序方式",
    options: SortMode.allCases,
    displayText: { $0.title },
    isSelected: { $0 == sortMode },
    onTap: { sortMode = $0 },
    tip: "排序方式会影响当前列表展示。"
)
```

### 操作菜单

```swift
DawnActionMenuSheet(
    title: "更多操作",
    actions: [
        .init(title: "编辑", handler: edit),
        .init(title: "删除", tintColor: .red, handler: delete),
    ]
)
```

如果外部需要自己控制 dismiss 时机，可以把单个 action 的 `dismissesSheet` 设为 `false`。

### 日期和时间

```swift
DawnDatePickerSheet(
    selectedDate: $selectedDate,
    dateRange: Date.distantPast ... Date.distantFuture,
    title: "选择日期",
    locale: Locale(identifier: "zh-Hans")
)

DawnTimePickerSheet(
    time: DawnTimeComponents(hour: 9, minute: 30),
    title: "每日提醒"
) { newTime in
    reminderHour = newTime.hour
    reminderMinute = newTime.minute
}
```

## 主题与文案

通过环境统一配置外观和默认文案：

```swift
ContentView()
    .dawnSheetTheme(DawnSheetTheme(
        accentColor: .green,
        rowFont: .body,
        cardCornerRadius: 18
    ))
    .dawnSheetTexts(DawnSheetTexts(
        cancel: "关闭",
        done: "应用",
        reset: "清空",
        manage: "管理"
    ))
```

`DawnSheetTheme` 可以控制背景色、卡片色、文本色、强调色、分割线、字体、间距、圆角、图标名称和禁用透明度。组件自身不读取任何宿主 App 的设计系统。

## 开发命令

常用命令：

```sh
swift package describe
swift test
```

## 许可证

MIT License
