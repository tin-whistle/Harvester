import UIKit

public protocol OAuthProvider {
    
    var isAuthorized: Bool { get }
        
    func authorize(completion: @escaping (_ result: Result<Bool, Error>) -> Void)

    func deauthorize() throws
        
    func sendAuthorizedRequest(_ url: URL, method: HTTPMethod, headers: [String: String], body: Data?, completion: @escaping (Result<Data, Error>) -> Void)
}
