import Foundation

struct UserRequest: NetworkRequest {
    typealias Response = HarvestUser
    
    var endpoint: NetworkEndpoint {
        .pathFromBaseURL("/users/\(userID)")
    }
    let method: HTTPMethod = .get([])
    let userID: String
}
