import SwiftUI

struct EventListView: View {
    @EnvironmentObject var inventoryVM: InventoryViewModel
    @State private var showAddEvent = false

    var filteredEvents: [Event] {
        inventoryVM.events.sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Title and New Event Button row
                HStack {
                    Text("Events")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: { showAddEvent = true }) {
                        Label("New Event", systemImage: "plus")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)

                // List of events
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(filteredEvents) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                EventCardView(event: event)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        Spacer(minLength: 20)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddEvent) {
                AddEventOnboardingView()
            }
        }
    }
}

struct EventCardView: View {
    let event: Event

    var statusColor: Color {
        if event.assignedCostumes.isEmpty {
            return .gray
        } else if event.assignedCostumes.allSatisfy({ $0.costume.status == .available }) {
            return .green
        } else if event.assignedCostumes.contains(where: { $0.costume.status == .checkedOut }) {
            return .red
        } else {
            return .yellow
        }
    }

    var eventStatusText: String {
        if event.assignedCostumes.isEmpty {
            return "No Costumes"
        } else if event.assignedCostumes.allSatisfy({ $0.costume.status == .available }) {
            return "Ready"
        } else if event.assignedCostumes.contains(where: { $0.costume.status == .checkedOut }) {
            let missing = event.assignedCostumes.filter { $0.costume.status == .checkedOut }
                .map { $0.quantity }.reduce(0, +)
            return "\(missing) Costumes Missing"
        } else {
            let needed = event.assignedCostumes.map { $0.quantity }.reduce(0, +)
            return "\(needed) Costumes Needed"
        }
    }

    var body: some View {
        ZStack {
            // Full colored border
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(statusColor, lineWidth: 4)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white)
                )
                .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(event.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text(event.date, format: .dateTime.month(.abbreviated).day().year())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(.secondary)
                        Text(event.organizer)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text(event.date, style: .time)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Text(eventStatusText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, minHeight: 96)
        .padding(.vertical, 4)
    }
}






