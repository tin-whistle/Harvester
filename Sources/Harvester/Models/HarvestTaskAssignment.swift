import Foundation

public struct HarvestTaskAssignment: Decodable {
    public let id: Int
    public let task: HarvestTask
    public let isActive: Bool
    public let billable: Bool
    public let created: String
    public let updated: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case task = "task"
        case isActive = "is_active"
        case billable = "billable"
        case created = "created_at"
        case updated = "updated_at"
    }
}
