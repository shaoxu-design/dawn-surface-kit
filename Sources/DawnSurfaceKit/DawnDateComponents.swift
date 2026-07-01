import Foundation

public enum DawnDateComponent: Hashable, Sendable {
    case year
    case month
    case day
}

public enum DawnDateComponentOrder {
    public static func components(for locale: Locale) -> [DawnDateComponent] {
        guard let pattern = DateFormatter.dateFormat(fromTemplate: "yMd", options: 0, locale: locale) else {
            return Self.defaultOrder
        }

        var result: [DawnDateComponent] = []
        var isInsideQuote = false

        for character in pattern {
            if character == "'" {
                isInsideQuote.toggle()
                continue
            }
            guard !isInsideQuote, let component = Self.component(for: character), !result.contains(component) else {
                continue
            }
            result.append(component)
        }

        for component in Self.defaultOrder where !result.contains(component) {
            result.append(component)
        }
        return result
    }

    private static let defaultOrder: [DawnDateComponent] = [.year, .month, .day]

    private static func component(for character: Character) -> DawnDateComponent? {
        switch character {
        case "y", "Y", "u", "U", "r":
            return .year
        case "M", "L":
            return .month
        case "d":
            return .day
        default:
            return nil
        }
    }
}

public enum DawnDatePickerYearDisplayStyle: Sendable {
    case full
    case short
}

public struct DawnDateComponentFormatter: Sendable {
    public let locale: Locale
    public let yearStyle: DawnDatePickerYearDisplayStyle

    public init(locale: Locale, yearStyle: DawnDatePickerYearDisplayStyle) {
        self.locale = locale
        self.yearStyle = yearStyle
    }

    public func string(for component: DawnDateComponent, value: Int) -> String {
        switch component {
        case .year:
            return self.string(from: self.date(year: value, month: 1, day: 1), template: self.yearTemplate)
        case .month:
            return self.string(from: self.date(year: 2026, month: value, day: 1), template: "MMM")
        case .day:
            return self.string(from: self.date(year: 2026, month: 1, day: value), template: "d")
        }
    }

    private var yearTemplate: String {
        switch self.yearStyle {
        case .full:
            return "yyyy"
        case .short:
            return "yy"
        }
    }

    private func string(from date: Date, template: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = self.locale
        formatter.calendar = self.calendar
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter.string(from: date)
    }

    private func date(year: Int, month: Int, day: Int) -> Date {
        self.calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = self.locale
        return calendar
    }
}

enum DawnDatePickerYearRange {
    static let earliestDisplayYear = 1900

    static func years(
        in dateRange: ClosedRange<Date>,
        selectedDate: Date,
        calendar: Calendar
    ) -> ClosedRange<Int> {
        let startYear = calendar.component(.year, from: dateRange.lowerBound)
        let endYear = calendar.component(.year, from: dateRange.upperBound)
        let selectedYear = calendar.component(.year, from: selectedDate)
        let clampedStart = max(Self.earliestDisplayYear, startYear)
        let effectiveStart = min(clampedStart, selectedYear, endYear)
        return effectiveStart ... max(effectiveStart, endYear)
    }
}

public struct DawnTimeComponents: Equatable, Sendable {
    public var hour: Int
    public var minute: Int

    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
}

struct DawnTimePickerDraft: Equatable {
    var pendingHour: Int
    var pendingMinute: Int

    init(initialTime: DawnTimeComponents) {
        self.pendingHour = initialTime.hour
        self.pendingMinute = initialTime.minute
    }

    func save() -> DawnTimeComponents {
        DawnTimeComponents(hour: self.pendingHour, minute: self.pendingMinute)
    }
}
