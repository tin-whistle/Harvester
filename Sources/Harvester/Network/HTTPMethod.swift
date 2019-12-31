import Foundation

public enum HTTPMethod {
    case delete
    case get(_ queryItems: [URLQueryItem])
    case patch(_ body: Encodable?)
    case post(_ body: Encodable?)

    var rawValue: String {
        switch self {
        case .delete:
            return "DELETE"
        case .get:
            return "GET"
        case .patch:
            return "PATCH"
        case .post:
            return "POST"
        }
    }
}
