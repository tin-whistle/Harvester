import Harvester
import SwiftUI

struct AccountsView : View {
    @EnvironmentObject var harvest: HarvestState

    var body: some View {
        List {
            ForEach(harvest.accounts, id: \.id) { account in
                NavigationLink(destination: AccountView(account: account)) {
                    Text(account.name)
                }
            }
        }.onAppear {
            self.harvest.loadAccounts()
        }.navigationBarTitle("Accounts")
    }
}

#if DEBUG
struct AccountsView_Previews : PreviewProvider {
    static var previews: some View {
        AccountsView()
            .environmentObject(HarvestState(api: PreviewHarvester()))
    }
}
#endif
