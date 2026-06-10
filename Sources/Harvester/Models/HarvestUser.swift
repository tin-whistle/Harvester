import Foundation

public struct HarvestUser: Codable, Sendable {
    public let id: Int
    public let firstName: String
    public let lastName: String
    public let avatarUrl: URL
}
