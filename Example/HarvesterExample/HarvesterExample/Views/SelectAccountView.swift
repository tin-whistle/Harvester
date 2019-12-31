import Harvester
import SwiftUI

struct SelectAccountView : View {
    @EnvironmentObject var harvest: HarvestState

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
        .onAppear {
            self.harvest.loadAccounts()
        }
        .navigationBarTitle("Select Account")
    }
}

#if DEBUG
struct SelectAccountView_Previews : PreviewProvider {
    static var previews: some View {
        SelectAccountView(show: .constant(true))
            .environmentObject(HarvestState(api: PreviewHarvester()))
    }
}
#endif
