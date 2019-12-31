import SwiftUI
import Harvester

struct ExploreView : View {
    @EnvironmentObject var harvest: HarvestState

    var body: some View {
        List {
            if harvest.isAuthorized {
                NavigationLink(destination: AccountsView()) {
                    Text("Get Accounts")
                }
            }
        }
        .navigationBarTitle("Explore API")
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
            .environmentObject(HarvestState(api: PreviewHarvester()))
    }
}
