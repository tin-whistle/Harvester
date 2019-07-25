import Foundation

protocol NetworkClient {
    var baseURL: URL { get }
    
    func send<T: NetworkRequest, U>(_ request: T, completion: @escaping (Result<U, HarvestError>) -> Void) where U == T.Response
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
