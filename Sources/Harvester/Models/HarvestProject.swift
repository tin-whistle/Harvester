import Foundation

public struct HarvestProject: Decodable, Sendable {
    public let id: Int
    public let name: String
    public let code: String

    public init(
        id: Int,
        name: String,
        code: String = ""
    ) {
        self.id = id
        self.name = name
        self.code = code
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, code
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        code = try container.decodeIfPresent(String.self, forKey: .code) ?? ""
    }
}
