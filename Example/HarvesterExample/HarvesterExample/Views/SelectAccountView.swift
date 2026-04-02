import Harvester
import SwiftUI

struct SelectAccountView : View {
    @Environment(HarvestState.self) var harvest

    @Binding var show: Bool

    var body: some View {
        List {
            ForEach(harvest.accounts, id: \.id) { account in
                Button(action: {
                    self.harvest.currentAccountId = account.id
                    self.show = false
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
struct SelectAccountView_Previews : PreviewProvider {
    static var previews: some View {
        SelectAccountView(show: .constant(true))
            .environment(HarvestState(api: PreviewHarvester()))
    }
}
#endif
