import Combine
import Harvester

protocol Harvest: ObservableObject {
    var currentAccountId: Int? { get set }
    var isAuthorized: Bool { get }
    func authorize(completion: @escaping (_ result: Result<Bool, HarvestError>) -> Void)
    func deauthorize() throws
    func getAccounts(completion: @escaping (Result<[HarvestAccount], HarvestError>) -> Void)
    func getMe(completion: @escaping (Result<HarvestUser, HarvestError>) -> Void)
    func getProjectAssignments(completion: @escaping (Result<[HarvestProjectAssignment], HarvestError>) -> Void)
    func getTimeEntries(_ completion: @escaping (Result<[HarvestTimeEntry], HarvestError>) -> Void)
    func getCompany(_ completion: @escaping (Result<HarvestCompany, HarvestError>) -> Void)
}

extension HarvestAPI: Harvest {
    
}

class PreviewHarvest: Harvest {
    var currentAccountId: Int?
    
    var isAuthorized = false
    
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
        completion(.failure(.unauthorized))
    }
    
    func getCompany(_ completion: @escaping (Result<HarvestCompany, HarvestError>) -> Void) {
        completion(.failure(.unauthorized))
    }
}
