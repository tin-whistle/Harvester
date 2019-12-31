import UIKit
import SwiftUI
import Combine

public class HarvestAPI: ObservableObject {

    private var localStorage: LocalStorage
    private var networkClient: AuthorizedNetworkClient
    
    // MARK: Authorization
    
    public var currentAccountId: Int? {
        get {
            localStorage.accountId
        }
        set {
            objectWillChange.send()
            networkClient.accountId = newValue
            localStorage.accountId = newValue
        }
    }

    public private(set) var wantsTimestampTimers: Bool? {
        get {
            localStorage.wantsTimestampTimers
        }
        set {
            localStorage.wantsTimestampTimers = newValue
        }
    }
    
    public var isAuthorized: Bool {
        return networkClient.isAuthorized
    }
    
    public func authorize(completion: @escaping (_ result: Result<Bool, HarvestError>) -> Void) {
        networkClient.authorize { [weak self] authorizeResult in
            if self?.isAuthorized ?? false {
                self?.getAccounts { getAccountsResult in
                    if case let .success(accounts) = getAccountsResult, accounts.count == 1 {
                        self?.currentAccountId = accounts[0].id
                        self?.getCompany { getCompanyResult in
                            if case let .success(company) = getCompanyResult {
                                self?.wantsTimestampTimers = company.wantsTimestampTimers
                            }
                            self?.objectWillChange.send()
                            completion(authorizeResult)
                        }
                    } else {
                        self?.objectWillChange.send()
                        completion(authorizeResult)
                    }
                }
            } else {
                self?.objectWillChange.send()
                completion(authorizeResult)
            }
        }
    }
    
    public func deauthorize() throws {
        objectWillChange.send()
        try networkClient.deauthorize()
        currentAccountId = nil
        wantsTimestampTimers = nil
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

    public func startTimeEntryWith(hours: Double, notes: String?, projectId: Int, spentDate: Date, taskId: Int, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void) {
        networkClient.send(StartTimeEntryRequest(hours: hours, notes: notes, projectId: projectId, spentDate: spentDate, taskId: taskId), completion: completion)
    }

    public func stopTimeEntry(_ timeEntry: HarvestTimeEntry, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void) {
        networkClient.send(StopTimeEntryRequest(timeEntry: timeEntry), completion: completion)
    }

    public func restartTimeEntry(_ timeEntry: HarvestTimeEntry, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void) {
        networkClient.send(RestartTimeEntryRequest(timeEntry: timeEntry), completion: completion)
    }

    public func deleteTimeEntry(_ timeEntry: HarvestTimeEntry, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void) {
        networkClient.send(DeleteTimeEntryRequest(timeEntry: timeEntry), completion: completion)
    }

    public func updateTimeEntry(_ timeEntry: HarvestTimeEntry, completion: @escaping (Result<HarvestTimeEntry, HarvestError>) -> Void) {
        networkClient.send(UpdateTimeEntryRequest(timeEntry: timeEntry), completion: completion)
    }

    // MARK: Initialization
    
    public init(configuration: HarvestAPIConfiguration,
                localStorage: LocalStorage = DefaultLocalStorage()) {
        self.localStorage = localStorage
        self.networkClient = HarvestNetworkClient(configuration: configuration)
        self.networkClient.accountId = currentAccountId

    }
    
    // MARK: ObservableObject
    public var objectWillChange = PassthroughSubject<Void, Never>()
}
