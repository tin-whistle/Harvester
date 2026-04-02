import Harvester
import SwiftUI

struct TimeEntriesView : View {
    @Environment(HarvestState.self) var harvest

    var body: some View {
        List {
            if harvest.timeEntries.count > 0 {
                Section(header: HStack {
                    Text("Totals")
                        .font(.headline)
                    Spacer()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(harvest.timeEntryWeeklyAverage.formattedHours())")
                                .font(.headline)
                            Text("Weekly Average")
                                .font(.caption)
                                .lineLimit(20)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        VStack(alignment: .center) {
                            Text("\(harvest.timeEntryTotalHoursInLastSevenDays.formattedHours())")
                                .font(.headline)
                            Text("Last 7 Days")
                                .font(.caption)
                                .lineLimit(20)
                                .multilineTextAlignment(.center)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        VStack(alignment: .trailing) {
                            Text("\(harvest.timeEntryTotalHoursThisWeek.formattedHours())")
                                .font(.headline)
                            Text("This Week")
                                .font(.caption)
                                .lineLimit(20)
                                .multilineTextAlignment(.trailing)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
            ForEach(harvest.timeEntryDates, id: \.timeIntervalSinceReferenceDate) { date in
                Section(header: HStack {
                    Text("\(DateFormatter.harvestDateFormatter.string(from: date))")
                        .font(.headline)
                    Spacer()
                    Text("\((harvest.timeEntryTotalHoursByDate[date] ?? 0).formattedHours())")
                        .font(.headline)
                }) {
                    ForEach(harvest.timeEntriesByDate[date] ?? [], id: \.id) { timeEntry in
                        TimeEntryView(timeEntryId: timeEntry.id)
                    }
                    .onDelete { indexSet in
                        guard let firstValidIndex = indexSet.first(where: { $0 < harvest.timeEntries.count }) else { return }
                        let entryToRemove = harvest.timeEntries[firstValidIndex]
                        harvest.deleteTimeEntry(entryToRemove)
                    }
                }
            }
        }
        .task {
            await harvest.loadTimeEntries()
            while !Task.isCancelled {
                let interval: UInt64 = harvest.timeEntries.contains(where: { $0.isRunning }) ? 10_000_000_000 : 30_000_000_000
                try? await Task.sleep(nanoseconds: interval)
                guard !Task.isCancelled else { break }
                await harvest.loadTimeEntries()
            }
        }
        .navigationTitle("Time Entries")
    }

    private func primaryActionButtonForTimeEntry(_ timeEntry: HarvestTimeEntry) -> some View {
        return Button(action: {
            if timeEntry.isRunning {
                harvest.stopTimeEntry(timeEntry)
            } else {
                harvest.startTimeEntryWith(client: timeEntry.client,
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
    }
}

#if DEBUG
struct TimeEntriesView_Previews : PreviewProvider {
    static var previews: some View {
        TimeEntriesView()
            .environment(HarvestState(api: PreviewHarvester()))
    }
}
#endif
