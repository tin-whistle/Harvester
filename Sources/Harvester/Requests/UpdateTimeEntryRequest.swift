import Foundation

struct UpdateTimeEntryRequest: NetworkRequest, Encodable {
    typealias Response = HarvestTimeEntry

    var endpoint: NetworkEndpoint
    var method: HTTPMethod {
        .patch(self)
    }

    let hours: Double
    let notes: String?
    let projectId: Int
    let spentDate: String
    let taskId: Int

    init(timeEntry: HarvestTimeEntry) {
        endpoint = .pathFromBaseURL("/time_entries/\(timeEntry.id)")
        self.hours = timeEntry.hours
        self.notes = timeEntry.notes
        self.projectId = timeEntry.project.id
        self.spentDate = timeEntry.spentDate
        self.taskId = timeEntry.task.id
    }

    enum CodingKeys: String, CodingKey {
        case hours = "hours"
        case notes = "notes"
        case projectId = "project_id"
        case spentDate = "spent_date"
        case taskId = "task_id"
    }
}
