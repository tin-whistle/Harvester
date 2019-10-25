import CoreGraphics
import Foundation

@propertyWrapper
/// A property wrapper for `UserDefault`-backed properties.
public struct Persistent<Value: Persistable> {

    /// The key used to reference the value in persistent storage.
    private let key: String

    /// The property used to get and set the value.
    public var wrappedValue: Value? {
        get {
            return UserDefaults.standard.object(forKey: key) as? Value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    /// Initializes a persistent property wrapper with a default value and a key.
    /// - Parameter wrappedValue: The default value.
    /// - Parameter key: The persistent storage reference key.
    public init(wrappedValue: Value?, _ key: String) {
        self.key = key
        if let defaultValue = wrappedValue {
            UserDefaults.standard.register(defaults: [key: defaultValue])
        }
    }

    /// Initializes a persistent property wrapper with a key.
    /// - Parameter key: The persistent storage reference key.
    public init(_ key: String) {
        self.key = key
    }
}

/// An empty protocol which marks a type as suitable to be used with the `Persistent` property wrapper.
public protocol Persistable {}
extension Array: Persistable where Element: Persistable {}
extension Bool: Persistable {}
extension CGFloat: Persistable {}
extension Data: Persistable {}
extension Date: Persistable {}
extension Dictionary: Persistable where Value: Persistable {}
extension Double: Persistable {}
extension Float: Persistable {}
extension Int: Persistable {}
extension String: Persistable {}
extension Set: Persistable where Element: Persistable {}
