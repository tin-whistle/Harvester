import Foundation

extension DateFormatter {
    /// ISO-8601 date-only formatter ("yyyy-MM-dd") in the user's current time zone.
    /// Used everywhere the Harvest API takes or returns a `spent_date`.
    public nonisolated(unsafe) static let yyyyMMdd: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
