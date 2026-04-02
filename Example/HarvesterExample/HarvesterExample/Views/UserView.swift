import Foundation
import Harvester
import SwiftUI

struct UserView: View {
    @Environment(HarvestState.self) var harvest

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
        .task {
            await harvest.loadUser()
        }
        .navigationTitle("User")
    }
}

#if DEBUG
    struct UserView_Previews: PreviewProvider {
        static var previews: some View {
            UserView()
                .environment(HarvestState(api: PreviewHarvester()))
        }
    }
#endif
