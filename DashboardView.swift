import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var inventoryVM: InventoryViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                // Break up complex expressions for compiler performance
                let futureEvents = inventoryVM.events.filter { $0.date >= Date() }
                let sortedEvents = futureEvents.sorted { $0.date < $1.date }
                let nextUpcomingEvent = sortedEvents.first

                VStack(spacing: 20) {
                    // Stat Cards Row
                    HStack(spacing: 16) {
                        BentoCard(color: .blue.opacity(0.85)) {
                            StatCard(
                                title: "Total Costumes",
                                value: "\(inventoryVM.costumes.map { $0.totalQuantity }.reduce(0, +))",
                                icon: "tshirt.fill",
                                color: .white
                            )
                        }
                        BentoCard(color: .orange.opacity(0.85)) {
                            StatCard(
                                title: "Checked Out",
                                value: "\(inventoryVM.costumes.map { $0.totalQuantity - $0.availableQuantity }.reduce(0, +))",
                                icon: "arrow.right.arrow.left.circle.fill",
                                color: .white
                            )
                        }
                    }
                    // Upcoming Event
                    BentoCard(color: .green.opacity(0.85)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Upcoming Event")
                                .font(.headline)
                                .foregroundColor(.white)
                            if let event = nextUpcomingEvent {
                                Text(event.name)
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.white)
                                Text(event.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                if let notes = event.notes, !notes.isEmpty {
                                    Text(notes)
                                        .font(.footnote)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            } else {
                                Text("No upcoming events")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    // Recent Activity
                    BentoCard(color: .purple.opacity(0.85)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recent Activity")
                                .font(.headline)
                                .foregroundColor(.white)
                            if inventoryVM.activities.isEmpty {
                                Text("No recent activity.")
                                    .foregroundColor(.white.opacity(0.8))
                            } else {
                                ForEach(inventoryVM.activities.prefix(2)) { activity in
                                    HStack(spacing: 8) {
                                        ActivityTypeIcon(type: activity.type)
                                        VStack(alignment: .leading) {
                                            Text(activity.description)
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                            Text(activity.date, style: .time)
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}

// MARK: - BentoCard (Reusable Box)
struct BentoCard<Content: View>: View {
    var color: Color
    var content: Content

    init(color: Color, @ViewBuilder content: () -> Content) {
        self.color = color
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
            .background(color)
            .cornerRadius(18)
            .shadow(color: color.opacity(0.25), radius: 6, x: 0, y: 3)
    }
}

// MARK: - StatCard
struct StatCard: View {
    var title: String
    var value: String
    var icon: String
    var color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(color)
                .padding(.trailing, 8)
            VStack(alignment: .leading) {
                Text(value)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            Spacer()
        }
    }
}

// MARK: - ActivityTypeIcon
struct ActivityTypeIcon: View {
    let type: ActivityType

    var body: some View {
        let iconName: String
        let iconColor: Color

        switch type {
        case .costumeAdded: iconName = "plus.circle.fill"; iconColor = .blue
        case .costumeEdited: iconName = "pencil.circle.fill"; iconColor = .yellow
        case .costumeDeleted: iconName = "trash.circle.fill"; iconColor = .red
        case .checkedIn: iconName = "arrow.down.circle.fill"; iconColor = .green
        case .checkedOut: iconName = "arrow.up.circle.fill"; iconColor = .orange
        case .eventAdded: iconName = "calendar.badge.plus"; iconColor = .mint
        case .eventEdited: iconName = "calendar.badge.clock"; iconColor = .purple
        case .eventDeleted: iconName = "calendar.badge.minus"; iconColor = .red
        }

        return Image(systemName: iconName)
            .foregroundColor(iconColor)
            .font(.system(size: 18))
    }
}



