import Foundation

struct StopTimeEntryRequest: NetworkRequest {
    typealias Response = HarvestTimeEntry

    var endpoint: NetworkEndpoint {
        .pathFromBaseURL("/time_entries/\(timeEntry.id)/stop")
    }
    let method: HTTPMethod = .patch(nil)
    let timeEntry: HarvestTimeEntry
}

