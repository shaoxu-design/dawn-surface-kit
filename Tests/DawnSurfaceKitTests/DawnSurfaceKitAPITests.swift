@testable import DawnSurfaceKit
import Foundation
import SwiftUI
import Testing
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@Suite(.serialized)
struct DawnSurfaceKitAPITests {
    enum SampleOption: String, CaseIterable, Hashable {
        case first
        case second
    }

    @Test("option picker accepts string options and a custom footer")
    @MainActor
    func optionPickerAcceptsStringOptionsAndCustomFooter() {
        let surface = DawnOptionPickerSurface(
            title: "分类",
            options: ["工作", "生活"],
            displayText: { $0 },
            isSelected: { $0 == "工作" },
            onTap: { _ in },
            multiSelect: true,
            managementAction: { }
        ) {
            Text("最多选择 3 个")
        }

        _ = surface
    }

    @Test("option picker exposes EmptyView convenience init")
    @MainActor
    func optionPickerExposesEmptyViewConvenienceInit() {
        let surface = DawnOptionPickerSurface(
            title: "模式",
            options: SampleOption.allCases,
            displayText: { $0.rawValue },
            isSelected: { $0 == .first },
            onTap: { _ in }
        )

        _ = surface
    }

    @Test("grid selection and action menu APIs compile")
    @MainActor
    func gridSelectionAndActionMenuAPIsCompile() {
        let grid = DawnGridSelectionSurface(
            title: "排序",
            options: SampleOption.allCases,
            displayText: { $0.rawValue },
            isSelected: { $0 == .first },
            onTap: { _ in },
            tip: "选择一个排序方式"
        )

        let menu = DawnActionMenuSurface(
            title: "更多",
            actions: [
                .init(title: "编辑", handler: { }),
                .init(title: "删除", tintColor: .red, handler: { }),
            ]
        )

        _ = grid
        _ = menu
    }

    @Test("theme and texts environment modifiers compile")
    @MainActor
    func themeAndTextsEnvironmentModifiersCompile() {
        let theme = DawnSurfaceTheme(
            accentColor: .blue,
            rowFont: .body,
            cardCornerRadius: 18
        )
        let texts = DawnSurfaceTexts(cancel: "Close", done: "Apply", reset: "Clear", manage: "Edit")

        let host = Text("Host")
            .dawnSurfaceTheme(theme)
            .dawnSurfaceTexts(texts)

        _ = host
    }

    @Test("default theme resolves iThings-compatible light and dark colors")
    func defaultThemeResolvesIThingsCompatibleLightAndDarkColors() throws {
        let theme = DawnSurfaceTheme.default

        #expect(try Self.hex(theme.backgroundColor, in: .light) == "#F2F2F7")
        #expect(try Self.hex(theme.backgroundColor, in: .dark) == "#1C1C1E")
        #expect(try Self.hex(theme.cardBackgroundColor, in: .light) == "#FFFFFF")
        #expect(try Self.hex(theme.cardBackgroundColor, in: .dark) == "#2C2C2E")
        #expect(try Self.hex(theme.primaryTextColor, in: .light) == "#000000")
        #expect(try Self.hex(theme.primaryTextColor, in: .dark) == "#FFFFFF")
        #expect(try Self.hex(theme.accentColor, in: .light) == "#10B981")
        #expect(try Self.hex(theme.accentColor, in: .dark) == "#34D399")
        #expect(try Self.hex(theme.destructiveColor, in: .light) == "#F43F5E")
        #expect(try Self.hex(theme.destructiveColor, in: .dark) == "#FB7185")
        #expect(try Self.hex(theme.dividerColor, in: .light) == "#D1D1D6")
        #expect(try Self.hex(theme.dividerColor, in: .dark) == "#3A3A3C")
    }

    @Test("date and time sheet APIs compile")
    @MainActor
    func dateAndTimeSheetAPIsCompile() throws {
        let calendar = Calendar(identifier: .gregorian)
        let selectedDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 7, day: 1, hour: 9, minute: 30)))
        let endDate = try #require(calendar.date(from: DateComponents(year: 2040, month: 12, day: 31)))

        let dateSurface = DawnDatePickerSurface(
            selectedDate: .constant(selectedDate),
            dateRange: Date.distantPast ... endDate,
            title: "日期",
            locale: Locale(identifier: "zh-Hans")
        )
        let dateTimeSurface = DawnDateTimePickerSurface(
            selectedDate: .constant(selectedDate),
            dateRange: Date.distantPast ... endDate,
            title: "提醒时间",
            locale: Locale(identifier: "zh-Hans")
        )
        let timeSurface = DawnTimePickerSurface(
            time: DawnTimeComponents(hour: 9, minute: 30),
            title: "每日提醒"
        ) { _ in }

        _ = dateSurface
        _ = dateTimeSurface
        _ = timeSurface
    }

    @Test("time picker draft saves hour and minute atomically")
    func timePickerDraftSavesHourAndMinuteAtomically() {
        var draft = DawnTimePickerDraft(initialTime: DawnTimeComponents(hour: 8, minute: 15))

        draft.pendingHour = 21
        draft.pendingMinute = 45

        #expect(draft.save() == DawnTimeComponents(hour: 21, minute: 45))
    }

    @Test("management surface APIs compile")
    @MainActor
    func managementSurfaceAPIsCompile() {
        struct Item: Identifiable, Equatable {
            let id: String
            let title: String
        }

        let surface = DawnManagementSurface(
            title: "渠道管理",
            presentationMode: .sheet,
            items: [
                Item(id: "apple", title: "Apple Store"),
                Item(id: "jd", title: "京东"),
            ],
            addButtonTitle: "创建渠道",
            onDismiss: { },
            onAddTapped: { },
            onMove: { _, _ in }
        ) { item in
            Text(item.title)
        } emptyContent: {
            Text("暂无渠道")
        } principalContent: {
            EmptyView()
        } loadingContent: {
            ProgressView()
        }

        _ = surface
    }

    @Test("editable management configuration exposes default and custom copy")
    func editableManagementConfigurationExposesDefaultAndCustomCopy() {
        let defaultConfiguration = DawnManagementEditConfiguration()

        #expect(defaultConfiguration.createTitle == "创建")
        #expect(defaultConfiguration.editTitle == "编辑")
        #expect(defaultConfiguration.inputPlaceholder == "请输入名称")
        #expect(defaultConfiguration.createButtonTitle == "创建")
        #expect(defaultConfiguration.editButtonTitle == "确定")
        #expect(defaultConfiguration.menuEditTitle == "编辑")
        #expect(defaultConfiguration.menuDeleteTitle == "删除")

        let customConfiguration = DawnManagementEditConfiguration(
            createTitle: "创建平台",
            editTitle: "编辑平台",
            inputPlaceholder: "例如：visionOS",
            createButtonTitle: "保存",
            editButtonTitle: "更新",
            menuEditTitle: "重命名",
            menuDeleteTitle: "移除"
        )

        #expect(customConfiguration.createTitle == "创建平台")
        #expect(customConfiguration.editTitle == "编辑平台")
        #expect(customConfiguration.inputPlaceholder == "例如：visionOS")
        #expect(customConfiguration.createButtonTitle == "保存")
        #expect(customConfiguration.editButtonTitle == "更新")
        #expect(customConfiguration.menuEditTitle == "重命名")
        #expect(customConfiguration.menuDeleteTitle == "移除")
    }

    @Test("editable management surface APIs compile with default and custom rows")
    @MainActor
    func editableManagementSurfaceAPIsCompileWithDefaultAndCustomRows() {
        struct Item: Identifiable, Equatable {
            let id: String
            let title: String
        }

        let items = [
            Item(id: "ios", title: "iOS"),
            Item(id: "android", title: "Android"),
        ]
        let configuration = DawnManagementEditConfiguration(
            createTitle: "新增平台",
            editTitle: "编辑平台",
            inputPlaceholder: "例如：visionOS",
            createButtonTitle: "保存",
            editButtonTitle: "保存",
            menuEditTitle: "编辑",
            menuDeleteTitle: "删除"
        )

        let defaultRowSurface = DawnEditableManagementSurface(
            title: "平台管理",
            presentationMode: .embedded,
            items: items,
            itemTitle: \.title,
            addButtonTitle: "新增平台",
            editConfiguration: configuration,
            onDismiss: { },
            onCreate: { _ in },
            onEdit: { _, _ in },
            onDelete: { _ in },
            onMove: { _, _ in }
        ) {
            Text("暂无平台")
        } principalContent: {
            EmptyView()
        } loadingContent: {
            ProgressView()
        }

        let customRowSurface = DawnEditableManagementSurface(
            title: "平台管理",
            items: items,
            itemTitle: \.title,
            editText: { "编辑：\($0.title)" },
            addButtonTitle: "新增平台",
            editConfiguration: configuration,
            onCreate: { _ in },
            onEdit: { _, _ in },
            onDelete: { _ in }
        ) { item, showMenu in
            Button(action: showMenu) {
                Text(item.title)
            }
        } emptyContent: {
            Text("暂无平台")
        } principalContent: {
            EmptyView()
        } loadingContent: {
            ProgressView()
        }

        _ = defaultRowSurface
        _ = customRowSurface
    }
}

private enum DawnSurfaceTestColorScheme {
    case light
    case dark
}

private extension DawnSurfaceKitAPITests {
    static func hex(_ color: Color, in scheme: DawnSurfaceTestColorScheme) throws -> String {
        #if os(iOS)
        let traits = UITraitCollection(userInterfaceStyle: scheme == .dark ? .dark : .light)
        let resolved = UIColor(color).resolvedColor(with: traits)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        #elseif os(macOS)
        let appearanceName: NSAppearance.Name = scheme == .dark ? .darkAqua : .aqua
        let appearance = try #require(NSAppearance(named: appearanceName))
        var srgb: NSColor?
        appearance.performAsCurrentDrawingAppearance {
            srgb = NSColor(color).usingColorSpace(.sRGB)
        }
        let resolved = try #require(srgb)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        #endif

        #if os(iOS)
        let extracted = resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #expect(extracted)
        #elseif os(macOS)
        resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif

        return String(
            format: "#%02X%02X%02X",
            Int((red * 255).rounded()),
            Int((green * 255).rounded()),
            Int((blue * 255).rounded())
        )
    }
}
