# DawnSurfaceKit

DawnSurfaceKit 是一个轻量级 SwiftUI surface 组件库，提供单选、多选、网格选择、操作菜单、日期选择、时间选择和可排序管理页骨架。

包内提供两套入口：

- `DawnSurfaceKit`：纯 SwiftUI 组件，只依赖 Foundation 和 SwiftUI。
- `DawnSurfaceTCA`：TCA 接入层，依赖 `DawnSurfaceKit` 和 The Composable Architecture。

组件不依赖业务项目、本地化系统或宿主 App 设计系统。

## 环境要求

- iOS 17+
- Swift 6.0+

> 包内声明 macOS 14+ 仅用于本机 `swift test` 编译与逻辑测试；首版公开使用场景以 iOS 17+ 为准。

## 安装方式

在 Xcode 中添加依赖：

1. 打开 **File > Add Package Dependencies**（文件 > 添加包依赖）。
2. 输入仓库地址。
3. 将需要的产物添加到你的 App 目标：非 TCA 项目选 `DawnSurfaceKit`，TCA 项目可额外选 `DawnSurfaceTCA`。

也可以在 `Package.swift` 中添加：

```swift
.package(url: "https://gitee.com/shaoxu0904/dawn-sheet-kit.git", from: "0.2.0")
```

然后在目标里依赖这个产物：

```swift
.product(name: "DawnSurfaceKit", package: "dawn-sheet-kit")
.product(name: "DawnSurfaceTCA", package: "dawn-sheet-kit")
```

## 基础用法

### 单选

```swift
import DawnSurfaceKit
import SwiftUI

struct CategoryPickerHost: View {
    @State private var selectedCategory = "生活"

    var body: some View {
        DawnOptionPickerSurface(
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
DawnOptionPickerSurface(
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
DawnGridSelectionSurface(
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
DawnActionMenuSurface(
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
DawnDatePickerSurface(
    selectedDate: $selectedDate,
    dateRange: Date.distantPast ... Date.distantFuture,
    title: "选择日期",
    locale: Locale(identifier: "zh-Hans")
)

DawnTimePickerSurface(
    time: DawnTimeComponents(hour: 9, minute: 30),
    title: "每日提醒"
) { newTime in
    reminderHour = newTime.hour
    reminderMinute = newTime.minute
}
```

### 管理页骨架

```swift
DawnManagementSurface(
    title: "渠道管理",
    presentationMode: .sheet,
    items: channels,
    addButtonTitle: "创建渠道",
    onDismiss: dismiss,
    onAddTapped: addChannel,
    onMove: moveChannel
) { channel in
    DawnManagementRow(
        title: channel.name,
        onMenuTapped: { showMenu(channel.id) }
    )
} emptyContent: {
    Text("暂无渠道")
} principalContent: {
    EmptyView()
} loadingContent: {
    ProgressView()
}
```

### TCA 接入

```swift
import DawnSurfaceTCA

DawnManagementStoreSurface(
    store: store,
    title: { $0.managementTitle },
    items: { $0.editableItems },
    isLoading: { $0.isLoading },
    addButtonTitle: { $0.addActionTitle },
    onDismiss: .dismissButtonTapped,
    onAddTapped: .addButtonTapped,
    onMove: { source, destination in .moveItem(source, destination) }
) { item, store in
    DawnManagementRow(
        title: item.title,
        onMenuTapped: { store.send(.itemActionMenuShown(item.id)) }
    )
} emptyContent: { _ in
    Text("暂无内容")
} principalContent: { _ in
    EmptyView()
} loadingContent: { _ in
    ProgressView()
}
```

`DawnSurfaceTCA` 只负责 Store 到 SwiftUI surface 的映射，不提供业务 reducer；校验、持久化、删除确认、会员限制和 HUD 等语义仍由宿主项目持有。

## 主题与文案

通过环境统一配置外观和默认文案：

```swift
ContentView()
    .dawnSurfaceTheme(DawnSurfaceTheme(
        accentColor: .green,
        rowFont: .body,
        cardCornerRadius: 18
    ))
    .dawnSurfaceTexts(DawnSurfaceTexts(
        cancel: "关闭",
        done: "应用",
        reset: "清空",
        manage: "管理"
    ))
```

`DawnSurfaceTheme` 可以控制背景色、卡片色、文本色、强调色、分割线、字体、间距、圆角、图标名称和禁用透明度。组件自身不读取任何宿主 App 的设计系统。

## 开发命令

常用命令：

```sh
swift package describe
swift test
```

## 许可证

MIT License
