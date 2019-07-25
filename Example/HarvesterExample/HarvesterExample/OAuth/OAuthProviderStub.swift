import Harvester
import UIKit

struct OAuthProviderStub: OAuthProvider {
    var isAuthorized: Bool

    init(isAuthorized: Bool) {
        self.isAuthorized = isAuthorized
    }
    
    func authorize(completion: @escaping (Result<Bool, Error>) -> Void) {
        completion(.success(isAuthorized))
    }
    
    func deauthorize() throws {
        // No-op
    }
    
    func sendAuthorizedRequest(_ url: URL, method: HTTPMethod, headers: [String : String], body: Data?, completion: @escaping (Result<Data, Error>) -> Void) {
        if isAuthorized {
            completion(.success(Data()))
        } else {
            completion(.failure(HarvestError.unauthorized))
        }
    }
}
