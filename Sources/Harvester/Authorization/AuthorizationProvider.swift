import Foundation

public protocol AuthorizationProvider {

    var accessToken: String? { get }

    @MainActor func authorize() async throws -> Bool

    func deauthorize() throws
}
