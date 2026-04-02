import Harvester
import SwiftUI

struct CompanyView: View {
    @Environment(HarvestState.self) var harvest

    var body: some View {
        VStack {
            Text("\(harvest.company?.name ?? "")")
        }
        .task {
            await harvest.loadCompany()
        }
        .navigationTitle("Company")
    }
}

#if DEBUG
    struct CompanyView_Previews: PreviewProvider {
        static var previews: some View {
            CompanyView()
                .environment(HarvestState(api: PreviewHarvester()))
        }
    }
#endif
