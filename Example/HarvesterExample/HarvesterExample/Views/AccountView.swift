import Harvester
import SwiftUI

struct AccountView : View {
    let account: HarvestAccount
    @EnvironmentObject var harvest: HarvestState
    var body: some View {
        List {
            NavigationLink(destination: UserView()) {
                Text("Get User")
            }
            NavigationLink(destination: ProjectsView()) {
                Text("Get Projects")
            }
            NavigationLink(destination: TimeEntriesView()) {
                Text("Get Time Entries")
            }
            NavigationLink(destination: CompanyView()) {
                Text("Get Company")
            }
        }
        .navigationBarTitle(account.name)
        .onAppear {
            self.harvest.currentAccountId = self.account.id
        }
    }
}

#if DEBUG
struct AccountView_Previews : PreviewProvider {
    static var previews: some View {
        let view = AccountView(account: HarvestAccount(id: 0, name: "My Account", product: .harvest))
            .environmentObject(HarvestState(api: PreviewHarvester()))
        return view
    }
}
#endif
