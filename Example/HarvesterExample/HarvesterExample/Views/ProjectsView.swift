import Harvester
import SwiftUI

struct ProjectsView: View {
    @Environment(HarvestState.self) var harvest

    var body: some View {
        List {
            ForEach(harvest.projectAssignments, id: \.id) { projectAssignment in
                NavigationLink(destination: TasksView(projectAssignment: projectAssignment)) {
                    Text("\(projectAssignment.client.name) -- \(projectAssignment.project.name)")
                }
            }
        }.task {
            await harvest.loadProjectAssignments()
        }.navigationTitle("Projects")
    }
}

#if DEBUG
    struct ProjectsView_Previews: PreviewProvider {
        static var previews: some View {
            ProjectsView()
                .environment(HarvestState(api: PreviewHarvester()))
        }
    }
#endif
