public struct HarvestAPIConfiguration {
    let appName: String
    let authorizationProvider: AuthorizationProvider
    let contactEmail: String

    public init(appName: String, authorizationProvider: AuthorizationProvider, contactEmail: String) {
        self.appName = appName
        self.authorizationProvider = authorizationProvider
        self.contactEmail = contactEmail
    }
}
