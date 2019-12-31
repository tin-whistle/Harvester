import Harvester
import SwiftUI

struct TimeEntryView: View {
    @EnvironmentObject var harvest: HarvestState

    @State private var showEditModal = false

    let timeEntry: HarvestTimeEntry

    var body: some View {
        ZStack {
            self.primaryActionButtonForTimeEntry(timeEntry)
                .hidden()
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(timeEntry.notes ?? "")
                        .font(.body)
                        .bold()
                        .foregroundColor(timeEntry.isRunning ? .blue : .primary)
                        .lineLimit(10)
                    Text([timeEntry.client.name, timeEntry.project.name, timeEntry.task.name].joined(separator: "\n"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(timeEntry.hours.formattedHours())")
                    .font(.body)
                    .bold()
                    .foregroundColor(timeEntry.isRunning ? .blue : .primary)
            }
            .contextMenu {
                self.primaryActionButtonForTimeEntry(timeEntry)
                Button(action: {
                    self.showEditModal = true
                }) {
                    Image(systemName: "pencil")
                    Text("Edit")
                }
                Button(action: {
                    self.harvest.deleteTimeEntry(self.timeEntry)
                }) {
                    Image(systemName: "trash")
                    Text("Delete")
                }.foregroundColor(.red)
            }
        }
        .sheet(isPresented: self.$showEditModal, onDismiss: {
            self.harvest.loadTimeEntries()
        }) {
            NavigationView {
                EditTimeEntryView(show: self.$showEditModal, originalTimeEntry: self.timeEntry)
                    .environmentObject(self.harvest)
            }
        }
    }

    private func primaryActionButtonForTimeEntry(_ timeEntry: HarvestTimeEntry) -> some View {
        return Button(action: {
            if timeEntry.isRunning {
                self.harvest.stopTimeEntry(timeEntry)
            } else {
                self.harvest.startTimeEntryWith(hours: 0,
                                                notes: timeEntry.notes,
                                                projectId: timeEntry.project.id,
                                                spentDate: Date(),
                                                taskId: timeEntry.task.id)
            }
        }) {
            if timeEntry.isRunning {
                Image(systemName: "xmark")
                Text("Stop")
            } else {
                Image(systemName: "arrow.clockwise")
                Text("Restart")
            }
        }
    }
}

struct TimeEntryView_Previews: PreviewProvider {
    private static let exampleTimeEntry = HarvestTimeEntry(id: 0,
                                                           spentDate: "1984-01-02",
                                                           client: HarvestClient(id: 0,
                                                                                 name: "Client A"),
                                                           project: HarvestProject(id: 0,
                                                                                   name: "Project A",
                                                                                   code: "12345"),
                                                           task: HarvestTask(id: 0,
                                                                             name: "Task A"),
                                                           hours: 1.5,
                                                           notes: "Notes",
                                                           startedTime: nil,
                                                           endedTime: nil,
                                                           isRunning: true)
    static var previews: some View {
        TimeEntryView(timeEntry: exampleTimeEntry)
            .environmentObject(HarvestState(api: PreviewHarvester()))

    }
}
