import Harvester
import SwiftUI

struct AccountsView : View {
    let harvest: HarvestAPI
    @State var accounts: [HarvestAccount] = []
    
    var body: some View {
        List {
            ForEach(accounts, id: \.id) { account in
                NavigationLink(destination: AccountView(account: account, harvest: self.harvest)) {
                    Text(account.name)
                }
            }
        }.onAppear {
            self.harvest.getAccounts { result in
                switch result {
                case let .success(accounts):
                    self.accounts = accounts
                case .failure:
                    break
                }
            }
        }.navigationBarTitle("Accounts")
    }
}

#if DEBUG
struct AccountsView_Previews : PreviewProvider {
    static var previews: some View {
        AccountsView(harvest: HarvestAPI(oauthProvider: OAuthProviderStub(isAuthorized: false)))
    }
}
#endif
