import Harvester
import SwiftUI

struct ProjectsView<T: Harvest>: View {
    @EnvironmentObject var harvest: T
    @State var projectAssignments: [HarvestProjectAssignment] = []

    var body: some View {
        List {
            ForEach(projectAssignments, id: \.id) { projectAssignment in
                NavigationLink(destination: TasksView(projectAssignment: projectAssignment)) {
                    Text("\(projectAssignment.client.name) -- \(projectAssignment.project.name)")
                }
            }
        }.onAppear {
            self.harvest.getProjectAssignments { result in
                switch result {
                case let .success(projectAssignments):
                    self.projectAssignments = projectAssignments
                case .failure:
                    break
                }
            }
        }.navigationBarTitle("Projects")
    }
}

#if DEBUG
struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView<PreviewHarvest>()
            .environmentObject(PreviewHarvest())
    }
}
#endif
