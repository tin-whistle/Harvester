import Combine
import Foundation
import Harvester
import SwiftUI

struct UserView: View {
    @EnvironmentObject var harvest: HarvestState

    private var userName: String {
        var components = PersonNameComponents()
        components.givenName = harvest.user?.firstName
        components.familyName = harvest.user?.lastName
        return PersonNameComponentsFormatter().string(from: components)
    }
    
    var body: some View {
        VStack {
            Image(uiImage: harvest.userImage ?? UIImage()).mask(Circle())
            Text("\(userName)")
        }
        .onAppear {
            self.harvest.loadUser()
        }
        .navigationBarTitle("User")
        .animation(.spring())
    }
}

#if DEBUG
struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
            .environmentObject(HarvestState(api: PreviewHarvester()))
    }
}
#endif
