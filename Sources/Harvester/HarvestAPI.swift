import Foundation

public class HarvestAPI {

    private var localStorage: LocalStorage
    private var networkClient: AuthorizedNetworkClient
    
    // MARK: Authorization
    
    public var currentAccountId: Int? {
        didSet {
            networkClient.accountId = currentAccountId
            localStorage.accountId = currentAccountId
        }
    }

    public private(set) var wantsTimestampTimers: Bool? {
        didSet {
            localStorage.wantsTimestampTimers = wantsTimestampTimers
        }
    }
    
    public var isAuthorized: Bool {
        return networkClient.isAuthorized
    }
    
    public func authorize() async throws -> Bool {
        let authorized = try await networkClient.authorize()
        if isAuthorized {
            let accounts = try await getAccounts()
            if accounts.count == 1 {
                currentAccountId = accounts[0].id
                if let company = try? await getCompany() {
                    wantsTimestampTimers = company.wantsTimestampTimers
                }
            }
        }
        return authorized
    }
    
    public func deauthorize() throws {
        try networkClient.deauthorize()
        currentAccountId = nil
        wantsTimestampTimers = nil
    }

    // MARK: Request Data
    
    public func getAccounts() async throws -> [HarvestAccount] {
        let response: AccountsRequest.Response = try await networkClient.send(AccountsRequest())
        return response.accounts
    }
    
    public func getMe() async throws -> HarvestUser {
        try await networkClient.send(UserRequest(userID: "me"))
    }
    
    public func getProjectAssignments() async throws -> [HarvestProjectAssignment] {
        let response: UserProjectAssignmentsRequest.Response = try await networkClient.send(UserProjectAssignmentsRequest(userID: "me"))
        return response.projectAssignments
    }
    
    public func getTimeEntries() async throws -> [HarvestTimeEntry] {
        let response: TimeEntriesRequest.Response = try await networkClient.send(TimeEntriesRequest())
        return response.timeEntries
    }
    
    public func getCompany() async throws -> HarvestCompany {
        try await networkClient.send(CompanyRequest())
    }

    public func startTimeEntryWith(hours: Double, notes: String?, projectId: Int, spentDate: Date, taskId: Int) async throws -> HarvestTimeEntry {
        try await networkClient.send(StartTimeEntryRequest(hours: hours, notes: notes, projectId: projectId, spentDate: spentDate, taskId: taskId))
    }

    public func stopTimeEntry(_ timeEntry: HarvestTimeEntry) async throws -> HarvestTimeEntry {
        try await networkClient.send(StopTimeEntryRequest(timeEntry: timeEntry))
    }

    public func restartTimeEntry(_ timeEntry: HarvestTimeEntry) async throws -> HarvestTimeEntry {
        try await networkClient.send(RestartTimeEntryRequest(timeEntry: timeEntry))
    }

    public func deleteTimeEntry(_ timeEntry: HarvestTimeEntry) async throws {
        // DELETE returns empty body, so we expect a decode error
        do {
            let _: HarvestTimeEntry = try await networkClient.send(DeleteTimeEntryRequest(timeEntry: timeEntry))
        } catch let error as HarvestError {
            if case .decoding = error { return }
            throw error
        }
    }

    public func updateTimeEntry(_ timeEntry: HarvestTimeEntry) async throws -> HarvestTimeEntry {
        try await networkClient.send(UpdateTimeEntryRequest(timeEntry: timeEntry))
    }

    // MARK: Initialization
    
    public init(configuration: HarvestAPIConfiguration,
                localStorage: LocalStorage = DefaultLocalStorage()) {
        self.localStorage = localStorage
        self.networkClient = HarvestNetworkClient(configuration: configuration)
        self.currentAccountId = localStorage.accountId
        self.wantsTimestampTimers = localStorage.wantsTimestampTimers
        self.networkClient.accountId = currentAccountId
    }
}
