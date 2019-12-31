/// The available local storage properties.
public protocol LocalStorage {
    var accessToken: String? { get set }
    var accountId: Int? { get set }
    var wantsTimestampTimers: Bool? { get set }
}

/// The default implementation of `LocalStorage`. Stores values in  `UserDefaults`.
public struct DefaultLocalStorage: LocalStorage {
    @Persistent("Harvester.accessToken") public var accessToken: String?
    @Persistent("Harvester.accountId") public var accountId: Int?
    @Persistent("Harvester.wantsTimestampTimers") public var wantsTimestampTimers: Bool?

    public init() {}
}
