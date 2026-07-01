@testable import DawnSurfaceKit
import Foundation
import SwiftUI
import Testing

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
}
