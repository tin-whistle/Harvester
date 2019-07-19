import Foundation

public enum HTTPMethod {
    case delete
    case get(_ queryItems: [URLQueryItem])
    case patch(_ body: Encodable?)
    case post(_ body: Encodable?)
}
