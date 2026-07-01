@testable import DawnSurfaceKit
import Foundation
import Testing

struct DawnDateComponentFormatterTests {
    @Test("date component order follows locale format")
    func dateComponentOrderFollowsLocaleFormat() {
        #expect(DawnDateComponentOrder.components(for: Locale(identifier: "en")) == [.month, .day, .year])
        #expect(DawnDateComponentOrder.components(for: Locale(identifier: "en_GB")) == [.day, .month, .year])
        #expect(DawnDateComponentOrder.components(for: Locale(identifier: "zh-Hans")) == [.year, .month, .day])
        #expect(DawnDateComponentOrder.components(for: Locale(identifier: "ja")) == [.year, .month, .day])
    }

    @Test("date component formatter localizes year month and day labels")
    func dateComponentFormatterLocalizesLabels() {
        let englishFormatter = DawnDateComponentFormatter(locale: Locale(identifier: "en"), yearStyle: .full)
        #expect(englishFormatter.string(for: .year, value: 2026) == "2026")
        #expect(englishFormatter.string(for: .month, value: 7) == "Jul")
        #expect(englishFormatter.string(for: .day, value: 1) == "1")

        let simplifiedFormatter = DawnDateComponentFormatter(locale: Locale(identifier: "zh-Hans"), yearStyle: .full)
        #expect(simplifiedFormatter.string(for: .year, value: 2026) == "2026年")
        #expect(simplifiedFormatter.string(for: .month, value: 7) == "7月")
    }

    @Test("year range clamps distant past to 1900")
    func yearRangeClampsDistantPastToEarliestDisplayYear() throws {
        let calendar = Calendar(identifier: .gregorian)
        let selectedDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 7, day: 1)))
        let endDate = try #require(calendar.date(from: DateComponents(year: 2040, month: 12, day: 31)))

        let range = DawnDatePickerYearRange.years(
            in: Date.distantPast ... endDate,
            selectedDate: selectedDate,
            calendar: calendar
        )

        #expect(range.lowerBound == 1900)
        #expect(range.upperBound == 2040)
    }

    @Test("year range keeps selected year when it is earlier than 1900")
    func yearRangeKeepsSelectedYearWhenEarlierThanEarliestDisplayYear() throws {
        let calendar = Calendar(identifier: .gregorian)
        let selectedDate = try #require(calendar.date(from: DateComponents(year: 1888, month: 7, day: 1)))
        let endDate = try #require(calendar.date(from: DateComponents(year: 2040, month: 12, day: 31)))

        let range = DawnDatePickerYearRange.years(
            in: Date.distantPast ... endDate,
            selectedDate: selectedDate,
            calendar: calendar
        )

        #expect(range.lowerBound == 1888)
        #expect(range.upperBound == 2040)
    }
}
