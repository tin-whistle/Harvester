import Foundation

struct DeleteTimeEntryRequest: NetworkRequest {
    typealias Response = HarvestTimeEntry

    var endpoint: NetworkEndpoint {
        .pathFromBaseURL("/time_entries/\(timeEntry.id)")
    }
    let method: HTTPMethod = .delete
    let timeEntry: HarvestTimeEntry
}

