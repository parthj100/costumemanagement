import SwiftUI

struct CostumeEditView: View {
    @EnvironmentObject var inventoryVM: InventoryViewModel
    @Environment(\.presentationMode) var presentationMode

    var editCostume: Costume

    @State private var name: String
    @State private var size: String
    @State private var color: String
    @State private var category: String
    @State private var totalQuantity: Int
    @State private var selectedLocationID: UUID
    @State private var notes: String
    @State private var images: [UIImage] = []
    @State private var showImagePicker = false

    let sizeOptions = ["XS", "S", "M", "L", "XL", "Custom"]
    let colorOptions = ["Red", "Blue", "Green", "Black", "White", "Other"]
    let categoryOptions = ["Dance", "Drama", "Prop", "Accessory"]

    init(editCostume: Costume) {
        self.editCostume = editCostume
        _name = State(initialValue: editCostume.name)
        _size = State(initialValue: editCostume.size)
        _color = State(initialValue: editCostume.color)
        _category = State(initialValue: editCostume.category)
        _totalQuantity = State(initialValue: editCostume.totalQuantity)
        _selectedLocationID = State(initialValue: editCostume.location.id)
        _notes = State(initialValue: editCostume.notes ?? "")
        // Pre-fill images from imageDatas
        _images = State(initialValue: editCostume.imageDatas.compactMap { UIImage(data: $0) })
    }

    var body: some View {
        NavigationView {
            Form {
                // Photo picker section
                Section(header: Text("Photos")) {
                    if !images.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<images.count, id: \.self) { idx in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: images[idx])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        Button(action: { images.remove(at: idx) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .offset(x: 8, y: -8)
                                        }
                                    }
                                }
                            }
                        }
                        Button("Add/Change Photos") { showImagePicker = true }
                    } else {
                        Button(action: { showImagePicker = true }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("Choose Photos")
                            }
                        }
                    }
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePickerGallery(images: $images)
                }

                Section(header: Text("Costume Info")) {
                    TextField("Name", text: $name)
                    Picker("Size", selection: $size) {
                        ForEach(sizeOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    Picker("Color", selection: $color) {
                        ForEach(colorOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    Picker("Category", selection: $category) {
                        ForEach(categoryOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    Stepper("Total Quantity: \(totalQuantity)", value: $totalQuantity, in: 1...100)
                    Text("Available: \(editCostume.availableQuantity) / \(totalQuantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("Location", selection: $selectedLocationID) {
                        ForEach(inventoryVM.locations) { loc in
                            Text(loc.name).tag(loc.id)
                        }
                    }
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle("Edit Costume")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") {
                    guard let location = inventoryVM.locations.first(where: { $0.id == selectedLocationID }) else { return }
                    let updatedCostume = Costume(
                        id: editCostume.id,
                        name: name,
                        size: size,
                        color: color,
                        category: category,
                        totalQuantity: totalQuantity,
                        location: location,
                        status: editCostume.status,
                        notes: notes.isEmpty ? nil : notes,
                        checkOuts: editCostume.checkOuts, imageDatas: images.isEmpty
                        ? editCostume.imageDatas
                        : images.map { $0.jpegData(compressionQuality: 0.8) ?? Data() } // preserve current check-outs!
                    )
                    inventoryVM.updateCostume(updatedCostume)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(name.isEmpty || size.isEmpty || color.isEmpty || category.isEmpty)
            )
        }
    }
}







