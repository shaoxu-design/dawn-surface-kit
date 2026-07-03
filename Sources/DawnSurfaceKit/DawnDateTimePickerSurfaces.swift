import SwiftUI

public struct DawnDatePickerSurface: View {
    @Binding private var selectedDate: Date
    private let dateRange: ClosedRange<Date>
    private let title: String
    private let locale: Locale?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var environmentLocale
    @Environment(\.dawnSurfaceTheme) private var theme
    @Environment(\.dawnSurfaceTexts) private var texts

    public init(
        selectedDate: Binding<Date>,
        dateRange: ClosedRange<Date>,
        title: String,
        locale: Locale? = nil
    ) {
        self._selectedDate = selectedDate
        self.dateRange = dateRange
        self.title = title
        self.locale = locale
    }

    public var body: some View {
        NavigationStack {
            DawnDateWheelPicker(
                selectedDate: self.$selectedDate,
                dateRange: self.dateRange,
                locale: self.resolvedLocale,
                yearStyle: .full
            )
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(self.theme.backgroundColor.ignoresSafeArea())
            .navigationTitle(self.title)
            .dawnInlineNavigationTitle()
            .toolbar {
                self.toolbarItems
            }
        }
        .presentationDetents([.medium])
    }

    private var resolvedLocale: Locale {
        self.locale ?? self.environmentLocale
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(self.texts.cancel) {
                self.dismiss()
            }
            .foregroundStyle(self.theme.secondaryTextColor)
        }

        ToolbarItem(placement: .confirmationAction) {
            Button(self.texts.done) {
                self.dismiss()
            }
            .foregroundStyle(self.theme.accentColor)
        }
    }
}

public struct DawnDateTimePickerSurface: View {
    @Binding private var selectedDate: Date
    private let dateRange: ClosedRange<Date>
    private let title: String
    private let locale: Locale?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var environmentLocale
    @Environment(\.dawnSurfaceTheme) private var theme
    @Environment(\.dawnSurfaceTexts) private var texts

    public init(
        selectedDate: Binding<Date>,
        dateRange: ClosedRange<Date>,
        title: String,
        locale: Locale? = nil
    ) {
        self._selectedDate = selectedDate
        self.dateRange = dateRange
        self.title = title
        self.locale = locale
    }

    public var body: some View {
        NavigationStack {
            DawnDateTimeWheelPicker(
                selectedDate: self.$selectedDate,
                dateRange: self.dateRange,
                locale: self.resolvedLocale
            )
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(self.theme.backgroundColor.ignoresSafeArea())
            .navigationTitle(self.title)
            .dawnInlineNavigationTitle()
            .toolbar {
                self.toolbarItems
            }
        }
        .presentationDetents([.medium])
    }

    private var resolvedLocale: Locale {
        self.locale ?? self.environmentLocale
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(self.texts.cancel) {
                self.dismiss()
            }
            .foregroundStyle(self.theme.secondaryTextColor)
        }

        ToolbarItem(placement: .confirmationAction) {
            Button(self.texts.done) {
                self.dismiss()
            }
            .foregroundStyle(self.theme.accentColor)
        }
    }
}

public struct DawnTimePickerSurface: View {
    private let title: String
    private let locale: Locale?
    private let onSave: (DawnTimeComponents) -> Void

    @State private var draft: DawnTimePickerDraft
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var environmentLocale
    @Environment(\.dawnSurfaceTheme) private var theme
    @Environment(\.dawnSurfaceTexts) private var texts

    public init(
        time: DawnTimeComponents,
        title: String,
        locale: Locale? = nil,
        onSave: @escaping (DawnTimeComponents) -> Void
    ) {
        self.title = title
        self.locale = locale
        self.onSave = onSave
        self._draft = State(initialValue: DawnTimePickerDraft(initialTime: time))
    }

    public var body: some View {
        NavigationStack {
            DawnTimeWheelPicker(
                hour: Binding(
                    get: { self.draft.pendingHour },
                    set: { self.draft.pendingHour = $0 }
                ),
                minute: Binding(
                    get: { self.draft.pendingMinute },
                    set: { self.draft.pendingMinute = $0 }
                ),
                locale: self.resolvedLocale
            )
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(self.theme.backgroundColor.ignoresSafeArea())
            .navigationTitle(self.title)
            .dawnInlineNavigationTitle()
            .toolbar {
                self.toolbarItems
            }
        }
        .presentationDetents([.medium])
    }

    private var resolvedLocale: Locale {
        self.locale ?? self.environmentLocale
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(self.texts.cancel) {
                self.dismiss()
            }
            .foregroundStyle(self.theme.secondaryTextColor)
        }

        ToolbarItem(placement: .confirmationAction) {
            Button(self.texts.done) {
                self.onSave(self.draft.save())
                self.dismiss()
            }
            .foregroundStyle(self.theme.accentColor)
        }
    }
}

private struct DawnDateTimeWheelPicker: View {
    @Binding var selectedDate: Date
    let dateRange: ClosedRange<Date>
    let locale: Locale

    private var calendar: Calendar {
        Calendar.current
    }

    private var hour: Int {
        self.calendar.component(.hour, from: self.selectedDate)
    }

    private var minute: Int {
        self.calendar.component(.minute, from: self.selectedDate)
    }

    var body: some View {
        HStack(spacing: 0) {
            DawnDateWheelPicker(
                selectedDate: self.$selectedDate,
                dateRange: self.dateRange,
                locale: self.locale,
                yearStyle: .short
            )

            Picker("", selection: Binding(
                get: { self.hour },
                set: { self.updateDate(hour: $0) }
            )) {
                ForEach(0 ... 23, id: \.self) { hour in
                    Text(Self.formatHour(hour, locale: self.locale))
                        .tag(hour)
                }
            }
            .dawnWheelPickerStyle()
            .frame(maxWidth: .infinity)

            Picker("", selection: Binding(
                get: { self.minute },
                set: { self.updateDate(minute: $0) }
            )) {
                ForEach(0 ... 59, id: \.self) { minute in
                    Text(Self.formatMinute(minute, locale: self.locale))
                        .tag(minute)
                }
            }
            .dawnWheelPickerStyle()
            .frame(maxWidth: .infinity)
        }
    }

    private func updateDate(hour: Int? = nil, minute: Int? = nil) {
        var components = self.calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self.selectedDate)
        if let hour { components.hour = hour }
        if let minute { components.minute = minute }

        if let newDate = self.calendar.date(from: components) {
            self.selectedDate = Self.clamped(newDate, to: self.dateRange)
        }
    }

    static func formatHour(_ hour: Int, locale: Locale) -> String {
        let formatted = String(format: "%02d", hour)
        return locale.identifier.lowercased().hasPrefix("zh") ? "\(formatted)时" : "\(formatted)h"
    }

    static func formatMinute(_ minute: Int, locale: Locale) -> String {
        let formatted = String(format: "%02d", minute)
        return locale.identifier.lowercased().hasPrefix("zh") ? "\(formatted)分" : "\(formatted)m"
    }

    static func clamped(_ date: Date, to range: ClosedRange<Date>) -> Date {
        if range.contains(date) {
            return date
        }
        return date < range.lowerBound ? range.lowerBound : range.upperBound
    }
}

private struct DawnDateWheelPicker: View {
    @Binding var selectedDate: Date
    let dateRange: ClosedRange<Date>
    let locale: Locale
    let yearStyle: DawnDatePickerYearDisplayStyle

    private var calendar: Calendar {
        Calendar.current
    }

    private var year: Int {
        self.calendar.component(.year, from: self.selectedDate)
    }

    private var month: Int {
        self.calendar.component(.month, from: self.selectedDate)
    }

    private var day: Int {
        self.calendar.component(.day, from: self.selectedDate)
    }

    private var yearRange: ClosedRange<Int> {
        DawnDatePickerYearRange.years(in: self.dateRange, selectedDate: self.selectedDate, calendar: self.calendar)
    }

    private var dayRange: ClosedRange<Int> {
        let daysInMonth = self.calendar.range(of: .day, in: .month, for: self.selectedDate)?.count ?? 31
        return 1 ... daysInMonth
    }

    private var componentOrder: [DawnDateComponent] {
        DawnDateComponentOrder.components(for: self.locale)
    }

    private var componentFormatter: DawnDateComponentFormatter {
        DawnDateComponentFormatter(locale: self.locale, yearStyle: self.yearStyle)
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(self.componentOrder, id: \.self) { component in
                self.picker(for: component)
            }
        }
    }

    @ViewBuilder
    private func picker(for component: DawnDateComponent) -> some View {
        switch component {
        case .year:
            Picker("", selection: Binding(
                get: { self.year },
                set: { self.updateDate(year: $0) }
            )) {
                ForEach(Array(self.yearRange), id: \.self) { year in
                    Text(self.componentFormatter.string(for: .year, value: year))
                        .tag(year)
                }
            }
            .dawnWheelPickerStyle()
            .frame(maxWidth: .infinity)

        case .month:
            Picker("", selection: Binding(
                get: { self.month },
                set: { self.updateDate(month: $0) }
            )) {
                ForEach(1 ... 12, id: \.self) { month in
                    Text(self.componentFormatter.string(for: .month, value: month))
                        .tag(month)
                }
            }
            .dawnWheelPickerStyle()
            .frame(maxWidth: .infinity)

        case .day:
            Picker("", selection: Binding(
                get: { self.day },
                set: { self.updateDate(day: $0) }
            )) {
                ForEach(Array(self.dayRange), id: \.self) { day in
                    Text(self.componentFormatter.string(for: .day, value: day))
                        .tag(day)
                }
            }
            .dawnWheelPickerStyle()
            .frame(maxWidth: .infinity)
        }
    }

    private func updateDate(year: Int? = nil, month: Int? = nil, day: Int? = nil) {
        var components = self.calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self.selectedDate)
        if let year { components.year = year }
        if let month { components.month = month }
        if let day { components.day = day }

        if let newDate = self.calendar.date(from: components) {
            self.selectedDate = DawnDateTimeWheelPicker.clamped(newDate, to: self.dateRange)
        }
    }
}

private struct DawnTimeWheelPicker: View {
    @Binding var hour: Int
    @Binding var minute: Int
    let locale: Locale

    var body: some View {
        HStack(spacing: 0) {
            Picker("", selection: self.$hour) {
                ForEach(0 ... 23, id: \.self) { hour in
                    Text(DawnDateTimeWheelPicker.formatHour(hour, locale: self.locale))
                        .tag(hour)
                }
            }
            .dawnWheelPickerStyle()
            .frame(maxWidth: .infinity)

            Picker("", selection: self.$minute) {
                ForEach(0 ... 59, id: \.self) { minute in
                    Text(DawnDateTimeWheelPicker.formatMinute(minute, locale: self.locale))
                        .tag(minute)
                }
            }
            .dawnWheelPickerStyle()
            .frame(maxWidth: .infinity)
        }
    }
}
