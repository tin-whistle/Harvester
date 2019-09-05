import Harvester
import SwiftUI

struct CompanyView<T: Harvest>: View {
    @EnvironmentObject var harvest: T
    @State var company: HarvestCompany? = nil
    
    var body: some View {
        VStack {
            Text("\(company?.name ?? "")")
        }
        .onAppear {
            self.harvest.getCompany { result in
                switch result {
                case let .success(company):
                    self.company = company
                case .failure:
                    break
                }
            }
        }
        .navigationBarTitle("Company")
        .animation(.spring())
    }
}

#if DEBUG
struct CompanyView_Previews: PreviewProvider {
    static var previews: some View {
        CompanyView<HarvestAPI>()
            .environmentObject(PreviewHarvest())
    }
}
#endif

