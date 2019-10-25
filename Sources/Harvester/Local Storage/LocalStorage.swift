/// The available local storage properties.
public protocol LocalStorage {
    var accountId: Int? { get set }
}

/// The default implementation of `LocalStorage`. Stores values in  `UserDefaults`.
public struct DefaultLocalStorage: LocalStorage {
    @Persistent("Harvester.accountId") public var accountId: Int?

    public init() {}
}
