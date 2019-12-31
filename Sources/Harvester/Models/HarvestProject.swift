import Foundation

public struct HarvestProject: Decodable {
    public let id: Int
    public let name: String
    public let code: String

    public init(id: Int,
                name: String,
                code: String) {
        self.id = id
        self.name = name
        self.code = code
    }
}
