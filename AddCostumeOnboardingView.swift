import SwiftUI

// MARK: - ButtonGridPicker (Reusable)
struct ButtonGridPicker<T: Hashable & CustomStringConvertible>: View {
    let options: [T]
    @Binding var selection: T
    let columns: Int

    var body: some View {
        let gridItems = Array(repeating: GridItem(.flexible(), spacing: 16), count: columns)
        LazyVGrid(columns: gridItems, spacing: 16) {
            ForEach(options, id: \.self) { option in
                Button(action: { selection = option }) {
                    Text(option.description)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(selection == option ? Color.blue.opacity(0.12) : Color(.systemGray6))
                        .foregroundColor(selection == option ? .blue : .primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selection == option ? Color.blue : Color(.systemGray4), lineWidth: 2)
                        )
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 12)
    }
}

extension Int: CustomStringConvertible {
    public var description: String { String(self) }
}
extension Location: CustomStringConvertible {
    public var description: String { name }
}

struct AddCostumeOnboardingView: View {
    @EnvironmentObject var inventoryVM: InventoryViewModel
    @Environment(\.presentationMode) var presentationMode

    enum Step: Int, CaseIterable {
        case name, size, color, category, totalQuantity, location, image, notes, confirm
    }

    @State private var step: Step = .name
    @State private var name = ""
    @State private var size = "M"
    @State private var color = "Black"
    @State private var category = "Dance"
    @State private var totalQuantity = 1
    @State private var selectedLocationIndex = 0
    @State private var images: [UIImage] = []
    @State private var showImagePicker = false
    @State private var notes = ""

    let sizeOptions = ["XS", "S", "M", "L", "XL", "Custom"]
    let colorOptions = ["Red", "Blue", "Green", "Black", "White", "Other"]
    let categoryOptions = ["Dance", "Drama", "Prop", "Accessory"]
    let quantityOptions = Array(1...16)
    let accent = Color.blue

    let cardWidth: CGFloat = 420
    let cardHeight: CGFloat = 540

    var locationOptions: [Location] { inventoryVM.locations }
    var selectedLocation: Location? {
        locationOptions.indices.contains(selectedLocationIndex) ? locationOptions[selectedLocationIndex] : nil
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack {
                Spacer(minLength: 0)
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Label("Add Costume", systemImage: "tshirt")
                            .font(.title2.bold())
                            .foregroundColor(accent)
                        Spacer()
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 28)
                    .padding(.horizontal, 28)

                    // Progress bar and step
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.systemGray5))
                                .frame(height: 6)
                            Capsule()
                                .fill(accent)
                                .frame(
                                    width: (cardWidth - 56) *
                                        CGFloat(step.rawValue + 1) / CGFloat(Step.allCases.count),
                                    height: 6
                                )
                                .animation(.easeInOut, value: step)
                        }
                        HStack {
                            Spacer()
                            Text("Step \(step.rawValue + 1) of \(Step.allCases.count)")
                                .font(.caption)
                                .foregroundColor(accent)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 28)

                    // Step content with fade animation
                    Group {
                        switch step {
                        case .name:
                            VStack(alignment: .leading, spacing: 24) {
                                OnboardingStepTitle(
                                    title: "Costume Details",
                                    subtitle: "Let's start with the name of your costume"
                                )
                                FloatingLabelTextField(
                                    label: "Costume Name",
                                    placeholder: "e.g. Pirate Outfit",
                                    text: $name
                                )
                            }
                            .padding(.top, 24)

                        case .size:
                            VStack(alignment: .leading, spacing: 24) {
                                OnboardingStepTitle(
                                    title: "Size",
                                    subtitle: "What size is this costume?"
                                )
                                ButtonGridPicker(
                                    options: sizeOptions,
                                    selection: $size,
                                    columns: 3
                                )
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(.top, 24)

                        case .color:
                            VStack(alignment: .leading, spacing: 24) {
                                OnboardingStepTitle(
                                    title: "Color",
                                    subtitle: "What color is this costume?"
                                )
                                ButtonGridPicker(
                                    options: colorOptions,
                                    selection: $color,
                                    columns: 3
                                )
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(.top, 24)

                        case .category:
                            VStack(alignment: .leading, spacing: 24) {
                                OnboardingStepTitle(
                                    title: "Category",
                                    subtitle: "Select the category for this costume"
                                )
                                ButtonGridPicker(
                                    options: categoryOptions,
                                    selection: $category,
                                    columns: 2
                                )
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(.top, 24)

                        case .totalQuantity:
                            VStack(alignment: .leading, spacing: 24) {
                                OnboardingStepTitle(
                                    title: "Quantity",
                                    subtitle: "How many of this costume do you have?"
                                )
                                ButtonGridPicker(
                                    options: quantityOptions,
                                    selection: $totalQuantity,
                                    columns: 4
                                )
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(.top, 24)

                        case .location:
                            VStack(alignment: .leading, spacing: 24) {
                                OnboardingStepTitle(
                                    title: "Location",
                                    subtitle: "Where is this costume stored?"
                                )
                                ButtonGridPicker(
                                    options: locationOptions,
                                    selection: Binding(
                                        get: { locationOptions[selectedLocationIndex] },
                                        set: { newValue in
                                            if let idx = locationOptions.firstIndex(where: { $0.id == newValue.id }) {
                                                selectedLocationIndex = idx
                                            }
                                        }
                                    ),
                                    columns: 2
                                )
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(.top, 24)

                        case .image:
                            VStack(alignment: .leading, spacing: 24) {
                                OnboardingStepTitle(
                                    title: "Photos",
                                    subtitle: "Add photos of this costume (optional)"
                                )
                                if !images.isEmpty {
                                    TabView {
                                        ForEach(0..<images.count, id: \.self) { idx in
                                            Image(uiImage: images[idx])
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 220, height: 220)
                                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                        }
                                    }
                                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                                    .frame(height: 240)
                                    .padding(.bottom, 8)
                                    Button("Add/Change Photos") { showImagePicker = true }
                                    Button("Remove All Photos") { images.removeAll() }
                                        .foregroundColor(.red)
                                        .font(.caption)
                                } else {
                                    Button(action: { showImagePicker = true }) {
                                        HStack {
                                            Image(systemName: "photo.on.rectangle.angled")
                                            Text("Choose Photos")
                                        }
                                        .font(.headline)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .sheet(isPresented: $showImagePicker) {
                                ImagePickerGallery(images: $images)
                            }
                            .padding(.top, 24)

                        case .notes:
                            VStack(alignment: .leading, spacing: 24) {
                                OnboardingStepTitle(
                                    title: "Notes",
                                    subtitle: "Any extra details about this costume?"
                                )
                                FloatingLabelTextField(
                                    label: "Notes (optional)",
                                    placeholder: "Add any details...",
                                    text: $notes
                                )
                            }
                            .padding(.top, 24)

                        case .confirm:
                            VStack(alignment: .leading, spacing: 24) {
                                OnboardingStepTitle(
                                    title: "Review Costume",
                                    subtitle: "Review and confirm all costume details"
                                )
                                VStack(spacing: 20) {
                                    if !images.isEmpty {
                                        TabView {
                                            ForEach(0..<images.count, id: \.self) { idx in
                                                Image(uiImage: images[idx])
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                                    .shadow(radius: 4)
                                            }
                                        }
                                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                                        .frame(height: 120)
                                    }
                                    VStack(alignment: .center, spacing: 10) {
                                        Text("Name: \(name)")
                                        Text("Size: \(size)")
                                        Text("Color: \(color)")
                                        Text("Category: \(category)")
                                        Text("Total Quantity: \(totalQuantity)")
                                        Text("Location: \(selectedLocation?.name ?? "N/A")")
                                        if !notes.isEmpty {
                                            Text("Notes: \(notes)")
                                        }
                                    }
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .padding(.top, 24)
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: step)
                    .padding(.vertical, 18)
                    .padding(.horizontal, 28)
                    .frame(maxWidth: .infinity, minHeight: cardHeight, alignment: .top)
                    .padding(.bottom, 32)

                    // Buttons (just below content)
                    HStack(spacing: 16) {
                        if step == .name {
                            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                Text("Cancel")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemGray6))
                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                            }
                        } else {
                            Button(action: { previousStep() }) {
                                HStack {
                                    Image(systemName: "arrow.left")
                                    Text("Back")
                                }
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .foregroundColor(.black)
                                .cornerRadius(12)
                            }
                        }
                        if step != .confirm {
                            Button(action: { nextStep() }) {
                                HStack {
                                    Text("Next")
                                    Image(systemName: "arrow.right")
                                }
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(accent)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(!canGoNext)
                        } else {
                            Button(action: { addCostume() }) {
                                HStack {
                                    Text("Add Costume")
                                    Image(systemName: "checkmark")
                                }
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(accent)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(!canGoNext)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 32)
                }
                .frame(maxWidth: .infinity, minHeight: cardHeight)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .sheet(isPresented: $showImagePicker) {
                ImagePickerGallery(images: $images)
            }
        }
        .onAppear {
            if selectedLocationIndex == 0 && !locationOptions.isEmpty {
                selectedLocationIndex = 0
            }
        }
    }

    private func nextStep() {
        if let next = Step(rawValue: step.rawValue + 1) {
            step = next
        }
    }
    private func previousStep() {
        if let prev = Step(rawValue: step.rawValue - 1) {
            step = prev
        }
    }
    private var canGoNext: Bool {
        switch step {
        case .name: return !name.isEmpty
        case .size: return !size.isEmpty
        case .color: return !color.isEmpty
        case .category: return !category.isEmpty
        case .totalQuantity: return totalQuantity > 0
        case .location: return selectedLocation != nil
        case .image: return true
        case .notes: return true
        case .confirm: return true
        }
    }
    private func addCostume() {
        guard let location = selectedLocation else { return }
        let costume = Costume(
            id: UUID(),
            name: name,
            size: size,
            color: color,
            category: category,
            totalQuantity: totalQuantity,
            location: location,
            status: .available,
            notes: notes.isEmpty ? nil : notes,
            imageDatas: images.map { $0.jpegData(compressionQuality: 0.8) ?? Data() }
        )
        inventoryVM.addCostume(costume)
        presentationMode.wrappedValue.dismiss()
    }
}


