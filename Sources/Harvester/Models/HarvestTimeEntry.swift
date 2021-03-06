import Foundation

public struct HarvestTimeEntry: Decodable, Identifiable {
    public let id: Int
    public let spentDate: String
    public let client: HarvestClient
    public let project: HarvestProject
    public let task: HarvestTask
//    public let taskAssignment: HarvestTaskAssignment
    public let hours: Double
    public let notes: String?
//    public let timerStartedAt: String
    public let startedTime: String?
    public let endedTime: String?
    public let isRunning: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case spentDate = "spent_date"
        case client = "client"
        case project = "project"
        case task = "task"
//        case taskAssignment = "task_assignment"
        case hours = "hours"
        case notes = "notes"
//        case timerStartedAt = "timer_started_at"
        case startedTime = "started_time"
        case endedTime = "ended_time"
        case isRunning = "is_running"
    }

    public init(id: Int,
                spentDate: String,
                client: HarvestClient,
                project: HarvestProject,
                task: HarvestTask,
                hours: Double,
                notes: String?,
                startedTime: String?,
                endedTime: String?,
                isRunning: Bool) {
        self.id = id
        self.spentDate = spentDate
        self.client = client
        self.project = project
        self.task = task
        self.hours = hours
        self.notes = notes
        self.startedTime = startedTime
        self.endedTime = endedTime
        self.isRunning = isRunning
    }
}
