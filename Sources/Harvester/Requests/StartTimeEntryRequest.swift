import Foundation

struct StartTimeEntryRequest: NetworkRequest {
    typealias Response = HarvestTimeEntry

    var endpoint: NetworkEndpoint {
        .pathFromBaseURL("/time_entries")
    }
    var method: HTTPMethod {
        .post(payload)
    }

    let payload: TimeEntryPayload

    init(hours: Double, notes: String?, projectId: Int, spentDate: Date, taskId: Int) {
        payload = TimeEntryPayload(
            hours: hours,
            notes: notes,
            projectId: projectId,
            spentDate: DateFormatter.yyyyMMdd.string(from: spentDate),
            taskId: taskId)
    }
}
