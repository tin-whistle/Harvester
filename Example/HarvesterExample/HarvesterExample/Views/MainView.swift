import SwiftUI
import Harvester

struct MainView<T: Harvest> : View {
    @EnvironmentObject var harvest: T
    
    @State private var modalSelection = ModalSelection.explore
    @State private var showModal = false
    @State private var showSheet = false
    
    var actionSheetButtons: [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        if self.harvest.isAuthorized {
            buttons.append(.default(Text("Sign Out")) {
                try? self.harvest.deauthorize()
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
                self.harvest.authorize { _ in }
            })
        }
        
        buttons.append(.cancel())
        
        return buttons
    }
    
    var navigationBarButton: some View {
        Button(action: {
            self.showSheet = true
        }) {
            Text("Setup")
        }
    }
    
    var body: some View {
        NavigationView {
            if harvest.currentAccountId == nil {
                List {
                    Text("No Account Selected")
                }
                .navigationBarTitle("Harvester")
                .navigationBarItems(trailing: navigationBarButton)
            } else {
                TimeEntriesView<T>()
                    .navigationBarTitle("Harvester")
                    .navigationBarItems(trailing: navigationBarButton)
            }
        }
        .actionSheet(isPresented: self.$showSheet) {
            ActionSheet(title: Text("Setup"), message: nil, buttons: self.actionSheetButtons)
        }
        .sheet(isPresented: self.$showModal) {
            if self.modalSelection == .explore {
                NavigationView {
                    ExploreView<T>().environmentObject(self.harvest)
                }
            } else {
                NavigationView {
                    SelectAccountView<T>().environmentObject(self.harvest)
                }
            }
        }
    }
}

enum ModalSelection {
    case explore
    case selectAccount
}

#if DEBUG
struct MainView_Previews : PreviewProvider {
    static var previews: some View {
        MainView<PreviewHarvest>()
            .environmentObject(PreviewHarvest())
    }
}
#endif
