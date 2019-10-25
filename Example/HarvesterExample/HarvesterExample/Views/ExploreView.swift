import SwiftUI
import Harvester

struct ExploreView<T: Harvest> : View {
    @EnvironmentObject var harvest: T

    var body: some View {
        List {
            if harvest.isAuthorized {
                NavigationLink(destination: AccountsView<T>()) {
                    Text("Get Accounts")
                }
            }
        }
        .navigationBarTitle("Explore API")
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView<PreviewHarvest>()
            .environmentObject(PreviewHarvest())
    }
}
