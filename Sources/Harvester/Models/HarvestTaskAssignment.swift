import Foundation

public struct HarvestTaskAssignment: Decodable, Sendable {
    public let id: Int
    public let task: HarvestTask
    public let isActive: Bool
    public let billable: Bool
    public let created: String
    public let updated: String

    public init(
        id: Int,
        task: HarvestTask,
        isActive: Bool,
        billable: Bool,
        created: String,
        updated: String
    ) {
        self.id = id
        self.task = task
        self.isActive = isActive
        self.billable = billable
        self.created = created
        self.updated = updated
    }

    // Raw values are post-`.convertFromSnakeCase` camelCase.
    enum CodingKeys: String, CodingKey {
        case id, task, isActive, billable
        case created = "createdAt"
        case updated = "updatedAt"
    }
}
