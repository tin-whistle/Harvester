import Harvester
import SwiftUI

struct EditTimeEntryView: View {

    @Environment(HarvestState.self) var harvest

    @Environment(\.dismiss) private var dismiss
    let originalTimeEntry: HarvestTimeEntry?

    @State private var client: HarvestClient?
    @State private var project: HarvestProject?
    @State private var task: HarvestTask?
    @State private var notes: String = ""
    @State private var hourComponent: Int = 0
    @State private var minuteComponent: Int = 0

    @State private var spentDate: Date = Date()

    @State private var showingClientSheet = false
    @State private var showingProjectSheet = false
    @State private var showingTaskSheet = false
    @State private var showingNotesAlert = false

    var hours: Double {
        Double(hourComponent) + Double(minuteComponent) / 60
    }

    private var canSave: Bool {
        client != nil && project != nil && task != nil
    }

    var clients: [HarvestClient] {
        harvest.clients
    }

    var projects: [HarvestProject] {
        guard let client else { return [] }
        return harvest.projects(for: client)
    }

    var tasks: [HarvestTask] {
        guard let client, let project else { return [] }
        return harvest.tasks(for: client, project: project)
    }

    var cancelButton: some View {
        Button("Cancel") {
            self.dismiss()
        }
    }

    var saveButton: some View {
        Button("Save") {
            self.save()
        }
        .disabled(!canSave)
    }

    var body: some View {
        Form {
            DatePicker("Date", selection: $spentDate, displayedComponents: .date)
            Button(client?.name ?? "Select a Client") {
                self.showingClientSheet = true
            }
            .disabled(clients.count <= 1)
            .actionSheet(isPresented: $showingClientSheet) {
                buildClientActionSheet()
            }
            Button(project?.name ?? "Select a Project") {
                self.showingProjectSheet = true
            }
            .disabled(client == nil || projects.count <= 1)
            .actionSheet(isPresented: $showingProjectSheet) {
                buildProjectActionSheet()
            }
            Button(task?.name ?? "Select a Task") {
                self.showingTaskSheet = true
            }
            .disabled(client == nil || project == nil || tasks.count <= 1)
            .actionSheet(isPresented: $showingTaskSheet) {
                buildTaskActionSheet()
            }
            Section(header: Text("Notes")) {
                TextField("Add Notes", text: $notes)
                    .autocapitalization(.words)
            }
            if harvest.wantsTimestampTimers ?? false {
                Text("Timestamp timers are not yet supported.")
            } else {
                Section(header: Text("Hours")) {
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            Picker("Hour", selection: self.$hourComponent) {
                                ForEach(0...23, id: \.self) { hour in
                                    Text("\(hour)")
                                }
                            }
                            .frame(maxWidth: geometry.size.width / 2.5)
                            .clipped()
                            .pickerStyle(WheelPickerStyle())
                            .labelsHidden()
                            Text(":")
                            Picker("Minute", selection: self.$minuteComponent) {
                                ForEach(0...59, id: \.self) { minute in
                                    Text("\(minute, specifier: "%02d")")
                                }
                            }
                            .frame(maxWidth: geometry.size.width / 2.5)
                            .clipped()
                            .pickerStyle(WheelPickerStyle())
                            .labelsHidden()
                            Spacer()
                        }
                    }.frame(minHeight: 216)
                }
            }
        }
        .onAppear {
            self.notes = self.originalTimeEntry?.notes ?? ""
            let hours = self.originalTimeEntry?.hours ?? 0
            self.hourComponent = hours.hourComponentFromHours()
            self.minuteComponent = hours.minuteComponentFromHours()
            if let spentDateString = self.originalTimeEntry?.spentDate,
                let date = DateFormatter.yyyyMMdd.date(from: spentDateString)
            {
                self.spentDate = date
            }
            self.client = self.originalTimeEntry?.client
            self.project = self.originalTimeEntry?.project
            self.task = self.originalTimeEntry?.task
        }
        .task {
            await harvest.loadProjectAssignments()
            if !clients.isEmpty && client == nil {
                selectClient()
            }
        }
        .navigationTitle(originalTimeEntry == nil ? "Add Time Entry" : "Edit Time Entry")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                cancelButton
            }
            ToolbarItem(placement: .confirmationAction) {
                saveButton
            }
        }
    }

    private func save() {
        guard let client, let project, let task else { return }
        if let originalTimeEntry {
            let updatedTimeEntry = HarvestTimeEntry(
                id: originalTimeEntry.id,
                spentDate: DateFormatter.yyyyMMdd.string(from: spentDate),
                client: client,
                project: project,
                task: task,
                hours: hours,
                notes: notes,
                startedTime: originalTimeEntry.startedTime,
                endedTime: originalTimeEntry.endedTime,
                isRunning: originalTimeEntry.isRunning)
            harvest.updateTimeEntry(updatedTimeEntry)
        } else {
            harvest.startTimeEntryWith(
                client: client,
                hours: hours,
                notes: notes,
                project: project,
                spentDate: spentDate,
                task: task)
        }
        dismiss()
    }

    private func buildClientActionSheet() -> ActionSheet {
        buildActionSheet(title: "Select a Client", items: clients) { client in
            ActionSheet.Button.default(Text(client.name)) {
                self.client = client
                self.project = nil
                self.task = nil
                self.notes = ""
                self.selectProject()
            }
        }
    }

    private func buildProjectActionSheet() -> ActionSheet {
        buildActionSheet(title: "Select a Project", items: projects) { project in
            ActionSheet.Button.default(Text(project.name)) {
                self.project = project
                self.task = nil
                self.notes = ""
                self.selectTask()
            }
        }
    }

    private func buildTaskActionSheet() -> ActionSheet {
        buildActionSheet(title: "Select a Task", items: tasks) { task in
            ActionSheet.Button.default(Text(task.name)) {
                self.task = task
                self.notes = ""
            }
        }
    }

    private func buildActionSheet<T>(title: String, items: [T], map: (T) -> ActionSheet.Button)
        -> ActionSheet
    {
        ActionSheet(
            title: Text(title),
            message: nil,
            buttons: items.map(map) + [ActionSheet.Button.cancel(Text("Cancel"))])
    }

    private func selectClient() {
        if self.clients.count == 1 {
            self.client = self.clients.first
            self.selectProject()
        } else {
            self.showingClientSheet = true
        }
    }

    private func selectProject() {
        if self.projects.count == 1 {
            self.project = self.projects.first
            self.selectTask()
        } else {
            self.showingProjectSheet = true
        }
    }

    private func selectTask() {
        if self.tasks.count == 1 {
            self.task = self.tasks.first
        } else {
            self.showingTaskSheet = true
        }
    }
}

struct EditTimeEntryView_Previews: PreviewProvider {
    static var previews: some View {
        EditTimeEntryView(originalTimeEntry: nil)
            .environment(HarvestState(api: PreviewHarvester()))
    }
}
