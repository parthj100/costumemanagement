import Foundation
import Combine

class InventoryViewModel: ObservableObject {
    @Published var costumes: [Costume] = []
    @Published var events: [Event] = []
    @Published var locations: [Location] = [
        Location(name: "Main Storage", address: "123 Main St"),
        Location(name: "Theater Closet", address: "Backstage")
    ]
    @Published var activities: [Activity] = []

    // MARK: - Costume CRUD
    func addCostume(_ costume: Costume) {
        costumes.append(costume)
        logActivity(description: "Added costume \"\(costume.name)\"", type: .costumeAdded)
    }

    func updateCostume(_ costume: Costume) {
        guard let idx = costumes.firstIndex(where: { $0.id == costume.id }) else { return }
        costumes[idx] = costume
        logActivity(description: "Edited costume \"\(costume.name)\"", type: .costumeEdited)
    }

    func deleteCostume(_ costume: Costume) {
        costumes.removeAll { $0.id == costume.id }
        logActivity(description: "Deleted costume \"\(costume.name)\"", type: .costumeDeleted)
    }

    // MARK: - Location CRUD
    func addLocation(_ location: Location) {
        locations.append(location)
    }

    func deleteLocation(_ location: Location) {
        locations.removeAll { $0.id == location.id }
    }

    // MARK: - Event CRUD
    func addEvent(_ event: Event) {
        events.append(event)
        logActivity(description: "Added event \"\(event.name)\"", type: .eventAdded)
    }

    func updateEvent(_ event: Event) {
        guard let idx = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[idx] = event
        logActivity(description: "Edited event \"\(event.name)\"", type: .eventEdited)
    }

    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
        logActivity(description: "Deleted event \"\(event.name)\"", type: .eventDeleted)
    }

    // MARK: - Check Out
    func checkOutCostume(_ costume: Costume, checkedOutBy: String, quantity: Int, dueDate: Date) {
            guard let idx = costumes.firstIndex(where: { $0.id == costume.id }) else { return }
            var c = costumes[idx]
            let checkOut = CheckOutInfo(
                checkedOutBy: checkedOutBy,
                quantity: quantity,
                dueDate: dueDate,
                checkedOutDate: Date()
            )
            c.checkOuts.append(checkOut)
            // Update status
            let available = c.availableQuantity
            if available == 0 {
                c.status = .checkedOut
            } else if available < c.totalQuantity {
                c.status = .partiallyCheckedOut
            } else {
                c.status = .available
            }
            costumes[idx] = c
            logActivity(
                description: "Checked out \(quantity) of \"\(costume.name)\" to \(checkedOutBy), due \(dueDate.formatted(date: .abbreviated, time: .omitted))",
                type: .checkedOut
            )
        }

        func checkInCostume(_ costume: Costume, checkOutID: UUID, quantity: Int) {
            guard let idx = costumes.firstIndex(where: { $0.id == costume.id }) else { return }
            var c = costumes[idx]
            if let coIdx = c.checkOuts.firstIndex(where: { $0.id == checkOutID }) {
                var co = c.checkOuts[coIdx]
                co.quantity -= quantity
                if co.quantity <= 0 {
                    c.checkOuts.remove(at: coIdx)
                } else {
                    c.checkOuts[coIdx] = co
                }
                // Update status
                let available = c.availableQuantity
                if available == 0 {
                    c.status = .checkedOut
                } else if available < c.totalQuantity {
                    c.status = .partiallyCheckedOut
                } else {
                    c.status = .available
                }
                costumes[idx] = c
                logActivity(
                    description: "Checked in \(quantity) of \"\(costume.name)\"",
                    type: .checkedIn
                )
            }
        }

    // MARK: - Activity Log
    private func logActivity(description: String, type: ActivityType) {
        let activity = Activity(date: Date(), description: description, type: type)
        activities.insert(activity, at: 0)
        if activities.count > 20 {
            activities.removeLast()
        }
    }
}

extension InventoryViewModel {
    func assignedEvents(for costume: Costume) -> [Event] {
        events.filter { event in
            event.assignedCostumes.contains { $0.costume.id == costume.id }
        }
    }
}

extension InventoryViewModel {
    func assignedEvents(for costumeID: UUID) -> [Event] {
        events.filter { event in
            event.assignedCostumes.contains { $0.costume.id == costumeID }
        }
    }
}





