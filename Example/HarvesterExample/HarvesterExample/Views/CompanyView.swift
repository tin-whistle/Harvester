import Harvester
import SwiftUI

struct CompanyView: View {
    @EnvironmentObject var harvest: HarvestState
    
    var body: some View {
        VStack {
            Text("\(harvest.company?.name ?? "")")
        }
        .onAppear {
            self.harvest.loadCompany()
        }
        .navigationBarTitle("Company")
        .animation(.spring())
    }
}

#if DEBUG
struct CompanyView_Previews: PreviewProvider {
    static var previews: some View {
        CompanyView()
            .environmentObject(HarvestState(api: PreviewHarvester()))
    }
}
#endif

