import UIKit

public protocol AuthorizedNetworkClient: NetworkClient {
    var accountID: Int? { get set }
    
    var isAuthorized: Bool { get }
    
    func authorizeWithViewController(_ viewController: UIViewController, completion: @escaping (_ result: Result<Bool, HarvestError>) -> Void)

    func deauthorize() throws
    
    func handleAuthorizationRedirectURL(_ url: URL)
}

//public struct AuthorizedNetworkClientStub: AuthorizedNetworkClient {
//    public init() {
//        // No-op
//    }
//    
//    public var accountID: Int?
//    
//    public var isAuthorized: Bool {
//        return false
//    }
//    
//    public func authorizeWithViewController(_ viewController: UIViewController, redirectURL: URL, completion: @escaping (_ result: Result<Bool, HarvestError>) -> Void) {
//        completion(.success(false))
//    }
//    
//    public func deauthorize() throws {
//        // No-op
//    }
//    
//    public func handleAuthorizationRedirectURL(_ url: URL) {
//        // No-op
//    }
//    
//    public var baseURL: URL {
//        return URL(string: "https://www.example.com")!
//    }
//    
//    public func send<T>(_ request: T, completion: @escaping (Result<T.Response, Error>) -> Void) where T : NetworkRequest {
//        completion(.failure(HarvestError.unauthorized))
//    }
//    
//    
//}
