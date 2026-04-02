import SwiftUI
import Harvester

struct MainView : View {
    @Environment(HarvestState.self) var harvest
    
    @State private var modalSelection = ModalSelection.explore
    @State private var showModal = false
    @State private var showSheet = false

    private var actionSheetButtons: [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        if self.harvest.isAuthorized {
            buttons.append(.default(Text("Sign Out")) {
                self.harvest.deauthorize()
            })
            buttons.append(.default(Text("Select Account")) {
                self.modalSelection = .selectAccount
                self.showModal = true
            })
            buttons.append(.default(Text("Explore API")) {
                self.modalSelection = .explore
                self.showModal = true
            })
        } else {
            buttons.append(.default(Text("Sign In")) {
                Task { await self.harvest.authorize() }
            })
        }
        
        buttons.append(.cancel())
        
        return buttons
    }

    var addButton: some View {
        Button(action: {
            self.modalSelection = .addTimeEntry
            self.showModal = true
        }) {
            Image(systemName: "plus")
                .frame(minWidth: 40, idealWidth: 60, minHeight: 40, alignment: .leading)
        }
    }

    var setupButton: some View {
        Button(action: {
            self.showSheet = true
        }) {
            Text("Setup")
        }
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
            }
        }
        .actionSheet(isPresented: self.$showSheet) {
            ActionSheet(title: Text("Setup"), message: nil, buttons: self.actionSheetButtons)
        }
        .sheet(isPresented: self.$showModal, onDismiss: {
            Task { await self.harvest.loadTimeEntries() }
        }) {
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

#if DEBUG
struct MainView_Previews : PreviewProvider {
    static var previews: some View {
        MainView()
            .environment(HarvestState(api: PreviewHarvester()))
    }
}
#endif
