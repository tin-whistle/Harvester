import Foundation

protocol NetworkClient {
    var baseURL: URL { get }

    func send<T: NetworkRequest>(_ request: T) async throws -> T.Response
}

extension NetworkClient {
    func urlFrom<T: NetworkRequest>(_ request: T) -> URL {
        switch request.endpoint {
        case .fullURL(let fullURL):
            return fullURL
        case .pathFromBaseURL(let path):
            return baseURL.appendingPathComponent(path)
        }
    }
}
