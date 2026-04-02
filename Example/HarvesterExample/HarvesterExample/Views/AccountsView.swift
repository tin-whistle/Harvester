import Harvester
import SwiftUI

struct AccountsView : View {
    @Environment(HarvestState.self) var harvest

    var body: some View {
        List {
            ForEach(harvest.accounts, id: \.id) { account in
                NavigationLink(destination: AccountView(account: account)) {
                    Text(account.name)
                }
            }
        }.task {
            await harvest.loadAccounts()
        }.navigationTitle("Accounts")
    }
}

#if DEBUG
struct AccountsView_Previews : PreviewProvider {
    static var previews: some View {
        AccountsView()
            .environment(HarvestState(api: PreviewHarvester()))
    }
}
#endif
