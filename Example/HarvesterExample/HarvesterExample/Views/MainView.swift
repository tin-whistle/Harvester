import SwiftUI
import Harvester
import UIKit

struct MainView : View {
    @ObjectBinding var harvest: HarvestAPI
    
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
                    NavigationLink(destination: AccountsView(harvest: harvest)) {
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
        MainView(harvest: HarvestAPI(configuration: HarvestAPIConfiguration(appName: "Harvester Example", contactEmail: "harvester@tinwhistlellc.com", oauthProvider: OAuthProviderStub(isAuthorized: false))))
    }
}
#endif
