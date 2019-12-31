import Combine
import Harvester
import SwiftUI

struct TimeEntriesView : View {
    @EnvironmentObject var harvest: HarvestState
    @State private var timeSubscription: AnyCancellable?
    @State private var timer = CombineTimer()

    var body: some View {
        List {
            ForEach(harvest.timeEntryDates, id: \.timeIntervalSinceReferenceDate) { date in
                Section(header: HStack {
                    Text("\(DateFormatter.harvestDateFormatter.string(from: date))")
                        .font(.headline)
                    Spacer()
                    Text("\((self.harvest.timeEntryTotalHoursByDate[date] ?? 0).formattedHours())")
                        .font(.headline)
                }) {
                    ForEach(self.harvest.timeEntriesByDate[date] ?? [], id: \.id) { timeEntry in
                        TimeEntryView(timeEntry: timeEntry)
                    }
                    .onDelete { indexSet in
                        guard let firstValidIndex = indexSet.first(where: { $0 < self.harvest.timeEntries.count }) else { return }
                        let entryToRemove = self.harvest.timeEntries[firstValidIndex]
                        self.harvest.deleteTimeEntry(entryToRemove)
                    }
                }
            }
        }
        .onAppear {
            self.harvest.loadTimeEntries()
        }
        .onReceive(timer.publisher) { _ in
            self.harvest.loadTimeEntries()
            self.timer.interval = self.harvest.timeEntries.contains { $0.isRunning } ? 5 : 15
        }
        .navigationBarTitle("Time Entries")
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

#if DEBUG
struct TimeEntriesView_Previews : PreviewProvider {
    static var previews: some View {
        TimeEntriesView()
            .environmentObject(HarvestState(api: PreviewHarvester()))
    }
}
#endif

class CombineTimer {
    private let intervalSubject: CurrentValueSubject<TimeInterval, Never>

    var interval: TimeInterval {
        get {
            intervalSubject.value
        }
        set {
            intervalSubject.send(newValue)
        }
    }

    var publisher: AnyPublisher<Date, Never> {
        intervalSubject
            .map {
                Timer.TimerPublisher(interval: $0, runLoop: .main, mode: .default).autoconnect()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    init(interval: TimeInterval = 5.0) {
        intervalSubject = CurrentValueSubject<TimeInterval, Never>(interval)
    }
}
