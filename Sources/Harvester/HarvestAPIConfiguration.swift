public struct HarvestAPIConfiguration {
    let appName: String
    let contactEmail: String
    let oauthProvider: OAuthProvider
    
    public init(appName: String, contactEmail: String, oauthProvider: OAuthProvider) {
        self.appName = appName
        self.contactEmail = contactEmail
        self.oauthProvider = oauthProvider
    }
}
