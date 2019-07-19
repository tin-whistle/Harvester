import Harvester
import SwiftUI

struct AccountView : View {
    let account: HarvestAccount
    let harvest: HarvestAPI
    var body: some View {
        List {
            NavigationLink(destination: UserView(harvest: self.harvest)) {
                Text("Get User")
            }
            Button(action: {
                self.harvest.getMyProjectAssignments { result in
                }
            }) {
                Text("Get User Project Assignments")
            }
            Button(action: {
                self.harvest.getTimeEntries { result in
                }
            }) {
                Text("Get Time Entries")
            }
            Button(action: {
                self.harvest.getCompany { result in
                }
            }) {
                Text("Get Company")
            }
        }
        .navigationBarTitle(account.name)
        .onAppear {
            self.harvest.currentAccount = self.account
        }
    }
}

#if DEBUG
struct AccountView_Previews : PreviewProvider {
    static var previews: some View {
        AccountView(account: HarvestAccount(id: 0, name: "My Account", product: .harvest), harvest: HarvestAPI(oauthProvider: OAuthProviderStub(isAuthorized: false)))
    }
}
#endif
