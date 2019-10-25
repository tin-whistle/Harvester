import Harvester
import SwiftUI

struct SelectAccountView<T: Harvest> : View {
    @EnvironmentObject var harvest: T
    @State var accounts: [HarvestAccount] = []
    
    var body: some View {
        List {
            ForEach(accounts, id: \.id) { account in
                Button(action: {
                    self.harvest.currentAccountId = account.id
                }) {
                    Text(account.name)
                }
            }
        }
        .onAppear {
            self.harvest.getAccounts { result in
                switch result {
                case let .success(accounts):
                    self.accounts = accounts
                case .failure:
                    break
                }
            }
        }
        .navigationBarTitle("Select Account")
    }
}

#if DEBUG
struct SelectAccountView_Previews : PreviewProvider {
    static var previews: some View {
        SelectAccountView<PreviewHarvest>()
            .environmentObject(PreviewHarvest())
    }
}
#endif
