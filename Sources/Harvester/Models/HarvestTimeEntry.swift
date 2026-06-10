import Foundation

public struct HarvestTimeEntry: Decodable, Equatable, Identifiable, Sendable {
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
    public private(set) var isDirty: Bool = false

    // `isDirty` is local-only state, never carried on the wire. Declaring CodingKeys
    // explicitly excludes it from the synthesized decoder. The camelCase raw values
    // pair with `JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase`.
    enum CodingKeys: String, CodingKey {
        case id, spentDate, client, project, task, hours, notes
        case startedTime, endedTime, isRunning
    }

    public init(
        id: Int,
        spentDate: String,
        client: HarvestClient,
        project: HarvestProject,
        task: HarvestTask,
        hours: Double,
        notes: String?,
        startedTime: String?,
        endedTime: String?,
        isRunning: Bool
    ) {
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
        isDirty = true
    }

    public func stopped() -> HarvestTimeEntry {
        HarvestTimeEntry(
            id: id,
            spentDate: spentDate,
            client: client,
            project: project,
            task: task,
            hours: hours,
            notes: notes,
            startedTime: startedTime,
            endedTime: endedTime,
            isRunning: false)
    }
}
