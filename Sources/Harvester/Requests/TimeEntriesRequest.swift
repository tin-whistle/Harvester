import Foundation

struct TimeEntriesRequest: NetworkRequest {
    typealias Response = TimeEntriesResponse
  
    let endpoint: NetworkEndpoint = .pathFromBaseURL("/time_entries")
    let method: HTTPMethod = .get([])
//        .get([URLQueryItem(name: "per_page", value: "20")])
}

public struct TimeEntriesResponse: Decodable {
    let timeEntries: [HarvestTimeEntry]
    
    enum CodingKeys: String, CodingKey {
        case timeEntries = "time_entries"
    }
}
