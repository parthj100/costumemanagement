import SwiftUI

struct AddEventOnboardingView: View {
    @EnvironmentObject var inventoryVM: InventoryViewModel
    @Environment(\.presentationMode) var presentationMode

    // Pass this when editing
    var editEvent: Event? = nil

    enum Step: Int, CaseIterable {
        case name, date, time, organizer, costumes, notes, confirm
    }

    @State private var step: Step = .name
    @State private var name = ""
    @State private var date = Date()
    @State private var time = Date()
    @State private var organizer = ""
    @State private var selectedCostumes: [UUID: Int] = [:]
    @State private var notes = ""

    let accent = Color.pink
    let cardWidth: CGFloat = 420
    let cardHeight: CGFloat = 540

    var costumeOptions: [Costume] { inventoryVM.costumes }
    var assignedCostumeList: [AssignedCostume] {
        costumeOptions
            .filter { selectedCostumes[$0.id] != nil }
            .map { AssignedCostume(costume: $0, quantity: selectedCostumes[$0.id] ?? 1) }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack {
                Spacer(minLength: 0)
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Label(editEvent == nil ? "Create New Event" : "Edit Event", systemImage: "calendar")
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
                                    title: "Event Details",
                                    subtitle: "Let's start with the basic information about your event"
                                )
                                FloatingLabelTextField(
                                    label: "Event Name",
                                    placeholder: "e.g. Summer Theater Production",
                                    text: $name
                                )
                            }
                            .padding(.top, 24)

                        case .date:
                            VStack(alignment: .leading, spacing: 24) {
                                OnboardingStepTitle(
                                    title: "Event Date",
                                    subtitle: "When will the event take place?"
                                )
                                FloatingLabelDatePicker(
                                    label: "Event Date",
                                    date: $date,
                                    accent: accent
                                )
                            }
                            .padding(.top, 24)

                        case .time:
                            VStack(alignment: .leading, spacing: 24) {
                                OnboardingStepTitle(
                                    title: "Event Time",
                                    subtitle: "What time does the event start?"
                                )
                                FloatingLabelTimePicker(
                                    label: "Event Time",
                                    time: $time,
                                    accent: accent
                                )
                            }
                            .padding(.top, 24)

                        case .organizer:
                            VStack(alignment: .leading, spacing: 24) {
                                OnboardingStepTitle(
                                    title: "Organizer",
                                    subtitle: "Who's responsible for this event?"
                                )
                                FloatingLabelTextField(
                                    label: "Organizer Name",
                                    placeholder: "e.g. John Doe",
                                    text: $organizer
                                )
                            }
                            .padding(.top, 24)

                        case .costumes:
                            VStack(alignment: .leading, spacing: 24) {
                                OnboardingStepTitle(
                                    title: "Assign Costumes",
                                    subtitle: "Select costumes and assign quantities"
                                )
                                VStack(spacing: 16) {
                                    ForEach(costumeOptions) { costume in
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack {
                                                Button(action: {
                                                    if selectedCostumes[costume.id] != nil {
                                                        selectedCostumes.removeValue(forKey: costume.id)
                                                    } else {
                                                        selectedCostumes[costume.id] = 1
                                                    }
                                                }) {
                                                    HStack {
                                                        if let data = costume.imageData, let uiImage = UIImage(data: data) {
                                                            Image(uiImage: uiImage)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 36, height: 36)
                                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                        }
                                                        Text(costume.name)
                                                            .fontWeight(.medium)
                                                            .foregroundColor(selectedCostumes[costume.id] != nil ? .pink : .primary)
                                                        Spacer()
                                                        if selectedCostumes[costume.id] != nil {
                                                            Image(systemName: "checkmark.circle.fill")
                                                                .foregroundColor(.pink)
                                                        }
                                                    }
                                                    .padding()
                                                    .background(selectedCostumes[costume.id] != nil ? Color.pink.opacity(0.08) : Color(.systemGray6))
                                                    .cornerRadius(12)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(selectedCostumes[costume.id] != nil ? Color.pink : Color(.systemGray4), lineWidth: 2)
                                                    )
                                                }
                                                // Qty stepper right-aligned
                                                if let qty = selectedCostumes[costume.id] {
                                                    HStack(spacing: 8) {
                                                        Text("Qty: \(qty) of \(costume.availableQuantity)")
                                                            .font(.subheadline)
                                                        Stepper(
                                                            "",
                                                            value: Binding(
                                                                get: { qty },
                                                                set: { newValue in
                                                                    selectedCostumes[costume.id] = min(max(1, newValue), max(1, costume.availableQuantity))
                                                                }
                                                            ),
                                                            in: 1...max(1, costume.availableQuantity)
                                                        )
                                                        .labelsHidden()
                                                    }
                                                    .padding(.trailing)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 12)
                            }
                            .padding(.top, 24)

                        case .notes:
                            VStack(alignment: .leading, spacing: 24) {
                                OnboardingStepTitle(
                                    title: "Notes",
                                    subtitle: "Any extra details about this event?"
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
                                    title: "Review Event",
                                    subtitle: "Review and confirm all event details"
                                )
                                VStack(spacing: 20) {
                                    VStack(alignment: .center, spacing: 10) {
                                        Text("Name: \(name)")
                                        Text("Date: \(date, style: .date)")
                                        Text("Time: \(time, style: .time)")
                                        Text("Organizer: \(organizer)")
                                        Text("Costumes:")
                                        if assignedCostumeList.isEmpty {
                                            Text("No costumes assigned.")
                                                .foregroundColor(.secondary)
                                        } else {
                                            ForEach(assignedCostumeList) { assigned in
                                                HStack(spacing: 12) {
                                                    if let data = assigned.costume.imageData, let uiImage = UIImage(data: data) {
                                                        Image(uiImage: uiImage)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 36, height: 36)
                                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    }
                                                    Text("\(assigned.costume.name) x\(assigned.quantity)")
                                                }
                                                .frame(maxWidth: .infinity, alignment: .center)
                                            }
                                        }
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
                            Button(action: { addEvent() }) {
                                HStack {
                                    Text("Add Event")
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
        }
        .onAppear {
            if let event = editEvent {
                name = event.name
                date = event.date
                time = event.date
                organizer = event.organizer
                notes = event.notes ?? ""
                selectedCostumes = Dictionary(
                    uniqueKeysWithValues: event.assignedCostumes.map { ($0.costume.id, $0.quantity) }
                )
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
        case .date: return true
        case .time: return true
        case .organizer: return !organizer.isEmpty
        case .costumes: return true
        case .notes: return true
        case .confirm: return true
        }
    }
    private func addEvent() {
        let eventDateTime = Calendar.current.date(
            bySettingHour: Calendar.current.component(.hour, from: time),
            minute: Calendar.current.component(.minute, from: time),
            second: 0,
            of: date
        ) ?? date

        let event = Event(
            id: editEvent?.id ?? UUID(),
            name: name,
            date: eventDateTime,
            organizer: organizer,
            assignedCostumes: assignedCostumeList,
            notes: notes.isEmpty ? nil : notes
        )
        if editEvent == nil {
            inventoryVM.addEvent(event)
        } else {
            inventoryVM.updateEvent(event)
        }
        presentationMode.wrappedValue.dismiss()
    }
}





