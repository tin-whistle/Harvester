import Foundation

public struct HarvestClient: Decodable, Equatable, Hashable {
    public let id: Int
    public let name: String

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public init(id: Int,
                name: String) {
        self.id = id
        self.name = name
    }
}
