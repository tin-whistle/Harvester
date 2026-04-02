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

    var body: some View {
        NavigationView {
            Passthrough {
                if self.harvest.currentAccountId == nil {
                    List {
                        Text("No Account Selected")
                    }
                } else {
                    TimeEntriesView()
                }
            }
            .navigationBarTitle("Harvester")
            .navigationBarItems(leading: harvest.isAuthorized ? addButton : nil, trailing: setupButton)
        }
        .actionSheet(isPresented: self.$showSheet) {
            ActionSheet(title: Text("Setup"), message: nil, buttons: self.actionSheetButtons)
        }
        .sheet(isPresented: self.$showModal, onDismiss: {
            Task { await self.harvest.loadTimeEntries() }
        }) {
            if self.modalSelection == .addTimeEntry {
                NavigationView {
                    EditTimeEntryView(show: self.$showModal, originalTimeEntry: nil)
                        .environment(self.harvest)
                }
            } else if self.modalSelection == .explore {
                NavigationView {
                    ExploreView().environment(self.harvest)
                }
            } else {
                NavigationView {
                    SelectAccountView(show: self.$showModal).environment(self.harvest)
                }
            }
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
