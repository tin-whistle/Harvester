import Foundation

protocol NetworkClient {
    var baseURL: URL { get }
    
    func send<T: NetworkRequest>(_ request: T) async throws -> T.Response
}

extension NetworkClient {
    func urlFrom<T: NetworkRequest>(_ request: T) -> URL {
        switch request.endpoint {
        case let .fullURL(fullURL):
            return fullURL
        case let .pathFromBaseURL(path):
            return baseURL.appendingPathComponent(path)
        }
    }
}
