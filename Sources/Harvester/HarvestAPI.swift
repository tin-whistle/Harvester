import UIKit
import SwiftUI
import Combine

public class HarvestAPI: ObservableObject {

    private var networkClient: AuthorizedNetworkClient
    
    // MARK: Authorization
    
    public var currentAccount: HarvestAccount? {
        didSet {
            networkClient.accountID = currentAccount?.id
        }
    }
    
    public var isAuthorized: Bool {
        return networkClient.isAuthorized
    }
    
    public func authorize(completion: @escaping (_ result: Result<Bool, HarvestError>) -> Void) {
        networkClient.authorize { [weak self] result in
            self?.objectWillChange.send()
            completion(result)
        }
    }
    
    public func deauthorize() throws {
        objectWillChange.send()
        try networkClient.deauthorize()
    }

    // MARK: Request Data
    
    public func getAccounts(completion: @escaping (Result<[HarvestAccount], HarvestError>) -> Void) {
        networkClient.send(AccountsRequest()) {
            completion($0.map { $0.accounts })
        }
    }
    
    public func getMe(completion: @escaping (Result<HarvestUser, HarvestError>) -> Void) {
        networkClient.send(UserRequest(userID: "me"), completion: completion)
    }
    
    public func getProjectAssignments(completion: @escaping (Result<[HarvestProjectAssignment], HarvestError>) -> Void) {
        networkClient.send(UserProjectAssignmentsRequest(userID: "me")) {
            completion($0.map { $0.projectAssignments })
        }
    }
    
    public func getTimeEntries(_ completion: @escaping (Result<[HarvestTimeEntry], HarvestError>) -> Void) {
        networkClient.send(TimeEntriesRequest()) {
           completion($0.map { $0.timeEntries })
        }
    }
    
    public func getCompany(_ completion: @escaping (Result<HarvestCompany, HarvestError>) -> Void) {
        networkClient.send(CompanyRequest(), completion: completion)
    }
    
    // MARK: Initialization
    
    public init(configuration: HarvestAPIConfiguration) {
        self.networkClient = HarvestNetworkClient(configuration: configuration)
    }
    
    // MARK: BindableObject
    public var objectWillChange = PassthroughSubject<Void, Never>()
}
