import Foundation

public struct HarvestCompany: Decodable {
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
    
    enum CodingKeys: String, CodingKey {
        case baseURL = "base_uri"
        case fullDomain = "full_domain"
        case name = "name"
        case isActive = "is_active"
        case weekStartDay = "week_start_day"
        case wantsTimestampTimers = "wants_timestamp_timers"
        case timeFormat = "time_format"
        case planType = "plan_type"
        case clock = "clock"
        case decimalSymbol = "decimal_symbol"
        case thousandsSeparator = "thousands_separator"
        case colorScheme = "color_scheme"
        case expenseFeature = "expense_feature"
        case invoiceFeature = "invoice_feature"
        case estimateFeature = "estimate_feature"
        case approvalFeature = "approval_feature"
    }
    
    public enum WeekStartDay: String, Codable {
        case saturday = "Saturday"
        case sunday = "Sunday"
        case monday = "Monday"
    }
    
    public enum TimeFormat: String, Codable {
        case decimal = "decimal"
        case hoursMinutes = "hoursMinutes"
    }
    
    public enum Clock: String, Codable {
        case twelveHour = "12h"
        case twentyFourHour = "24h"
    }
}
