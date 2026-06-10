import Foundation

public struct HarvestCompany: Decodable, Sendable {
    public let baseURL: URL
    public let fullDomain: URL
    public let name: String
    public let isActive: Bool
    public let weekStartDay: WeekStartDay
    public let wantsTimestampTimers: Bool
    public let timeFormat: TimeFormat
    public let planType: String
    public let clock: Clock
    public let decimalSymbol: String
    public let thousandsSeparator: String
    public let colorScheme: String
    public let expenseFeature: Bool
    public let invoiceFeature: Bool
    public let estimateFeature: Bool
    public let approvalFeature: Bool

    // Raw values are post-`.convertFromSnakeCase` camelCase. Only `baseURL`
    // needs an explicit override (JSON `base_uri` → `baseUri`, which differs
    // from the URL-acronym property name).
    enum CodingKeys: String, CodingKey {
        case baseURL = "baseUri"
        case fullDomain, name, isActive, weekStartDay, wantsTimestampTimers
        case timeFormat, planType, clock, decimalSymbol, thousandsSeparator
        case colorScheme, expenseFeature, invoiceFeature, estimateFeature, approvalFeature
    }

    public enum WeekStartDay: String, Codable, Sendable {
        case saturday = "Saturday"
        case sunday = "Sunday"
        case monday = "Monday"
    }

    public enum TimeFormat: String, Codable, Sendable {
        case decimal = "decimal"
        case hoursMinutes = "hoursMinutes"
    }

    public enum Clock: String, Codable, Sendable {
        case twelveHour = "12h"
        case twentyFourHour = "24h"
    }
}
