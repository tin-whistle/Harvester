import Harvester
import SwiftUI

struct SelectAccountView: View {
    @Environment(HarvestState.self) var harvest

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(harvest.accounts, id: \.id) { account in
                Button(action: {
                    self.harvest.currentAccountId = account.id
                    self.dismiss()
                }) {
                    Text(account.name)
                }
            }
        }
        .task {
            await self.harvest.loadAccounts()
        }
        .navigationTitle("Select Account")
    }
}

#if DEBUG
    struct SelectAccountView_Previews: PreviewProvider {
        static var previews: some View {
            SelectAccountView()
                .environment(HarvestState(api: PreviewHarvester()))
        }
    }
#endif
