import Foundation

public struct HarvestProjectAssignment: Decodable {
    public let id: Int
    public let isActive: Bool
    public let isProjectManager: Bool
    public let useDefaultRates: Bool
    public let created: String
    public let updated: String
    public let project: HarvestProject
    public let client: HarvestClient
    public let taskAssignments: [HarvestTaskAssignment]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case isActive = "is_active"
        case isProjectManager = "is_project_manager"
        case useDefaultRates = "use_default_rates"
        case created = "created_at"
        case updated = "updated_at"
        case project = "project"
        case client = "client"
        case taskAssignments = "task_assignments"
    }
}
