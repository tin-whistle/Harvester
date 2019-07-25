import UIKit

protocol AuthorizedNetworkClient: NetworkClient {
    var accountID: Int? { get set }
    
    var isAuthorized: Bool { get }
    
    func authorize(completion: @escaping (_ result: Result<Bool, HarvestError>) -> Void)

    func deauthorize() throws
}
