struct RestartTimeEntryRequest: NetworkRequest {
    typealias Response = HarvestTimeEntry

    var endpoint: NetworkEndpoint {
        .pathFromBaseURL("/time_entries/\(timeEntry.id)/restart")
    }
    let method: HTTPMethod = .patch(nil)
    let timeEntry: HarvestTimeEntry
}

