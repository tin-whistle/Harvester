import Foundation

protocol NetworkRequest {
    associatedtype Response: Decodable

    var endpoint: NetworkEndpoint { get }
    var method: HTTPMethod { get }
}
