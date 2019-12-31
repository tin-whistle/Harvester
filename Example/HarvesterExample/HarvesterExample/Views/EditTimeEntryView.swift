import SwiftUI
import Harvester

struct EditTimeEntryView : View {

    enum Modification<T> {
        case modified(_: T)
        case unmodified
    }

    @EnvironmentObject var harvest: HarvestState

    @Binding var show: Bool
    let originalTimeEntry: HarvestTimeEntry?

    @State private var modifiedClient = Modification<HarvestClient?>.unmodified
    @State private var modifiedProject = Modification<HarvestProject?>.unmodified
    @State private var modifiedTask = Modification<HarvestTask?>.unmodified
    @State private var notes: String = ""
    @State private var hourComponent: Int = 0
    @State private var minuteComponent: Int = 0
    @State private var timeDate: Date = Date()

    @State private var showingClientSheet = false
    @State private var showingProjectSheet = false
    @State private var showingTaskSheet = false
    @State private var showingNotesAlert = false

    var client: HarvestClient? {
        switch modifiedClient {
        case .modified(let client):
            return client
        case .unmodified:
            return originalTimeEntry?.client
        }
    }

    var project: HarvestProject? {
        switch modifiedProject {
        case .modified(let project):
            return project
        case .unmodified:
            return originalTimeEntry?.project
        }
    }

    var task: HarvestTask? {
        switch modifiedTask {
        case .modified(let task):
            return task
        case .unmodified:
            return originalTimeEntry?.task
        }
    }

    var hours: Double {
        Double(hourComponent) + Double(minuteComponent) / 60
    }

    private var canSave: Bool {
        client != nil && project != nil && task != nil
    }

    var clients: [HarvestClient] {
        Set(harvest.projectAssignments.map { $0.client }).sorted { $0.name < $1.name }
    }

    var projects: [HarvestProject] {
        guard let client = client else { return [] }
        return harvest.projectAssignments
            .filter { $0.client.id == client.id }
            .map { $0.project }
            .sorted { $0.name < $1.name }
    }

    var tasks: [HarvestTask] {
        guard let client = client else { return [] }
        guard let project = project else { return [] }
        return harvest.projectAssignments
            .filter { $0.client.id == client.id && $0.project.id == project.id }
            .flatMap { $0.taskAssignments }
            .map { $0.task }
            .sorted { $0.name < $1.name }
    }

    var cancelButton: some View {
        Button("Cancel") {
            self.show = false
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
            self.harvest.loadProjectAssignments() {
                if !self.clients.isEmpty && self.client == nil {
                    self.selectClient()
                }
            }
            self.notes = self.originalTimeEntry?.notes ?? ""
            let hours = self.originalTimeEntry?.hours ?? 0
            self.hourComponent = hours.hourComponentFromHours()
            self.minuteComponent = hours.minuteComponentFromHours()
        }
        .navigationBarTitle(originalTimeEntry == nil ? "Add Time Entry" : "Edit Time Entry")
        .navigationBarItems(leading: cancelButton, trailing: saveButton)
    }

    private func save() {
        if let originalTimeEntry = originalTimeEntry {
            guard let client = client, let project = project, let task = task else { return }
            let updatedTimeEntry = HarvestTimeEntry(id: originalTimeEntry.id,
                                                    spentDate: originalTimeEntry.spentDate,
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
            guard let project = project, let task = task else { return }
            harvest.startTimeEntryWith(hours: hours,
                                       notes: notes,
                                       projectId: project.id,
                                       spentDate: Date(),
                                       taskId: task.id)
        }
        show = false
    }

    private func buildClientActionSheet() -> ActionSheet {
        buildActionSheet(title: "Select a Client", items: clients) { client in
            ActionSheet.Button.default(Text(client.name)) {
                self.modifiedClient = .modified(client)
                self.modifiedProject = .modified(nil)
                self.modifiedTask = .modified(nil)
                self.notes = ""
                self.selectProject()
            }
        }
    }

    private func buildProjectActionSheet() -> ActionSheet {
        buildActionSheet(title: "Select a Project", items: projects) { project in
            ActionSheet.Button.default(Text(project.name)) {
                self.modifiedProject = .modified(project)
                self.modifiedTask = .modified(nil)
                self.notes = ""
                self.selectTask()
            }
        }
    }

    private func buildTaskActionSheet() -> ActionSheet {
        buildActionSheet(title: "Select a Task", items: tasks) { task in
            ActionSheet.Button.default(Text(task.name)) {
                self.modifiedTask = .modified(task)
                self.notes = ""
            }
        }
    }

    private func buildActionSheet<T>(title: String, items: [T], map: (T) -> ActionSheet.Button) -> ActionSheet {
        ActionSheet(title: Text(title),
                    message: nil,
                    buttons: items.map(map) + [ActionSheet.Button.cancel(Text("Cancel"))])
    }

    private func selectClient() {
        if self.clients.count == 1 {
            self.modifiedClient = .modified(self.clients.first)
            self.selectProject()
        } else {
            self.showingClientSheet = true
        }
    }

    private func selectProject() {
        if self.projects.count == 1 {
            self.modifiedProject = .modified(self.projects.first)
            self.selectTask()
        } else {
            self.showingProjectSheet = true
        }
    }

    private func selectTask() {
        if self.tasks.count == 1 {
            self.modifiedTask = .modified(self.tasks.first)
        } else {
            self.showingTaskSheet = true
        }
    }
}

struct EditTimeEntryView_Previews: PreviewProvider {
    static var previews: some View {
        EditTimeEntryView(show: .constant(true), originalTimeEntry: nil)
            .environmentObject(HarvestState(api: PreviewHarvester()))
    }
}
