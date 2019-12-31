import SwiftUI
import Harvester

struct MainView : View {
    @EnvironmentObject var harvest: HarvestState
    
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
                self.harvest.authorize()
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
            self.harvest.loadTimeEntries()
        }) {
            if self.modalSelection == .addTimeEntry {
                NavigationView {
                    EditTimeEntryView(show: self.$showModal, originalTimeEntry: nil)
                        .environmentObject(self.harvest)
                }
            } else if self.modalSelection == .explore {
                NavigationView {
                    ExploreView().environmentObject(self.harvest)
                }
            } else {
                NavigationView {
                    SelectAccountView(show: self.$showModal).environmentObject(self.harvest)
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
            .environmentObject(HarvestState(api: PreviewHarvester()))
    }
}
#endif
