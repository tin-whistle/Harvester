import Foundation

struct CompanyRequest: NetworkRequest {
    typealias Response = HarvestCompany
    
    let endpoint: NetworkEndpoint = .pathFromBaseURL("/company")
    let method: HTTPMethod = .get([])
}
