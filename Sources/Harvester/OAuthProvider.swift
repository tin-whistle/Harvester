import UIKit

public protocol OAuthProvider {
    
    var isAuthorized: Bool { get }
        
    func authorizeWithViewController(_ viewController: UIViewController, completion: @escaping (_ result: Result<Bool, HarvestError>) -> Void)

    func deauthorize() throws
    
    func handleAuthorizationRedirectURL(_ url: URL)
    
    func sendAuthorizedRequest(_ url: URL, method: HTTPMethod, headers: [String: String], body: Data?, completion: @escaping (Result<Data, Error>) -> Void)
}

public struct OAuthProviderStub: OAuthProvider {
    public var isAuthorized: Bool

    public init(isAuthorized: Bool) {
        self.isAuthorized = isAuthorized
    }
    
    public func authorizeWithViewController(_ viewController: UIViewController, completion: @escaping (Result<Bool, HarvestError>) -> Void) {
        completion(.success(isAuthorized))
    }
    
    public func deauthorize() throws {
        // No-op
    }
    
    public func handleAuthorizationRedirectURL(_ url: URL) {
        // No-op
    }
    
    public func sendAuthorizedRequest(_ url: URL, method: HTTPMethod, headers: [String : String], body: Data?, completion: @escaping (Result<Data, Error>) -> Void) {
        if isAuthorized {
            completion(.success(Data()))
        } else {
            completion(.failure(HarvestError.unauthorized))
        }
    }
}
