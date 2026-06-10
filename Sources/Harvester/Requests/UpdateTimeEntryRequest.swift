import Foundation

struct UpdateTimeEntryRequest: NetworkRequest {
    typealias Response = HarvestTimeEntry

    var endpoint: NetworkEndpoint
    var method: HTTPMethod {
        .patch(payload)
    }

    let payload: TimeEntryPayload

    init(timeEntry: HarvestTimeEntry) {
        endpoint = .pathFromBaseURL("/time_entries/\(timeEntry.id)")
        payload = TimeEntryPayload(
            hours: timeEntry.hours,
            notes: timeEntry.notes,
            projectId: timeEntry.project.id,
            spentDate: timeEntry.spentDate,
            taskId: timeEntry.task.id)
    }
}
