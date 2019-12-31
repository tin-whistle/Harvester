import Combine
import Foundation
import Harvester

protocol Harvester {
    var currentAccountId: Int? { get set }
    var isAuthorized: Bool { get }
    var wantsTimestampTimers: Bool? { get }
    func authorize(completion: @escaping (_ result: Result<Bool, HarvestError>) -> Void)
    func deauthorize() throws
    func getAccounts(completion: @escaping (Result<[HarvestAccount], HarvestError>) -> Void)
    func getMe(completion: @escaping (Result<HarvestUser, HarvestError>) -> Void)
    func getProjectAssignments(completion: @escaping (Result<[HarvestProjectAssignment], HarvestError>) -> Void)
    func getTimeEntries(_ completion: @escaping (Result<[HarvestTimeEntry], HarvestError>) -> Void)
    func getCompany(_ completion: @escaping (Result<HarvestCompany, HarvestError>) -> Void)
    func startTimeEntryWith(hours: Double, notes: String?, projectId: Int, spentDate: Date, taskId: Int, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void)
    func stopTimeEntry(_ timeEntry: HarvestTimeEntry, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void)
    func restartTimeEntry(_ timeEntry: HarvestTimeEntry, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void)
    func deleteTimeEntry(_ timeEntry: HarvestTimeEntry, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void)
    func updateTimeEntry(_ timeEntry: HarvestTimeEntry, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void)

}

extension HarvestAPI: Harvester {
    
}

class PreviewHarvester: Harvester {
    var currentAccountId: Int?
    
    var isAuthorized = true

    var wantsTimestampTimers: Bool? = true

    func authorize(completion: @escaping (Result<Bool, HarvestError>) -> Void) {
        isAuthorized = true
    }
    
    func deauthorize() throws {
        isAuthorized = false
    }
    
    func getAccounts(completion: @escaping (Result<[HarvestAccount], HarvestError>) -> Void) {
        completion(.failure(.unauthorized))
    }
    
    func getMe(completion: @escaping (Result<HarvestUser, HarvestError>) -> Void) {
        completion(.failure(.unauthorized))
    }
    
    func getProjectAssignments(completion: @escaping (Result<[HarvestProjectAssignment], HarvestError>) -> Void) {
        completion(.failure(.unauthorized))
    }
    
    func getTimeEntries(_ completion: @escaping (Result<[HarvestTimeEntry], HarvestError>) -> Void) {
        completion(.success([
            HarvestTimeEntry(id: 0,
                             spentDate: "1984-01-02",
                             client: HarvestClient(id: 0,
                                                   name: "Client A"),
                             project: HarvestProject(id: 0,
                                                     name: "Project A",
                                                     code: "12345"),
                             task: HarvestTask(id: 0,
                                               name: "Task A"),
                             hours: 1.5,
                             notes: "Notes",
                             startedTime: nil,
                             endedTime: nil,
                             isRunning: true),
            HarvestTimeEntry(id: 1,
                             spentDate: "1984-01-01",
                             client: HarvestClient(id: 1,
                                                   name: "Client B"),
                             project: HarvestProject(id: 1,
                                                     name: "Project B",
                                                     code: "54321"),
                             task: HarvestTask(id: 1,
                                               name: "Task B"),
                             hours: 5.1,
                             notes: "Notes",
                             startedTime: nil,
                             endedTime: nil,
                             isRunning: false)
        ]))
        completion(.failure(.unauthorized))
    }
    
    func getCompany(_ completion: @escaping (Result<HarvestCompany, HarvestError>) -> Void) {
        completion(.failure(.unauthorized))
    }

    func startTimeEntryWith(hours: Double, notes: String?, projectId: Int, spentDate: Date, taskId: Int, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void) {
        completion(.failure(.unauthorized))
    }

    func stopTimeEntry(_ timeEntry: HarvestTimeEntry, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void) {
        completion(.failure(.unauthorized))
    }

    func restartTimeEntry(_ timeEntry: HarvestTimeEntry, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void) {
        completion(.failure(.unauthorized))
    }

    func deleteTimeEntry(_ timeEntry: HarvestTimeEntry, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void) {
        completion(.failure(.unauthorized))
    }

    func updateTimeEntry(_ timeEntry: HarvestTimeEntry, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void) {
        completion(.failure(.unauthorized))
    }
}
