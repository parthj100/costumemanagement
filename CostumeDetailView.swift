import SwiftUI

struct CostumeDetailView: View {
    @EnvironmentObject var inventoryVM: InventoryViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var costume: Costume
    @State private var showEdit = false
    @State private var showCheckOutSheet = false
    @State private var showCheckInSheet: CheckOutInfo? = nil
    @State private var showImageFullscreen = false
    @State private var showDeleteAlert = false
    @State private var selectedEvent: Event? = nil

    var assignedEvents: [Event] {
        inventoryVM.assignedEvents(for: costume.id)
    }

    var costumeImages: [UIImage] {
        costume.imageDatas.compactMap { UIImage(data: $0) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Swipeable gallery of images with rounded corners
                if !costumeImages.isEmpty {
                    TabView {
                        ForEach(0..<costumeImages.count, id: \.self) { idx in
                            Image(uiImage: costumeImages[idx])
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .clipped()
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 340)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal)
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemGray5))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(systemName: "tshirt.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.blue)
                        )
                        .padding(.horizontal)
                }

                // Card-like info panel
                VStack(alignment: .leading, spacing: 20) {
                    // Department/User + Edit/Delete
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray)
                            Text("Costume Department")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: { showEdit = true }) {
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
                                title: Text("Delete Costume?"),
                                message: Text("Are you sure you want to delete this costume? This action cannot be undone."),
                                primaryButton: .destructive(Text("Delete")) {
                                    inventoryVM.deleteCostume(costume)
                                    presentationMode.wrappedValue.dismiss()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }

                    // Name, Status Badge, ID
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(costume.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Text(costume.status.rawValue)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            costume.status == .available ? Color.green.opacity(0.15) :
                                            costume.status == .partiallyCheckedOut ? Color.orange.opacity(0.15) :
                                            Color.red.opacity(0.15)
                                        )
                                )
                                .foregroundColor(
                                    costume.status == .available ? .green :
                                    costume.status == .partiallyCheckedOut ? .orange : .red
                                )
                        }
                        Text("ID: \(costume.id.uuidString.prefix(8))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Location
                    HStack {
                        Text("Location")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(costume.location.name)
                            .font(.subheadline)
                    }

                    // Quantity
                    HStack {
                        Text("Available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(costume.availableQuantity)/\(costume.totalQuantity)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    // Action Buttons (Check Out and Edit side by side)
                    HStack(spacing: 12) {
                        Button(action: { showCheckOutSheet = true }) {
                            Text("Check Out")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(costume.status == .checkedOut || costume.availableQuantity == 0)
                        .sheet(isPresented: $showCheckOutSheet) {
                            CheckOutSheet(
                                costume: costume,
                                onCheckOut: { checkedOutBy, quantity, dueDate in
                                    inventoryVM.checkOutCostume(costume, checkedOutBy: checkedOutBy, quantity: quantity, dueDate: dueDate)
                                    if let updated = inventoryVM.costumes.first(where: { $0.id == costume.id }) {
                                        self.costume = updated
                                    }
                                }
                            )
                        }

                        Button(action: { showEdit = true }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Costume")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .sheet(isPresented: $showEdit) {
                            CostumeEditView(editCostume: costume)
                                .environmentObject(inventoryVM)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color(.systemGray4).opacity(0.2), radius: 8, x: 0, y: 4)

                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    Text(costume.notes ?? "—")
                        .font(.body)
                        .foregroundColor(.primary)
                }

                // Assigned Events (modern style)
                if !assignedEvents.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Assigned to Events")
                            .font(.headline)
                        ForEach(assignedEvents) { event in
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.secondary)
                                Text(event.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                Spacer()
                                if let assigned = event.assignedCostumes.first(where: { $0.costume.id == costume.id }) {
                                    Text("x\(assigned.quantity)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .imageScale(.small)
                                    .padding(.leading, 4)
                            }
                            .padding(.vertical, 2)
                            .contentShape(Rectangle())
                        }
                    }
                }

                // Check-out records (show who/when) and check-in functionality
                if !costume.checkOuts.isEmpty {
                    Divider()
                    Text("Checked Out Records")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    ForEach(costume.checkOuts) { info in
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text(info.checkedOutBy)
                            }
                            HStack {
                                Image(systemName: "number")
                                Text("Qty: \(info.quantity)")
                            }
                            HStack {
                                Image(systemName: "calendar")
                                Text("Due: \(info.dueDate, style: .date)")
                            }
                            HStack {
                                Image(systemName: "clock")
                                Text("Checked Out: \(info.checkedOutDate, style: .date)")
                            }
                            // Check In Button with confirmation
                            Button(action: { showCheckInSheet = info }) {
                                HStack {
                                    Image(systemName: "arrow.down.doc")
                                    Text("Check In")
                                }
                                .font(.caption)
                                .padding(6)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .padding(.top, 4)
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(costume.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $showCheckInSheet) { info in
            CheckInSheet(
                costume: costume,
                checkOutInfo: info,
                onCheckIn: { qty in
                    inventoryVM.checkInCostume(costume, checkOutID: info.id, quantity: qty)
                    if let updated = inventoryVM.costumes.first(where: { $0.id == costume.id }) {
                        self.costume = updated
                    }
                }
            )
        }
    }
}

















