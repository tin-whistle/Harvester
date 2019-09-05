import SwiftUI
import Harvester
import UIKit

struct MainView<T: Harvest> : View {
    @EnvironmentObject var harvest: T
    
    var body: some View {
        NavigationView {
            List {
                if !harvest.isAuthorized {
                    Button(action: {
                        self.harvest.authorize { _ in }
                    }) {
                        Text("Authorize with Harvest")
                    }
                } else {
                    Button(action: {
                        try? self.harvest.deauthorize()
                    }) {
                        Text("Deauthorize with Harvest")
                    }
                }
                if harvest.isAuthorized {
                    NavigationLink(destination: AccountsView<T>()) {
                        Text("Get Accounts")
                    }
                }
            }.navigationBarTitle("Harvester")
        }
    }
}

#if DEBUG
struct MainView_Previews : PreviewProvider {
    static var previews: some View {
        MainView<HarvestAPI>()
            .environmentObject(PreviewHarvest())
    }
}
#endif
