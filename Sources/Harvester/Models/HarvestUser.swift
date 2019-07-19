import Foundation

public struct HarvestUser: Codable {
    public let id: Int
    public let firstName: String
    public let lastName: String
    public let avatarURL: URL
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarURL = "avatar_url"
    }
}
