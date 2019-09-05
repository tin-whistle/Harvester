import Harvester
import SwiftUI

struct TasksView: View {
    let projectAssignment: HarvestProjectAssignment?

    var body: some View {
        List {
            ForEach(projectAssignment?.taskAssignments ?? [], id: \.id) { taskAssignment in
                Text("\(taskAssignment.task.name)")
            }
        }.navigationBarTitle("Tasks")
    }
}

#if DEBUG
struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView(projectAssignment: nil)
    }
}
#endif
