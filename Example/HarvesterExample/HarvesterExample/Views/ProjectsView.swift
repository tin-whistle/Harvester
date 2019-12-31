import Harvester
import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject var harvest: HarvestState

    var body: some View {
        List {
            ForEach(harvest.projectAssignments, id: \.id) { projectAssignment in
                NavigationLink(destination: TasksView(projectAssignment: projectAssignment)) {
                    Text("\(projectAssignment.client.name) -- \(projectAssignment.project.name)")
                }
            }
        }.onAppear {
            self.harvest.loadProjectAssignments()
        }.navigationBarTitle("Projects")
    }
}

#if DEBUG
struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView()
            .environmentObject(HarvestState(api: PreviewHarvester()))
    }
}
#endif
