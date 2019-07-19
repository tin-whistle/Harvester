import Foundation

struct AccountsRequest: NetworkRequest {
    typealias Response = AccountsResponse
    
    var endpoint: NetworkEndpoint {
        return .fullURL(URL(string: "https://id.getharvest.com/api/v2/accounts")!)
    }
    let method: HTTPMethod = .get([])
}

struct AccountsResponse: Decodable {
    let accounts: [HarvestAccount]
}
