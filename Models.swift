import Foundation

enum CostumeStatus: String, Codable, CaseIterable {
    case available = "Available"
    case partiallyCheckedOut = "Partially Checked Out"
    case checkedOut = "Checked Out"
}

struct Location: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var address: String
}

struct CheckOutInfo: Identifiable, Codable, Hashable {
    var id = UUID()
    var checkedOutBy: String
    var quantity: Int
    var dueDate: Date
    var checkedOutDate: Date
}

struct Costume: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var size: String
    var color: String
    var category: String
    var totalQuantity: Int
    var location: Location
    var status: CostumeStatus
    var notes: String?
    var imageData: Data?
    var checkOuts: [CheckOutInfo] = []
    var imageDatas: [Data] = []
    var availableQuantity: Int {
        totalQuantity - checkOuts.map { $0.quantity }.reduce(0, +)
    }
}


struct Event: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var date: Date
    var organizer: String
    var assignedCostumes: [AssignedCostume] // <-- new
    var notes: String?
}

struct AssignedCostume: Identifiable, Codable, Hashable {
    var id: UUID { costume.id }
    var costume: Costume
    var quantity: Int

}

// --- ACTIVITY LOGGING ---

enum ActivityType: String, Codable {
    case costumeAdded = "Costume Added"
    case costumeEdited = "Costume Edited"
    case costumeDeleted = "Costume Deleted"
    case checkedIn = "Checked In"
    case checkedOut = "Checked Out"
    case eventAdded = "Event Added"
    case eventEdited = "Event Edited"
    case eventDeleted = "Event Deleted"
}

struct Activity: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var description: String
    var type: ActivityType
}



