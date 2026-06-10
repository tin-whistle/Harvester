import Foundation

/// Shared body payload for both `StartTimeEntryRequest` (POST) and
/// `UpdateTimeEntryRequest` (PATCH). The Harvest API accepts the same field set
/// for create and update, so the two requests differ only in HTTP method and
/// endpoint path.
struct TimeEntryPayload: Encodable {
    let hours: Double
    let notes: String?
    let projectId: Int
    let spentDate: String
    let taskId: Int
}
