import Harvester
import SwiftUI

struct TimeEntryView: View {

    @State private var showEditModal = false

    @StateObject var model: TimeEntryModel

    var body: some View {
        if let timeEntry = model.timeEntry {
            ZStack {
                Menu {
                    if !timeEntry.isDirty {
                        Button(action: {
                            if timeEntry.isRunning {
                                model.harvest.stopTimeEntry(timeEntry)
                            } else {
                                model.harvest.startTimeEntryWith(client: timeEntry.client,
                                                                 hours: 0,
                                                                 notes: timeEntry.notes,
                                                                 project: timeEntry.project,
                                                                 spentDate: Date(),
                                                                 task: timeEntry.task)
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
                        Button(action: {
                            self.showEditModal = true
                        }) {
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                        Button(action: {
                            model.harvest.deleteTimeEntry(timeEntry)
                        }) {
                            Image(systemName: "trash")
                            Text("Delete")
                        }.foregroundColor(.red)
                    }
                } label: {
                    HStack(alignment: .firstTextBaseline) {
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
                        if timeEntry.isDirty {
                            Image(systemName: "arrow.2.circlepath")
                                .foregroundColor(.red)
                        }
                        Text("\(timeEntry.hours.formattedHours())")
                            .font(.body)
                            .bold()
                            .foregroundColor(timeEntry.isRunning ? .blue : .primary)
                    }
                    .multilineTextAlignment(.leading)
                }
            }
            .sheet(isPresented: $showEditModal, onDismiss: {
                model.harvest.loadTimeEntries()
            }) {
                NavigationView {
                    EditTimeEntryView(show: $showEditModal, originalTimeEntry: model.timeEntry)
                        .environmentObject(model.harvest)
                }
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
        TimeEntryView(
            model: TimeEntryModel(harvest: HarvestState(api: PreviewHarvester()), timeEntryId: 0)
        )
    }
}
