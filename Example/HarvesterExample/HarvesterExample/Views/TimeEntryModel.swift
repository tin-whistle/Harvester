import Combine
import Foundation
import Harvester

@MainActor
class TimeEntryModel: ObservableObject {

    var harvest: HarvestState

    var timeEntry: HarvestTimeEntry? {
        harvest.timeEntryById(timeEntryId)
    }

    // MARK: Private Properties

    private var subscriptions = Set<AnyCancellable>()

    private let timeEntryId: Int

    init(harvest: HarvestState, timeEntryId: Int) {
        self.harvest = harvest
        self.timeEntryId = timeEntryId
        harvest.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &subscriptions)
    }
}
