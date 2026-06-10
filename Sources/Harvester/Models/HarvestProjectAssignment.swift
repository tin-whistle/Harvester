import Foundation

public struct HarvestProjectAssignment: Decodable, Sendable {
    public let id: Int
    public let isActive: Bool
    public let isProjectManager: Bool
    public let useDefaultRates: Bool
    public let created: String
    public let updated: String
    public let project: HarvestProject
    public let client: HarvestClient
    public let taskAssignments: [HarvestTaskAssignment]

    public init(
        id: Int,
        isActive: Bool,
        isProjectManager: Bool,
        useDefaultRates: Bool,
        created: String,
        updated: String,
        project: HarvestProject,
        client: HarvestClient,
        taskAssignments: [HarvestTaskAssignment]
    ) {
        self.id = id
        self.isActive = isActive
        self.isProjectManager = isProjectManager
        self.useDefaultRates = useDefaultRates
        self.created = created
        self.updated = updated
        self.project = project
        self.client = client
        self.taskAssignments = taskAssignments
    }

    // Raw values are post-`.convertFromSnakeCase` camelCase. Cases without an
    // explicit raw value use the property name; `created`/`updated` need an
    // explicit override because the JSON key (`created_at`) converts to a
    // different camelCase form than the property name.
    enum CodingKeys: String, CodingKey {
        case id, isActive, isProjectManager, useDefaultRates
        case created = "createdAt"
        case updated = "updatedAt"
        case project, client, taskAssignments
    }
}
