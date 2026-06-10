import Foundation
import Harvester
import UIKit

@Observable
@MainActor
class HarvestState {
    private var api: Harvester

    var accounts: [HarvestAccount] = []
    var company: HarvestCompany?
    var wantsTimestampTimers: Bool?
    var currentAccountId: Int? {
        didSet {
            api.currentAccountId = currentAccountId
        }
    }
    var isAuthorized = false {
        didSet {
            currentAccountId = api.currentAccountId
            wantsTimestampTimers = api.wantsTimestampTimers
        }
    }
    var projectAssignments: [HarvestProjectAssignment] = []
    var timeEntries: [HarvestTimeEntry] = [] {
        didSet {
            recomputeDerivedTimeEntryData()
        }
    }

    private(set) var timeEntriesByDate: [Date: [HarvestTimeEntry]] = [:]
    private(set) var timeEntryDates: [Date] = []
    private(set) var timeEntryTotalHoursByDate: [Date: Double] = [:]

    /// Monotonic counter incremented whenever a new time entry is started, used
    /// by `TimeEntriesView` as an observable signal to scroll its list to the top.
    private(set) var scrollToTopRequest: Int = 0

    var clients: [HarvestClient] {
        Set(projectAssignments.map { $0.client }).sorted { $0.name < $1.name }
    }

    var projects: [HarvestProject] {
        return
            projectAssignments
            .map { $0.project }
            .sorted { $0.name < $1.name }
    }

    var tasks: [HarvestTask] {
        return
            projectAssignments
            .flatMap { $0.taskAssignments }
            .map { $0.task }
            .sorted { $0.name < $1.name }
    }

    private func recomputeDerivedTimeEntryData() {
        let formatter = DateFormatter.yyyyMMdd
        var byDate: [Date: [HarvestTimeEntry]] = [:]
        for entry in timeEntries {
            guard let date = formatter.date(from: entry.spentDate) else { continue }
            byDate[date, default: []].append(entry)
        }
        timeEntriesByDate = byDate
        timeEntryDates = byDate.keys.sorted(by: >)

        var totals = [Date: Double]()
        for (date, entries) in byDate {
            totals[date] = entries.reduce(0) { $0 + $1.hours }
        }
        timeEntryTotalHoursByDate = totals
    }

    var timeEntryWeeklyAverage: Double {
        guard let oldestDate = timeEntryDates.last else {
            return 0
        }

        guard
            let daysSinceOldestEntry = Calendar.current.dateComponents(
                [.day],
                from: oldestDate,
                to: Date()
            ).day
        else {
            return 0
        }

        let totalHours = timeEntriesByDate.reduce(0) { $0 + $1.value.reduce(0) { $0 + $1.hours } }
        let numberOfWeeks = Double(daysSinceOldestEntry) / 7
        return totalHours / numberOfWeeks
    }

    var timeEntryTotalHoursInLastSevenDays: Double {
        let calendar = Calendar.current
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        guard let sixDaysAgoStartOfDay = calendar.date(byAdding: .day, value: -6, to: todayStart),
            let sevenDaysAgoStartOfDay = calendar.date(byAdding: .day, value: -7, to: todayStart),
            let todayInterval = calendar.dateInterval(of: .day, for: now)
        else {
            return 0
        }

        let hoursOnOrAfter: (Date) -> Double = { cutoff in
            self.timeEntriesByDate
                .filter { $0.key >= cutoff }
                .reduce(0) { $0 + $1.value.reduce(0) { $0 + $1.hours } }
        }

        let hoursSinceSixDaysAgo = hoursOnOrAfter(sixDaysAgoStartOfDay)
        let hoursSinceSevenDaysAgo = hoursOnOrAfter(sevenDaysAgoStartOfDay)
        let hoursFromSevenDaysAgo = hoursSinceSevenDaysAgo - hoursSinceSixDaysAgo

        let percentOfTodayCompleted =
            now.timeIntervalSince(todayInterval.start) / todayInterval.duration

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

    var user: HarvestUser?
    var userImage: UIImage?

    // MARK: Authorization Alert State
    var showingTokenAlert = false
    var tokenText = ""
    @ObservationIgnored private var authorizationContinuation:
        CheckedContinuation<String, any Error>?

    init(api: Harvester) {
        self.api = api
        isAuthorized = api.isAuthorized
    }

    func setupAuthorizationHandler(on provider: PersonalAccessTokenProvider) {
        provider.tokenRequestHandler = { [weak self] in
            guard let self else { throw AuthorizationProviderError.failed }
            return try await withCheckedThrowingContinuation { continuation in
                self.authorizationContinuation = continuation
                self.tokenText = ""
                self.showingTokenAlert = true
            }
        }
    }

    func completeAuthorization() {
        authorizationContinuation?.resume(returning: tokenText)
        authorizationContinuation = nil
    }

    func cancelAuthorization() {
        authorizationContinuation?.resume(throwing: AuthorizationProviderError.canceled)
        authorizationContinuation = nil
    }

    func authorize() async {
        do {
            let result = try await api.authorize()
            isAuthorized = result
        } catch {
            print("Failed to authorize with Harvest: \(error)")
        }
    }

    func deauthorize() {
        try? api.deauthorize()
        isAuthorized = api.isAuthorized
    }

    func loadAccounts() async {
        do {
            accounts = try await api.getAccounts()
        } catch {
            print("Failed to load accounts: \(error)")
        }
    }

    func loadCompany() async {
        do {
            company = try await api.getCompany()
        } catch {
            print("Failed to load company: \(error)")
        }
    }

    func loadProjectAssignments() async {
        do {
            projectAssignments = try await api.getProjectAssignments()
        } catch {
            // silently fail
        }
    }

    func loadTimeEntries() async {
        do {
            let newEntries = try await api.getTimeEntries()
            if newEntries != timeEntries {
                timeEntries = newEntries
            }
        } catch {
            print("Failed to load time entries: \(error)")
        }
    }

    func loadUser() async {
        do {
            let user = try await api.getMe()
            self.user = user
            let (data, _) = try await URLSession.shared.data(from: user.avatarUrl)
            self.userImage = UIImage(data: data)
        } catch {
            print("Failed to load user: \(error)")
        }
    }

    func startTimeEntryWith(
        client: HarvestClient, hours: Double, notes: String?, project: HarvestProject,
        spentDate: Date,
        task: HarvestTask
    ) {
        scrollToTopRequest += 1

        // If the requested project no longer exists for the client, fall back to the
        // client's current project. Some clients only have a single active project at
        // a time, so a stale entry should restart against whatever project is current.
        let project = resolvedProject(for: client, requested: project)
        let isToday = Calendar.current.isDateInToday(spentDate)

        if isToday {
            // Perform a quick local stop of all running time entries.
            while let index = indexOfRunningTimeEntry() {
                timeEntries[index] = timeEntries[index].stopped()
            }
        }

        // Perform a quick local insert.
        let timeEntry = HarvestTimeEntry(
            id: -Int.random(in: 1000...10000),
            spentDate: DateFormatter.yyyyMMdd.string(from: spentDate),
            client: client,
            project: project,
            task: task,
            hours: hours,
            notes: notes,
            startedTime: nil,
            endedTime: nil,
            isRunning: isToday)
        timeEntries.insert(timeEntry, at: 0)

        // Create on the server and reload.
        Task {
            do {
                let created = try await api.startTimeEntryWith(
                    hours: hours, notes: notes, projectId: project.id, spentDate: spentDate,
                    taskId: task.id)
                if isToday {
                    _ = try? await api.restartTimeEntry(created)
                }
            } catch {
                print("Failed to create time entry: \(error)")
            }
            await loadTimeEntries()
        }
    }

    func stopTimeEntry(_ timeEntry: HarvestTimeEntry) {
        // Perform a quick local stop.
        if let index = indexOfTimeEntry(id: timeEntry.id) {
            timeEntries[index] = timeEntry.stopped()
        }

        // Stop on the server and reload.
        Task {
            _ = try? await api.stopTimeEntry(timeEntry)
            await loadTimeEntries()
        }
    }

    func deleteTimeEntry(_ timeEntry: HarvestTimeEntry) {
        // Perform a quick local delete.
        timeEntries.removeAll { $0.id == timeEntry.id }

        // Delete from the server and reload.
        Task {
            try? await api.deleteTimeEntry(timeEntry)
            await loadTimeEntries()
        }
    }

    func updateTimeEntry(_ timeEntry: HarvestTimeEntry) {
        // A time entry must not be running if its date is not today.
        let needsStop = timeEntry.isRunning && !isToday(spentDateString: timeEntry.spentDate)
        let entryToApply = needsStop ? timeEntry.stopped() : timeEntry

        // Perform a quick local update.
        if let index = indexOfTimeEntry(id: entryToApply.id) {
            timeEntries[index] = entryToApply
        }

        // Update on the server and reload.
        Task {
            _ = try? await api.updateTimeEntry(entryToApply)
            if needsStop {
                _ = try? await api.stopTimeEntry(entryToApply)
            }
            await loadTimeEntries()
        }
    }

    func timeEntryById(_ id: Int) -> HarvestTimeEntry? {
        timeEntries.first { $0.id == id }
    }

    var hasRunningTimeEntry: Bool {
        timeEntries.contains { $0.isRunning }
    }

    private func indexOfTimeEntry(id: Int) -> Int? {
        timeEntries.firstIndex { $0.id == id }
    }

    private func indexOfRunningTimeEntry() -> Int? {
        timeEntries.firstIndex { $0.isRunning }
    }

    private func isToday(spentDateString: String) -> Bool {
        guard let date = DateFormatter.yyyyMMdd.date(from: spentDateString) else {
            return false
        }
        return Calendar.current.isDateInToday(date)
    }

    func projects(for client: HarvestClient) -> [HarvestProject] {
        projectAssignments
            .filter { $0.client.id == client.id }
            .map { $0.project }
            .sorted { $0.name < $1.name }
    }

    func tasks(for client: HarvestClient, project: HarvestProject) -> [HarvestTask] {
        projectAssignments
            .filter { $0.client.id == client.id && $0.project.id == project.id }
            .flatMap { $0.taskAssignments }
            .map { $0.task }
            .sorted { $0.name < $1.name }
    }

    private func resolvedProject(for client: HarvestClient, requested: HarvestProject)
        -> HarvestProject
    {
        let clientProjects = projects(for: client)
        if clientProjects.contains(where: { $0.id == requested.id }) {
            return requested
        }
        return clientProjects.first ?? requested
    }

    /// The top recent (project, task, notes) tuples per client over the last `windowDays`,
    /// limited to `perClientLimit` rows per client. Applies stale-project collapse via
    /// `resolvedProject(for:requested:)` once `projectAssignments` have loaded.
    func recentTasksByClient(
        now: Date = Date(),
        windowDays: Int = 30,
        perClientLimit: Int = 5
    ) -> [ClientTaskGroup] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -windowDays, to: now) ?? now
        let formatter = DateFormatter.yyyyMMdd
        // Only apply stale-data filtering once assignments have loaded; until then,
        // treat every entry's project as still valid so the menu isn't empty.
        let assignmentsLoaded = !projectAssignments.isEmpty

        var countsByClient: [Int: [String: (count: Int, task: RecentTask)]] = [:]
        var clientOrder: [HarvestClient] = []

        for entry in timeEntries {
            guard let entryDate = formatter.date(from: entry.spentDate),
                entryDate >= cutoff
            else { continue }

            // Hide entries for clients that no longer exist. If the project is gone
            // too, keep the entry only when the client has exactly one project — the
            // auto-switch on start will fall through to that single project.
            let clientProjects = projects(for: entry.client)
            let projectStillExists = clientProjects.contains { $0.id == entry.project.id }
            if assignmentsLoaded {
                guard !clientProjects.isEmpty else { continue }
                guard projectStillExists || clientProjects.count == 1 else { continue }
            }

            // Collapse stale duplicates onto the client's sole active project so
            // identical (task, notes) pairs that already use it merge together.
            let effectiveProject = resolvedProject(for: entry.client, requested: entry.project)

            let key = "\(effectiveProject.id)-\(entry.task.id)-\(entry.notes ?? "")"
            if countsByClient[entry.client.id] == nil {
                countsByClient[entry.client.id] = [:]
                clientOrder.append(entry.client)
            }
            if let existing = countsByClient[entry.client.id]![key] {
                countsByClient[entry.client.id]![key] =
                    (count: existing.count + 1, task: existing.task)
            } else {
                countsByClient[entry.client.id]![key] = (
                    count: 1,
                    task: RecentTask(
                        client: entry.client,
                        project: effectiveProject,
                        task: entry.task,
                        notes: entry.notes)
                )
            }
        }

        return clientOrder.map { client in
            let sorted = (countsByClient[client.id] ?? [:]).values
                .sorted { $0.count > $1.count }
                .prefix(perClientLimit)
                .map { $0.task }
            return ClientTaskGroup(client: client, tasks: Array(sorted))
        }
    }
}

struct RecentTask: Identifiable {
    let client: HarvestClient
    let project: HarvestProject
    let task: HarvestTask
    let notes: String?
    var id: String { "\(client.id)-\(project.id)-\(task.id)-\(notes ?? "")" }
}

struct ClientTaskGroup: Identifiable {
    let client: HarvestClient
    let tasks: [RecentTask]
    var id: Int { client.id }
}