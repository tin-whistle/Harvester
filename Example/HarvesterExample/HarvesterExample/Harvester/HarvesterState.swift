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

    var clients: [HarvestClient] {
        Set(projectAssignments.map { $0.client }).sorted { $0.name < $1.name }
    }

    var projects: [HarvestProject] {
        return projectAssignments
            .map { $0.project }
            .sorted { $0.name < $1.name }
    }

    var tasks: [HarvestTask] {
        return projectAssignments
            .flatMap { $0.taskAssignments }
            .map { $0.task }
            .sorted { $0.name < $1.name }
    }

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

    var timeEntryTotalHoursInLastSevenDays: Double {
        let now = Date()
        guard let sixDaysAgoExactly = Calendar.current.date(byAdding: .day, value: -6, to: now),
              let sixDaysAgoStartOfDay = DateFormatter.yyyyMMdd.date(from: DateFormatter.yyyyMMdd.string(from: sixDaysAgoExactly)),
              let sevenDaysAgoExactly = Calendar.current.date(byAdding: .day, value: -7, to: now),
              let sevenDaysAgoStartOfDay = DateFormatter.yyyyMMdd.date(from: DateFormatter.yyyyMMdd.string(from: sevenDaysAgoExactly)),
              let todayInterval = Calendar.current.dateInterval(of: .day, for: now) else {
            return 0
        }

        let hoursSinceSixDaysAgo = timeEntriesByDate
            .filter { $0.key >= sixDaysAgoStartOfDay }
            .reduce(0) { $0 + $1.value.reduce(0) { $0 + $1.hours } }

        let hoursSinceSevenDaysAgo = timeEntriesByDate
            .filter { $0.key >= sevenDaysAgoStartOfDay }
            .reduce(0) { $0 + $1.value.reduce(0) { $0 + $1.hours } }

        let hoursFromSevenDaysAgo = hoursSinceSevenDaysAgo - hoursSinceSixDaysAgo

        let percentOfTodayCompleted = now.timeIntervalSince(todayInterval.start) / todayInterval.duration

        return hoursSinceSixDaysAgo + (1 - percentOfTodayCompleted) * hoursFromSevenDaysAgo
     }

    var timeEntryTotalHoursThisWeek: Double {
        guard let thisWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date()) else {
            return 0
        }
        let timeEntriesThisWeek = timeEntries.filter {
            guard let date = DateFormatter.yyyyMMdd.date(from: $0.spentDate) else { return false }
            return date >= thisWeek.start && date <= thisWeek.end
        }
        return timeEntriesThisWeek.reduce(0) { $0 + $1.hours }
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

    func startTimeEntryWith(client: HarvestClient, hours: Double, notes: String?, project: HarvestProject, spentDate: Date, task: HarvestTask) {
        // Perform a quick local stop of all running time entries.
        while timeEntries.contains(where: { $0.isRunning }) {
            if let index = timeEntries.firstIndex(where: { $0.isRunning }) {
                let stopped = HarvestTimeEntry(id: timeEntries[index].id,
                                               spentDate: timeEntries[index].spentDate,
                                               client: timeEntries[index].client,
                                               project: timeEntries[index].project,
                                               task: timeEntries[index].task,
                                               hours: timeEntries[index].hours,
                                               notes: timeEntries[index].notes,
                                               startedTime: timeEntries[index].startedTime,
                                               endedTime: timeEntries[index].endedTime,
                                               isRunning: false)
                timeEntries[index] = stopped
            }
        }
        // Perform a quick local start.
        let timeEntry = HarvestTimeEntry(id: Int.random(in: 1000...10000),
                                         spentDate: DateFormatter.yyyyMMdd.string(from: spentDate),
                                         client: client,
                                         project: project,
                                         task: task,
                                         hours: hours,
                                         notes: notes,
                                         startedTime: nil,
                                         endedTime: nil,
                                         isRunning: true)
        timeEntries.insert(timeEntry, at: 0)


        // Start on the server and reload.
        api.startTimeEntryWith(hours: hours, notes: notes, projectId: project.id, spentDate: spentDate, taskId: task.id) { [weak self] result in
            switch result {
            case .success(let timeEntry):
                self?.api.restartTimeEntry(timeEntry) { _ in
                    self?.loadTimeEntries()
                }
            case .failure(let error):
                print("Failed to create time entry: \(error)")
                self?.loadTimeEntries()
            }
        }
    }

    func stopTimeEntry(_ timeEntry: HarvestTimeEntry) {
        // Perform a quick local stop.
        if let index = timeEntries.firstIndex(where: { $0.id == timeEntry.id }) {
            let stopped = HarvestTimeEntry(id: timeEntry.id,
                                           spentDate: timeEntry.spentDate,
                                           client: timeEntry.client,
                                           project: timeEntry.project,
                                           task: timeEntry.task,
                                           hours: timeEntry.hours,
                                           notes: timeEntry.notes,
                                           startedTime: timeEntry.startedTime,
                                           endedTime: timeEntry.endedTime,
                                           isRunning: false)
            timeEntries[index] = stopped
        }

        // Stop on the server and reload.
        api.stopTimeEntry(timeEntry) { [weak self] _ in
            self?.loadTimeEntries()
        }
    }

    func deleteTimeEntry(_ timeEntry: HarvestTimeEntry) {
        // Perform a quick local delete.
        timeEntries.removeAll { $0.id == timeEntry.id }

        // Delete from the server and reload.
        api.deleteTimeEntry(timeEntry) { [weak self] _ in
            self?.loadTimeEntries()
        }
    }

    func updateTimeEntry(_ timeEntry: HarvestTimeEntry) {
        // Perform a quick local update.
        if let index = timeEntries.firstIndex(where: { $0.id == timeEntry.id }) {
            timeEntries[index] = timeEntry
        }

        // Update on the server and reload.
        api.updateTimeEntry(timeEntry) { [weak self] _ in
            self?.loadTimeEntries()
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
