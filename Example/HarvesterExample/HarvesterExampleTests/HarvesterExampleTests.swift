import Foundation
import Harvester
import Testing

@testable import HarvesterExample

@MainActor
struct RecentTasksByClientTests {

    /// SPEC §4b: when a historical time entry references a project that no longer
    /// exists for its client AND the client now has exactly one active project,
    /// the recent-tasks list should still surface the entry, re-mapped to the
    /// client's current single project. Duplicates that collapse to the same
    /// (currentProject, task, notes) tuple should merge.
    @Test
    func collapsesStaleEntryOntoSingleCurrentProject() {
        let state = HarvestState(api: PreviewHarvester())

        let client = HarvestClient(id: 1, name: "Acme")
        let currentProject = HarvestProject(id: 100, name: "Active")
        let removedProject = HarvestProject(id: 999, name: "Archived")
        let task = HarvestTask(id: 10, name: "Engineering")

        let taskAssignment = HarvestTaskAssignment(
            id: 1, task: task, isActive: true, billable: true,
            created: "", updated: "")
        state.projectAssignments = [
            HarvestProjectAssignment(
                id: 1,
                isActive: true,
                isProjectManager: false,
                useDefaultRates: true,
                created: "",
                updated: "",
                project: currentProject,
                client: client,
                taskAssignments: [taskAssignment])
        ]

        let today = DateFormatter.yyyyMMdd.string(from: Date())
        state.timeEntries = [
            HarvestTimeEntry(
                id: 1, spentDate: today, client: client, project: removedProject,
                task: task, hours: 1, notes: "Notes",
                startedTime: nil, endedTime: nil, isRunning: false),
            HarvestTimeEntry(
                id: 2, spentDate: today, client: client, project: currentProject,
                task: task, hours: 1, notes: "Notes",
                startedTime: nil, endedTime: nil, isRunning: false),
        ]

        let groups = state.recentTasksByClient()
        #expect(groups.count == 1)
        let recent = try? #require(groups.first?.tasks.first)
        #expect(recent?.project.id == currentProject.id)
        // The two entries (one stale, one current) collapse to a single row.
        #expect(groups.first?.tasks.count == 1)
    }

    /// Sanity: two entries with identical (client, project, task, notes) should
    /// collapse to one row with count 2 — no edge case involved.
    @Test
    func identicalEntriesCollapseToOneRow() {
        let state = HarvestState(api: PreviewHarvester())

        let client = HarvestClient(id: 1, name: "Acme")
        let project = HarvestProject(id: 100, name: "Active")
        let task = HarvestTask(id: 10, name: "Engineering")

        let taskAssignment = HarvestTaskAssignment(
            id: 1, task: task, isActive: true, billable: true,
            created: "", updated: "")
        state.projectAssignments = [
            HarvestProjectAssignment(
                id: 1, isActive: true, isProjectManager: false, useDefaultRates: true,
                created: "", updated: "",
                project: project, client: client,
                taskAssignments: [taskAssignment])
        ]

        let today = DateFormatter.yyyyMMdd.string(from: Date())
        state.timeEntries = [
            HarvestTimeEntry(
                id: 1, spentDate: today, client: client, project: project,
                task: task, hours: 1, notes: "Notes",
                startedTime: nil, endedTime: nil, isRunning: false),
            HarvestTimeEntry(
                id: 2, spentDate: today, client: client, project: project,
                task: task, hours: 1, notes: "Notes",
                startedTime: nil, endedTime: nil, isRunning: false),
        ]

        #expect(state.recentTasksByClient().count == 1)
        #expect(state.recentTasksByClient().first?.tasks.count == 1)
    }

    /// SPEC §4b: when a client has multiple current projects and a historical entry
    /// references a project that has been removed, the entry must be HIDDEN from the
    /// menu (no safe single-project fallback exists). Only entries whose project still
    /// exists should remain.
    @Test
    func hidesStaleEntryWhenClientHasMultipleProjects() {
        let state = HarvestState(api: PreviewHarvester())

        let client = HarvestClient(id: 1, name: "Acme")
        let projectA = HarvestProject(id: 100, name: "Active A")
        let projectB = HarvestProject(id: 200, name: "Active B")
        let removedProject = HarvestProject(id: 999, name: "Archived")
        let task = HarvestTask(id: 10, name: "Engineering")

        let taskAssignment = HarvestTaskAssignment(
            id: 1, task: task, isActive: true, billable: true, created: "", updated: "")
        state.projectAssignments = [
            HarvestProjectAssignment(
                id: 1, isActive: true, isProjectManager: false, useDefaultRates: true,
                created: "", updated: "",
                project: projectA, client: client, taskAssignments: [taskAssignment]),
            HarvestProjectAssignment(
                id: 2, isActive: true, isProjectManager: false, useDefaultRates: true,
                created: "", updated: "",
                project: projectB, client: client, taskAssignments: [taskAssignment]),
        ]

        let today = DateFormatter.yyyyMMdd.string(from: Date())
        state.timeEntries = [
            HarvestTimeEntry(
                id: 1, spentDate: today, client: client, project: projectA,
                task: task, hours: 1, notes: "Notes",
                startedTime: nil, endedTime: nil, isRunning: false),
            HarvestTimeEntry(
                id: 2, spentDate: today, client: client, project: removedProject,
                task: task, hours: 1, notes: "Notes",
                startedTime: nil, endedTime: nil, isRunning: false),
        ]

        let groups = state.recentTasksByClient()
        #expect(groups.first?.tasks.count == 1)
        #expect(groups.first?.tasks.first?.project.id == projectA.id)
    }

    /// Live-app load order: `timeEntries` arrives FIRST (cache built with
    /// `assignmentsLoaded = false`), then `projectAssignments` arrives. After the
    /// second `didSet`, the cache must reflect the stale-collapse — not a stale
    /// pre-load snapshot.
    @Test
    func collapseAppliesAfterProjectAssignmentsLoadSecond() {
        let state = HarvestState(api: PreviewHarvester())

        let client = HarvestClient(id: 1, name: "Acme")
        let currentProject = HarvestProject(id: 100, name: "Active")
        let removedProject = HarvestProject(id: 999, name: "Archived")
        let task = HarvestTask(id: 10, name: "Engineering")

        let today = DateFormatter.yyyyMMdd.string(from: Date())
        // Step 1: time entries arrive while projectAssignments is still empty.
        state.timeEntries = [
            HarvestTimeEntry(
                id: 1, spentDate: today, client: client, project: removedProject,
                task: task, hours: 1, notes: "Notes",
                startedTime: nil, endedTime: nil, isRunning: false),
            HarvestTimeEntry(
                id: 2, spentDate: today, client: client, project: currentProject,
                task: task, hours: 1, notes: "Notes",
                startedTime: nil, endedTime: nil, isRunning: false),
        ]

        // Step 2: projectAssignments arrive a moment later.
        let taskAssignment = HarvestTaskAssignment(
            id: 1, task: task, isActive: true, billable: true, created: "", updated: "")
        state.projectAssignments = [
            HarvestProjectAssignment(
                id: 1, isActive: true, isProjectManager: false, useDefaultRates: true,
                created: "", updated: "",
                project: currentProject, client: client,
                taskAssignments: [taskAssignment])
        ]

        let groups = state.recentTasksByClient()
        #expect(groups.first?.tasks.count == 1)
        #expect(groups.first?.tasks.first?.project.id == currentProject.id)
    }

    /// When project assignments haven't loaded yet (`projectAssignments.isEmpty`),
    /// the recent-tasks list must NOT filter out any entries — the user still sees
    /// their history while the network is in flight.
    @Test
    func showsEntriesEvenBeforeAssignmentsLoad() {
        let state = HarvestState(api: PreviewHarvester())

        let client = HarvestClient(id: 1, name: "Acme")
        let project = HarvestProject(id: 100, name: "Active")
        let task = HarvestTask(id: 10, name: "Engineering")
        let today = DateFormatter.yyyyMMdd.string(from: Date())

        state.timeEntries = [
            HarvestTimeEntry(
                id: 1, spentDate: today, client: client, project: project,
                task: task, hours: 1, notes: "Notes",
                startedTime: nil, endedTime: nil, isRunning: false)
        ]

        #expect(state.recentTasksByClient().first?.tasks.first?.project.id == project.id)
    }
}

/// `.convertFromSnakeCase` mutates the JSON key BEFORE matching the CodingKey
/// `stringValue`. Models whose CodingKeys raw values are still snake_case
/// (HarvestProjectAssignment, HarvestTaskAssignment, HarvestCompany) won't
/// match the converted camelCase JSON keys and silently fail to decode. This
/// test guards the live-data path.
@MainActor
struct DecodingTests {

    @Test
    func projectAssignmentDecodesWithConvertFromSnakeCase() throws {
        let json = """
        {
          "id": 1,
          "is_active": true,
          "is_project_manager": false,
          "use_default_rates": true,
          "created_at": "2026-06-03T15:17:16Z",
          "updated_at": "2026-06-03T15:17:16Z",
          "project": {"id": 100, "name": "P", "code": "X"},
          "client": {"id": 1, "name": "C"},
          "task_assignments": []
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode(
            HarvestProjectAssignment.self,
            from: Data(json.utf8))
        #expect(decoded.id == 1)
        #expect(decoded.isActive == true)
        #expect(decoded.project.id == 100)
        #expect(decoded.client.id == 1)
    }
}

@MainActor
struct HarvestTimeEntryStoppedTests {

    @Test
    func stoppedClearsIsRunningAndPreservesOtherFields() {
        let running = HarvestTimeEntry(
            id: 7,
            spentDate: "2026-06-09",
            client: HarvestClient(id: 1, name: "Acme"),
            project: HarvestProject(id: 100, name: "P"),
            task: HarvestTask(id: 10, name: "T"),
            hours: 1.5,
            notes: "abc",
            startedTime: "09:00",
            endedTime: nil,
            isRunning: true)

        let stopped = running.stopped()

        #expect(stopped.isRunning == false)
        #expect(stopped.id == running.id)
        #expect(stopped.spentDate == running.spentDate)
        #expect(stopped.client.id == running.client.id)
        #expect(stopped.project.id == running.project.id)
        #expect(stopped.task.id == running.task.id)
        #expect(stopped.hours == running.hours)
        #expect(stopped.notes == running.notes)
        #expect(stopped.startedTime == running.startedTime)
        #expect(stopped.endedTime == running.endedTime)
    }
}
