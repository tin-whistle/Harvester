import Harvester
import SwiftUI

struct MainView: View {
    @Environment(HarvestState.self) var harvest

    @State private var modalSelection = ModalSelection.explore
    @State private var showModal = false


    private var recentTasksByClient: [ClientTaskGroup] {
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let formatter = DateFormatter.yyyyMMdd

        // Count occurrences of each unique task within the last month.
        var countsByClient: [Int: [String: (count: Int, task: RecentTask)]] = [:]
        var clientOrder: [HarvestClient] = []

        for entry in harvest.timeEntries {
            guard let entryDate = formatter.date(from: entry.spentDate),
                entryDate >= oneMonthAgo
            else { continue }

            let key = "\(entry.project.id)-\(entry.task.id)-\(entry.notes ?? "")"
            if countsByClient[entry.client.id] == nil {
                countsByClient[entry.client.id] = [:]
                clientOrder.append(entry.client)
            }
            if let existing = countsByClient[entry.client.id]![key] {
                countsByClient[entry.client.id]![key] = (count: existing.count + 1, task: existing.task)
            } else {
                countsByClient[entry.client.id]![key] = (
                    count: 1,
                    task: RecentTask(
                        client: entry.client,
                        project: entry.project,
                        task: entry.task,
                        notes: entry.notes)
                )
            }
        }

        // Return the top 5 most-used tasks per client.
        return clientOrder.map { client in
            let sorted = (countsByClient[client.id] ?? [:]).values
                .sorted { $0.count > $1.count }
                .prefix(5)
                .map { $0.task }
            return ClientTaskGroup(client: client, tasks: sorted)
        }
    }

    var addButton: some View {
        Menu {
            if !harvest.timeEntries.isEmpty {
                ForEach(recentTasksByClient) { group in
                    Section(group.client.name) {
                        ForEach(group.tasks) { recentTask in
                            Button {
                                harvest.startTimeEntryWith(
                                    client: recentTask.client,
                                    hours: 0,
                                    notes: recentTask.notes,
                                    project: recentTask.project,
                                    spentDate: Date(),
                                    task: recentTask.task)
                            } label: {
                                if let notes = recentTask.notes, !notes.isEmpty {
                                    Text(notes)
                                } else {
                                    Text("\(recentTask.project.name) — \(recentTask.task.name)")
                                }
                            }
                        }
                    }
                }
                Divider()
            }
            Button {
                self.modalSelection = .addTimeEntry
                self.showModal = true
            } label: {
                Label("New Time Entry…", systemImage: "square.and.pencil")
            }
        } label: {
            Image(systemName: "plus")
        }
    }

    var setupButton: some View {
        Menu {
            if harvest.isAuthorized {
                Button("Sign Out") {
                    harvest.deauthorize()
                }
                Button("Select Account") {
                    modalSelection = .selectAccount
                    showModal = true
                }
                Button("Explore API") {
                    modalSelection = .explore
                    showModal = true
                }
            } else {
                Button("Sign In") {
                    Task { await harvest.authorize() }
                }
            }
        } label: {
            if let userImage = harvest.userImage {
                Image(uiImage: userImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            } else {
                Text("Setup")
            }
        }
        .menuIndicator(.hidden)
    }

    @Environment(\.openURL) private var openURL

    var body: some View {
        @Bindable var harvest = harvest
        NavigationStack {
            Group {
                if self.harvest.currentAccountId == nil {
                    List {
                        Text("No Account Selected")
                    }
                } else {
                    TimeEntriesView()
                }
            }
            .navigationTitle("Harvester")
            .toolbar {
                if harvest.isAuthorized {
                    ToolbarItem(placement: .topBarLeading) {
                        addButton
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    setupButton
                }
                .sharedBackgroundVisibility(.hidden)
            }
        }
        .sheet(
            isPresented: self.$showModal,
            onDismiss: {
                Task { await self.harvest.loadTimeEntries() }
            }
        ) {
            if self.modalSelection == .addTimeEntry {
                NavigationStack {
                    EditTimeEntryView(show: self.$showModal, originalTimeEntry: nil)
                        .environment(self.harvest)
                }
            } else if self.modalSelection == .explore {
                NavigationStack {
                    ExploreView().environment(self.harvest)
                }
            } else {
                NavigationStack {
                    SelectAccountView(show: self.$showModal).environment(self.harvest)
                }
            }
        }
        .onChange(of: harvest.isAuthorized, initial: true) {
            if harvest.isAuthorized && harvest.userImage == nil {
                Task { await harvest.loadUser() }
            }
        }
        .alert("Authorization", isPresented: $harvest.showingTokenAlert) {
            TextField("Personal Access Token", text: $harvest.tokenText)
            Button("OK") {
                harvest.completeAuthorization()
            }
            Button("Cancel", role: .cancel) {
                harvest.cancelAuthorization()
            }
            Button("Open in Safari") {
                openURL(URL(string: "https://id.getharvest.com/developers")!)
                harvest.cancelAuthorization()
            }
        } message: {
            Text("Generate a personal access token at https://id.getharvest.com/developers")
        }
    }

}

enum ModalSelection {
    case addTimeEntry
    case explore
    case selectAccount
}

private struct RecentTask: Identifiable {
    let client: HarvestClient
    let project: HarvestProject
    let task: HarvestTask
    let notes: String?
    var id: String { "\(client.id)-\(project.id)-\(task.id)-\(notes ?? "")" }
}

private struct ClientTaskGroup: Identifiable {
    let client: HarvestClient
    let tasks: [RecentTask]
    var id: Int { client.id }
}

#if DEBUG
    struct MainView_Previews: PreviewProvider {
        static var previews: some View {
            MainView()
                .environment(HarvestState(api: PreviewHarvester()))
        }
    }
#endif
