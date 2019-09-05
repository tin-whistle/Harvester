import Harvester
import SwiftUI

struct AccountView<T: Harvest> : View {
    let account: HarvestAccount
    @EnvironmentObject var harvest: T
    var body: some View {
        List {
            NavigationLink(destination: UserView<T>()) {
                Text("Get User")
            }
            NavigationLink(destination: ProjectsView<T>()) {
                Text("Get Projects")
            }
            NavigationLink(destination: TimeEntriesView<T>()) {
                Text("Get Time Entries")
            }
            NavigationLink(destination: CompanyView<T>()) {
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
        AccountView<HarvestAPI>(account: HarvestAccount(id: 0, name: "My Account", product: .harvest))
            .environmentObject(PreviewHarvest())
    }
}
#endif
