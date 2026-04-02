import Foundation

public protocol AuthorizationProvider: Sendable {

    var accessToken: String? { get }

    @MainActor func authorize() async throws -> Bool

    func deauthorize() throws
}
