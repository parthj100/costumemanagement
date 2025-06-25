import SwiftUI

// MARK: - Onboarding Step Title
struct OnboardingStepTitle: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2.bold())
            Text(subtitle)
                .foregroundColor(.gray)
                .font(.body)
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Floating Label TextField
struct FloatingLabelTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline.bold())
            TextField(placeholder, text: $text)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}

// MARK: - Floating Label Picker
struct FloatingLabelPicker: View {
    let label: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline.bold())
            Picker(label, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

// MARK: - Floating Label Stepper
struct FloatingLabelStepper: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline.bold())
            HStack {
                Stepper("", value: $value, in: range)
                Text("\(value)")
                    .font(.body)
                    .padding(.horizontal, 12)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

// MARK: - Floating Label Location Picker
struct FloatingLabelLocationPicker: View {
    let label: String
    @Binding var selection: UUID?
    let locations: [Location]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline.bold())
            Picker(label, selection: $selection) {
                ForEach(locations) { loc in
                    Text(loc.name).tag(Optional(loc.id))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

// MARK: - Floating Label Image Picker
struct FloatingLabelImagePicker: View {
    let label: String
    @Binding var image: UIImage?
    @Binding var showImagePicker: Bool
    var accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline.bold())
            HStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
                Button("Choose Photo") { showImagePicker = true }
                if image != nil {
                    Button(action: { image = nil }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .padding(.leading, 8)
                }
            }
        }
    }
}

// MARK: - StepCostumeSummary
struct StepCostumeSummary: View {
    let name: String
    let size: String
    let color: String
    let category: String
    let totalQuantity: Int
    let location: Location?
    let notes: String
    let image: UIImage?
    var accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let image = image {
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Spacer()
                }
            }
            Group {
                Text("Name: \(name)")
                Text("Size: \(size)")
                Text("Color: \(color)")
                Text("Category: \(category)")
                Text("Total Quantity: \(totalQuantity)")
                Text("Location: \(location?.name ?? "N/A")")
                if !notes.isEmpty {
                    Text("Notes: \(notes)")
                }
            }
            .font(.body)
        }
    }
}

struct StepCostumeQuantityPicker: View {
    @EnvironmentObject var inventoryVM: InventoryViewModel
    @Binding var selectedCostumes: [UUID: Int]
    var accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(inventoryVM.costumes) { costume in
                HStack {
                    Button(action: {
                        if selectedCostumes[costume.id] != nil {
                            selectedCostumes.removeValue(forKey: costume.id)
                        } else {
                            selectedCostumes[costume.id] = 1
                        }
                    }) {
                        Image(systemName: selectedCostumes[costume.id] != nil ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedCostumes[costume.id] != nil ? accent : .gray)
                    }
                    Text(costume.name)
                        .foregroundColor(.primary)
                    Spacer()
                    if let qty = selectedCostumes[costume.id] {
                        Stepper("", value: Binding(
                            get: { qty },
                            set: { newValue in
                                selectedCostumes[costume.id] = min(max(1, newValue), costume.totalQuantity)
                            }
                        ), in: 1...costume.totalQuantity)
                        Text("\(qty)/\(costume.totalQuantity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

struct FloatingLabelDatePicker: View {
    let label: String
    @Binding var date: Date
    var accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline.bold())
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .frame(maxWidth: .infinity)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

struct FloatingLabelTimePicker: View {
    let label: String
    @Binding var time: Date
    var accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline.bold())
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.gray)
                DatePicker(
                    "",
                    selection: $time,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .frame(maxWidth: .infinity)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

