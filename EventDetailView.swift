import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject var inventoryVM: InventoryViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var event: Event
    @State private var showEditOnboarding = false
    @State private var showDeleteAlert = false

    // Helper to get the latest costume from inventory
    func latestCostume(for assigned: AssignedCostume) -> Costume {
        inventoryVM.costumes.first(where: { $0.id == assigned.costume.id }) ?? assigned.costume
    }

    // Swipeable gallery of all assigned costume images (latest, with rounded corners)
    var assignedPhotos: [(UIImage, String)] {
        event.assignedCostumes.compactMap { assigned in
            let costume = latestCostume(for: assigned)
            guard let data = costume.imageDatas.first, let uiImage = UIImage(data: data) else { return nil }
            return (uiImage, costume.name)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Swipeable gallery with rounded corners
                if !assignedPhotos.isEmpty {
                    ZStack {
                        TabView {
                            ForEach(0..<assignedPhotos.count, id: \.self) { idx in
                                VStack(spacing: 8) {
                                    Image(uiImage: assignedPhotos[idx].0)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                    Text(assignedPhotos[idx].1)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.bottom, 8)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                        .frame(height: 340)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24)) // Ensures rounded corners
                    .padding(.horizontal)
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemGray5))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(systemName: "calendar")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.pink)
                        )
                        .padding(.horizontal)
                }

                // Card-like info panel
                VStack(alignment: .leading, spacing: 20) {
                    // Organizer/department + Edit/Delete
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray)
                            Text(event.organizer)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: { showEditOnboarding = true }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.gray)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        Button(action: { showDeleteAlert = true }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(
                                title: Text("Delete Event?"),
                                message: Text("Are you sure you want to delete this event? This action cannot be undone."),
                                primaryButton: .destructive(Text("Delete")) {
                                    inventoryVM.deleteEvent(event)
                                    presentationMode.wrappedValue.dismiss()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }

                    // Name, status badge, date/time/location
                    VStack(alignment: .leading, spacing: 6) {
                        Text(event.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        HStack {
                            Text("Upcoming")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green.opacity(0.15))
                                )
                                .foregroundColor(.green)
                            Spacer()
                            Text("ID: \(event.id.uuidString.prefix(8))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        HStack(spacing: 16) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                Text(event.date, format: .dateTime.month(.abbreviated).day().year())
                            }
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                Text(event.date, style: .time)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                            Text(event.assignedCostumes.first.flatMap { latestCostume(for: $0).location.name } ?? "—")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color(.systemGray4).opacity(0.2), radius: 8, x: 0, y: 4)

                // Description
                if let notes = event.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text(notes)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }

                // Assigned Costumes (with images)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Assigned Costumes")
                        .font(.headline)
                    if event.assignedCostumes.isEmpty {
                        Text("No costumes assigned.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(event.assignedCostumes) { assigned in
                            let costume = latestCostume(for: assigned)
                            HStack(spacing: 12) {
                                if let data = costume.imageDatas.first, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 36, height: 36)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                VStack(alignment: .leading) {
                                    Text(costume.name)
                                        .fontWeight(.medium)
                                    Text("Qty: \(assigned.quantity)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(event.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditOnboarding) {
            AddEventOnboardingView(editEvent: event)
                .environmentObject(inventoryVM)
        }
    }
}





