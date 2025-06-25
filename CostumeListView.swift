import SwiftUI

struct CostumeListView: View {
    @EnvironmentObject var inventoryVM: InventoryViewModel
    @State private var showAdd = false
    @State private var galleryMode = false
    @State private var showEditSheet: Costume? = nil

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var filteredCostumes: [Costume] {
        inventoryVM.costumes.sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Title and Add Button row
                    HStack {
                        Text("Inventory")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: { showAdd = true }) {
                            Label("Add Costume", systemImage: "plus")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 28)

                    // List/Gallery Toggle
                    Picker("View", selection: $galleryMode) {
                        Text("List").tag(false)
                        Text("Gallery").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding([.top, .horizontal])

                    if galleryMode {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredCostumes) { costume in
                                    NavigationLink(destination: CostumeDetailView(costume: costume)) {
                                        CostumeGalleryCard(costume: costume)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 24)
                        }
                        .background(Color.white)
                        .transition(.opacity)
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                ForEach(filteredCostumes) { costume in
                                    NavigationLink(destination: CostumeDetailView(costume: costume)) {
                                        CostumeBentoCard(costume: costume)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                            .padding(.top, 16)
                        }
                        .background(Color.white)
                        .transition(.opacity)
                    }
                }
                .sheet(isPresented: $showAdd) {
                    AddCostumeOnboardingView()
                }
                .sheet(item: $showEditSheet) { costume in
                    CostumeEditView(editCostume: costume)
                }
            }
        }
    }
}

// MARK: - Gallery Card View (unchanged)
struct CostumeGalleryCard: View {
    let costume: Costume

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.15))
                    .frame(height: 100)
                if let data = costume.imageDatas.first, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "tshirt.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .foregroundColor(.blue)
                }
            }
            Text(costume.name)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundColor(.primary)
            Text("Location: \(costume.location.name)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("Size: \(costume.size)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("Qty: \(costume.availableQuantity)/\(costume.totalQuantity)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .bold()
            Text(costume.status.rawValue)
                .font(.caption2)
                .foregroundColor(
                    costume.status == .available ? .green :
                    costume.status == .partiallyCheckedOut ? .orange : .red
                )
                .bold()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 2)
    }
}

// MARK: - Bento Card for List View

struct CostumeBentoCard: View {
    let costume: Costume

    var body: some View {
        HStack(spacing: 16) {
            if let data = costume.imageDatas.first, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Image(systemName: "tshirt.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(costume.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Location: \(costume.location.name)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Qty: \(costume.availableQuantity)/\(costume.totalQuantity)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(costume.status.rawValue)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(
                    costume.status == .available ? .green :
                    costume.status == .partiallyCheckedOut ? .orange : .red
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color(.systemGray3).opacity(0.18), radius: 7, x: 0, y: 3)
        )
    }
}


