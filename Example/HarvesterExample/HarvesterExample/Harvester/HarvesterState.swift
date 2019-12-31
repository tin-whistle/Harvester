import Combine
import Foundation
import Harvester
import UIKit

class HarvestState: ObservableObject {
    private var api: Harvester

    @Published var accounts: [HarvestAccount] = []
    @Published var company: HarvestCompany?
    @Published var wantsTimestampTimers: Bool?
    @Published var currentAccountId: Int? {
        didSet {
            api.currentAccountId = currentAccountId
        }
    }
    @Published var isAuthorized = false {
        didSet {
            currentAccountId = api.currentAccountId
            wantsTimestampTimers = api.wantsTimestampTimers
        }
    }
    @Published var projectAssignments: [HarvestProjectAssignment] = []
    @Published var timeEntries: [HarvestTimeEntry] = []

    var timeEntriesByDate: [Date: [HarvestTimeEntry]] {
        let formatter = DateFormatter.yyyyMMdd
        var timeEntriesByDate: [Date: [HarvestTimeEntry]] = [:]

        timeEntries.forEach {
            guard let date = formatter.date(from: $0.spentDate) else { return }
            var entries = timeEntriesByDate[date] ?? []
            entries.append($0)
            timeEntriesByDate[date] = entries
        }

        return timeEntriesByDate
    }

    var timeEntryDates: [Date] {
        return timeEntriesByDate.keys.sorted(by: >)
    }

    var timeEntryTotalHoursByDate: [Date: Double] {
        var totals = [Date: Double]()
        for (date, timeEntries) in timeEntriesByDate {
            totals[date] = timeEntries.reduce(0) { $0 + $1.hours }
        }
        return totals
    }

    @Published var user: HarvestUser?
    @Published var userImage: UIImage?

    init(api: Harvester) {
        self.api = api
        isAuthorized = api.isAuthorized
    }

    func authorize() {
        api.authorize { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("Failed to authorize with Harvest: \(error)")
                case .success(let isAuthorized):
                    self?.isAuthorized = isAuthorized
                }
            }
        }
    }

    func deauthorize() {
        try? api.deauthorize()
        isAuthorized = api.isAuthorized
    }

    func loadAccounts() {
        api.getAccounts { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(accounts):
                    self.accounts = accounts
                case .failure(let error):
                    print("Failed to load accounts: \(error)")
                }
            }
        }
    }

    func loadCompany() {
        api.getCompany { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(company):
                    self.company = company
                case .failure(let error):
                    print("Failed to load company: \(error)")
                }
            }
        }
    }

    func loadProjectAssignments(_ completion: (() -> Void)? = nil) {
        api.getProjectAssignments { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(projectAssignments):
                    self.projectAssignments = projectAssignments
                case .failure:
                    break
                }
                completion?()
            }
        }
    }

    func loadTimeEntries() {
        api.getTimeEntries { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(timeEntries):
                    self.timeEntries = timeEntries
                case let .failure(error):
                    print("Failed to load time entries: \(error)")
                }
            }
        }
    }

    func loadUser() {
        api.getMe { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(user):
                    self.user = user
                    URLSession.shared.dataTask(with: user.avatarURL) { data, response, error in
                        guard let data = data, let image = UIImage(data: data) else { return }
                        self.userImage = image
                    }.resume()
                case .failure(let error):
                    print("Failed to load user: \(error)")
                }
            }
        }
    }

    func startTimeEntryWith(hours: Double, notes: String?, projectId: Int, spentDate: Date, taskId: Int) {
        api.startTimeEntryWith(hours: hours, notes: notes, projectId: projectId, spentDate: spentDate, taskId: taskId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let timeEntry):
                    self?.api.restartTimeEntry(timeEntry) { _ in
                        DispatchQueue.main.async {
                            self?.loadTimeEntries()
                        }
                    }
                case .failure(let error):
                    print("Failed to create time entry: \(error)")
                }
            }
        }
    }

    func stopTimeEntry(_ timeEntry: HarvestTimeEntry) {
        api.stopTimeEntry(timeEntry) { [weak self] _ in
            DispatchQueue.main.async {
                self?.loadTimeEntries()
            }
        }
    }

    func deleteTimeEntry(_ timeEntry: HarvestTimeEntry) {
        // Perform a quick local delete.
        timeEntries.removeAll { $0.id == timeEntry.id }

        // Delete from the server and reload.
        api.deleteTimeEntry(timeEntry) { [weak self] _ in
            DispatchQueue.main.async {
                self?.loadTimeEntries()
            }
        }
    }

    func updateTimeEntry(_ timeEntry: HarvestTimeEntry) {
        // Perform a quick local update.
        if let index = timeEntries.firstIndex(where: { $0.id == timeEntry.id }) {
            timeEntries[index] = timeEntry
        }

        // Update on the server and reload.
        api.updateTimeEntry(timeEntry) { [weak self] _ in
            DispatchQueue.main.async {
                self?.loadTimeEntries()
            }
        }
    }
}

extension DateFormatter {
    static let yyyyMMdd: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
