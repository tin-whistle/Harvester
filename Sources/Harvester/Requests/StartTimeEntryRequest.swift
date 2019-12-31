import Foundation

struct StartTimeEntryRequest: NetworkRequest, Encodable {
    typealias Response = HarvestTimeEntry

    var endpoint: NetworkEndpoint {
        .pathFromBaseURL("/time_entries")
    }
    var method: HTTPMethod {
        .post(self)
    }

    let hours: Double
    let notes: String?
    let projectId: Int
    let spentDate: String
    let taskId: Int

    init(hours: Double, notes: String?, projectId: Int, spentDate: Date, taskId: Int) {
        self.hours = hours
        self.notes = notes
        self.projectId = projectId
        self.spentDate = DateFormatter.yyyyMMdd.string(from: spentDate)
        self.taskId = taskId
    }

    enum CodingKeys: String, CodingKey {
        case hours = "hours"
        case notes = "notes"
        case projectId = "project_id"
        case spentDate = "spent_date"
        case taskId = "task_id"
    }
}

extension DateFormatter {
    static let yyyyMMdd: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
