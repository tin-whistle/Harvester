import Foundation

struct UserProjectAssignmentsRequest: NetworkRequest {
    typealias Response = UserProjectAssignmentsResponse
  
    var endpoint: NetworkEndpoint {
        return .pathFromBaseURL("/users/\(userID)/project_assignments")
    }
    let method: HTTPMethod = .get([])
    let userID: String
}

struct UserProjectAssignmentsResponse: Decodable {
    let projectAssignments: [HarvestProjectAssignment]
    
    enum CodingKeys: String, CodingKey {
        case projectAssignments = "project_assignments"
    }
}
