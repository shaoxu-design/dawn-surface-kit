@testable import DawnSheetKit
import Foundation
import SwiftUI
import Testing

@Suite(.serialized)
struct DawnSheetKitAPITests {
    enum SampleOption: String, CaseIterable, Hashable {
        case first
        case second
    }

    @Test("option picker accepts string options and a custom footer")
    @MainActor
    func optionPickerAcceptsStringOptionsAndCustomFooter() {
        let sheet = DawnOptionPickerSheet(
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

        _ = sheet
    }

    @Test("option picker exposes EmptyView convenience init")
    @MainActor
    func optionPickerExposesEmptyViewConvenienceInit() {
        let sheet = DawnOptionPickerSheet(
            title: "模式",
            options: SampleOption.allCases,
            displayText: { $0.rawValue },
            isSelected: { $0 == .first },
            onTap: { _ in }
        )

        _ = sheet
    }

    @Test("grid selection and action menu APIs compile")
    @MainActor
    func gridSelectionAndActionMenuAPIsCompile() {
        let grid = DawnGridSelectionSheet(
            title: "排序",
            options: SampleOption.allCases,
            displayText: { $0.rawValue },
            isSelected: { $0 == .first },
            onTap: { _ in },
            tip: "选择一个排序方式"
        )

        let menu = DawnActionMenuSheet(
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
        let theme = DawnSheetTheme(
            accentColor: .blue,
            rowFont: .body,
            cardCornerRadius: 18
        )
        let texts = DawnSheetTexts(cancel: "Close", done: "Apply", reset: "Clear", manage: "Edit")

        let host = Text("Host")
            .dawnSheetTheme(theme)
            .dawnSheetTexts(texts)

        _ = host
    }

    @Test("date and time sheet APIs compile")
    @MainActor
    func dateAndTimeSheetAPIsCompile() throws {
        let calendar = Calendar(identifier: .gregorian)
        let selectedDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 7, day: 1, hour: 9, minute: 30)))
        let endDate = try #require(calendar.date(from: DateComponents(year: 2040, month: 12, day: 31)))

        let dateSheet = DawnDatePickerSheet(
            selectedDate: .constant(selectedDate),
            dateRange: Date.distantPast ... endDate,
            title: "日期",
            locale: Locale(identifier: "zh-Hans")
        )
        let dateTimeSheet = DawnDateTimePickerSheet(
            selectedDate: .constant(selectedDate),
            dateRange: Date.distantPast ... endDate,
            title: "提醒时间",
            locale: Locale(identifier: "zh-Hans")
        )
        let timeSheet = DawnTimePickerSheet(
            time: DawnTimeComponents(hour: 9, minute: 30),
            title: "每日提醒"
        ) { _ in }

        _ = dateSheet
        _ = dateTimeSheet
        _ = timeSheet
    }

    @Test("time picker draft saves hour and minute atomically")
    func timePickerDraftSavesHourAndMinuteAtomically() {
        var draft = DawnTimePickerDraft(initialTime: DawnTimeComponents(hour: 8, minute: 15))

        draft.pendingHour = 21
        draft.pendingMinute = 45

        #expect(draft.save() == DawnTimeComponents(hour: 21, minute: 45))
    }
}
