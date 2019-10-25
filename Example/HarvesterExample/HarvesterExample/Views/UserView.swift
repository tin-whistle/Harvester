import Combine
import Foundation
import Harvester
import SwiftUI

struct UserView<T: Harvest>: View {
    @EnvironmentObject var harvest: T
    @State var user: HarvestUser? = nil
    @State var image = UIImage()
    
    private var userName: String {
        var components = PersonNameComponents()
        components.givenName = user?.firstName
        components.familyName = user?.lastName
        return PersonNameComponentsFormatter().string(from: components)
    }
    
    var body: some View {
        VStack {
            Image(uiImage: image).mask(Circle())
            Text("\(userName)")
        }
        .onAppear {
            self.harvest.getMe { result in
                switch result {
                case let .success(user):
                    self.user = user
                    URLSession.shared.dataTask(with: user.avatarURL) { data, response, error in
                        guard let data = data, let image = UIImage(data: data) else { return }
                        self.image = image
                    }.resume()
                case .failure:
                    break
                }
            }
        }
        .navigationBarTitle("User")
        .animation(.spring())
    }
}

#if DEBUG
struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView<PreviewHarvest>()
            .environmentObject(PreviewHarvest())
    }
}
#endif
