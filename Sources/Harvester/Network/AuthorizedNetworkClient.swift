import Foundation

protocol AuthorizedNetworkClient: NetworkClient {
    var accountId: Int? { get set }

    var isAuthorized: Bool { get }

    func authorize() async throws -> Bool

    func deauthorize() throws
}
