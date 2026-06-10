import Harvester
import SwiftUI

struct MainView: View {
    @Environment(HarvestState.self) var harvest

    @State private var modalSelection: ModalSelection?

    var addButton: some View {
        Menu {
            if !harvest.timeEntries.isEmpty {
                ForEach(harvest.recentTasksByClient()) { group in
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
                }
                Button("Explore API") {
                    modalSelection = .explore
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
            item: self.$modalSelection,
            onDismiss: {
                Task { await self.harvest.loadTimeEntries() }
            }
        ) { selection in
            switch selection {
            case .addTimeEntry:
                NavigationStack {
                    EditTimeEntryView(originalTimeEntry: nil)
                        .environment(self.harvest)
                }
            case .explore:
                NavigationStack {
                    ExploreView().environment(self.harvest)
                }
            case .selectAccount:
                NavigationStack {
                    SelectAccountView().environment(self.harvest)
                }
            }
        }
        .onChange(of: harvest.isAuthorized, initial: true) {
            if harvest.isAuthorized && harvest.userImage == nil {
                Task { await harvest.loadUser() }
            }
            if harvest.isAuthorized {
                Task { await harvest.loadProjectAssignments() }
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

enum ModalSelection: Identifiable {
    case addTimeEntry
    case explore
    case selectAccount

    var id: Self { self }
}

#if DEBUG
    struct MainView_Previews: PreviewProvider {
        static var previews: some View {
            MainView()
                .environment(HarvestState(api: PreviewHarvester()))
        }
    }
#endif
