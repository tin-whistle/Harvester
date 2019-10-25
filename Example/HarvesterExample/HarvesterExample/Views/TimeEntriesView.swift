import Harvester
import SwiftUI

struct TimeEntriesView<T: Harvest> : View {
    @EnvironmentObject var harvest: T
    @State var timeEntries: [HarvestTimeEntry] = []
    
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var body: some View {
        List {
            ForEach(timeEntries, id: \.id) { timeEntry in
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading) {
                        Text(timeEntry.client.name)
                            .font(.caption)
                        Text(timeEntry.project.name)
                            .font(.caption)
                        Text(timeEntry.task.name)
                            .font(.caption)
                        Text(timeEntry.notes ?? "")
                            .bold()
                            .lineLimit(10)
                            .font(.body)
                    }.layoutPriority(1)
                    Spacer()
                    Text("\(self.formatHours(timeEntry.hours))")
                        .font(.body)
                        .bold()
                        .foregroundColor(Color(timeEntry.isRunning ? .systemBlue : .label))
                }
            }
        }.onAppear {
            self.harvest.getTimeEntries { result in
                switch result {
                case let .success(timeEntries):
                    self.timeEntries = timeEntries
                case .failure:
                    break
                }
            }
        }.navigationBarTitle("Time Entries")
    }

    private func formatHours(_ hours: Double) -> String {
        let duration = Measurement(value: hours, unit: UnitDuration.hours)
        let seconds = duration.converted(to: .seconds).value
        var formatted = timeFormatter.string(from: seconds) ?? "?"
        if formatted.hasPrefix("0") { formatted.removeFirst() }
        return formatted
    }
}

#if DEBUG
struct TimeEntriesView_Previews : PreviewProvider {
    static var previews: some View {
        TimeEntriesView<PreviewHarvest>()
            .environmentObject(PreviewHarvest())
    }
}
#endif
