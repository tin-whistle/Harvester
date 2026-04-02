import Foundation
import Harvester

protocol Harvester {
    var currentAccountId: Int? { get set }
    var isAuthorized: Bool { get }
    var wantsTimestampTimers: Bool? { get }
    func authorize() async throws -> Bool
    func deauthorize() throws
    func getAccounts() async throws -> [HarvestAccount]
    func getMe() async throws -> HarvestUser
    func getProjectAssignments() async throws -> [HarvestProjectAssignment]
    func getTimeEntries() async throws -> [HarvestTimeEntry]
    func getCompany() async throws -> HarvestCompany
    func startTimeEntryWith(
        hours: Double, notes: String?, projectId: Int, spentDate: Date, taskId: Int
    ) async throws -> HarvestTimeEntry
    func stopTimeEntry(_ timeEntry: HarvestTimeEntry) async throws -> HarvestTimeEntry
    func restartTimeEntry(_ timeEntry: HarvestTimeEntry) async throws -> HarvestTimeEntry
    func deleteTimeEntry(_ timeEntry: HarvestTimeEntry) async throws
    func updateTimeEntry(_ timeEntry: HarvestTimeEntry) async throws -> HarvestTimeEntry
}

extension HarvestAPI: Harvester {

}

class PreviewHarvester: Harvester {
    var currentAccountId: Int?

    var isAuthorized = true

    var wantsTimestampTimers: Bool? = true

    func authorize() async throws -> Bool {
        isAuthorized = true
        return true
    }

    func deauthorize() throws {
        isAuthorized = false
    }

    func getAccounts() async throws -> [HarvestAccount] {
        throw HarvestError.unauthorized
    }

    func getMe() async throws -> HarvestUser {
        throw HarvestError.unauthorized
    }

    func getProjectAssignments() async throws -> [HarvestProjectAssignment] {
        throw HarvestError.unauthorized
    }

    func getTimeEntries() async throws -> [HarvestTimeEntry] {
        return [
            HarvestTimeEntry(
                id: 0,
                spentDate: "1984-01-02",
                client: HarvestClient(
                    id: 0,
                    name: "Client A"),
                project: HarvestProject(
                    id: 0,
                    name: "Project A",
                    code: "12345"),
                task: HarvestTask(
                    id: 0,
                    name: "Task A"),
                hours: 1.5,
                notes: "Notes",
                startedTime: nil,
                endedTime: nil,
                isRunning: true),
            HarvestTimeEntry(
                id: 1,
                spentDate: "1984-01-01",
                client: HarvestClient(
                    id: 1,
                    name: "Client B"),
                project: HarvestProject(
                    id: 1,
                    name: "Project B",
                    code: "54321"),
                task: HarvestTask(
                    id: 1,
                    name: "Task B"),
                hours: 5.1,
                notes: "Notes",
                startedTime: nil,
                endedTime: nil,
                isRunning: false),
        ]
    }

    func getCompany() async throws -> HarvestCompany {
        throw HarvestError.unauthorized
    }

    func startTimeEntryWith(
        hours: Double, notes: String?, projectId: Int, spentDate: Date, taskId: Int
    ) async throws -> HarvestTimeEntry {
        throw HarvestError.unauthorized
    }

    func stopTimeEntry(_ timeEntry: HarvestTimeEntry) async throws -> HarvestTimeEntry {
        throw HarvestError.unauthorized
    }

    func restartTimeEntry(_ timeEntry: HarvestTimeEntry) async throws -> HarvestTimeEntry {
        throw HarvestError.unauthorized
    }

    func deleteTimeEntry(_ timeEntry: HarvestTimeEntry) async throws {
        throw HarvestError.unauthorized
    }

    func updateTimeEntry(_ timeEntry: HarvestTimeEntry) async throws -> HarvestTimeEntry {
        throw HarvestError.unauthorized
    }
}
