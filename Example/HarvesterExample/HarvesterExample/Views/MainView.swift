import SwiftUI
import Harvester
import UIKit

struct MainView : View {
    var authorizationParentViewController: UIViewController
    @ObjectBinding var harvest: HarvestAPI
    
    var body: some View {
        NavigationView {
            List {
                if !harvest.isAuthorized {
                    Button(action: {
                        self.harvest.authorizeWithViewController(self.authorizationParentViewController) { _ in }
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
        MainView(authorizationParentViewController: UIViewController(),
                    harvest: HarvestAPI(oauthProvider: OAuthProviderStub(isAuthorized: false)))
    }
}
#endif
