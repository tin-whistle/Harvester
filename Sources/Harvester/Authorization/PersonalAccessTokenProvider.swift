import Foundation

public final class PersonalAccessTokenProvider: @unchecked Sendable {

    /// A closure that requests a personal access token from the user.
    /// The closure should return the token string, or throw to cancel.
    public var tokenRequestHandler: (@MainActor @Sendable () async throws -> String)?

    private var localStorage: LocalStorage

    public init(localStorage: LocalStorage = DefaultLocalStorage()) {
        self.localStorage = localStorage
    }
}

extension PersonalAccessTokenProvider: AuthorizationProvider {
    public var accessToken: String? {
        get {
            localStorage.accessToken
        }
        set {
            localStorage.accessToken = newValue
        }
    }

    @MainActor
    public func authorize() async throws -> Bool {
        guard let tokenRequestHandler else {
            throw AuthorizationProviderError.failed
        }

        let token = try await tokenRequestHandler()
        accessToken = token
        return true
    }

    public func deauthorize() throws {
        accessToken = nil
    }
}
