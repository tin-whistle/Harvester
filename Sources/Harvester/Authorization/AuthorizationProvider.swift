import UIKit

public protocol AuthorizationProvider {

    var accessToken: String? { get }

    func authorize(completion: @escaping (_ result: Result<Bool, AuthorizationProviderError>) -> Void)

    func deauthorize() throws
}
