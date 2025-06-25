import SwiftUI

struct EventEditView: View {
    @EnvironmentObject var inventoryVM: InventoryViewModel
    @Environment(\.presentationMode) var presentationMode

    var editEvent: Event?

    @State private var name = ""
    @State private var date = Date()
    @State private var organizer = ""
    @State private var selectedCostumes: [UUID: Int] = [:]
    @State private var notes = ""

    var assignedCostumeList: [AssignedCostume] {
        inventoryVM.costumes
            .filter { selectedCostumes[$0.id] != nil }
            .map { AssignedCostume(costume: $0, quantity: selectedCostumes[$0.id] ?? 1) }
    }

    var body: some View {
        NavigationView {
            let costumes = inventoryVM.costumes // Precompute for performance

            Form {
                Section(header: Text("Event Info")) {
                    TextField("Name", text: $name)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Organizer", text: $organizer)
                    TextField("Notes", text: $notes)
                }
                Section(header: Text("Costumes")) {
                    ForEach(costumes) { costume in
                        HStack {
                            Button(action: {
                                if selectedCostumes[costume.id] != nil {
                                    selectedCostumes.removeValue(forKey: costume.id)
                                } else {
                                    selectedCostumes[costume.id] = 1
                                }
                            }) {
                                Image(systemName: selectedCostumes[costume.id] != nil ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedCostumes[costume.id] != nil ? .blue : .gray)
                            }
                            Text(costume.name)
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
                    }
                }
            }
            .navigationTitle(editEvent == nil ? "Add Event" : "Edit Event")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") {
                    let event = Event(
                        id: editEvent?.id ?? UUID(),
                        name: name,
                        date: date,
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
                .disabled(name.isEmpty || organizer.isEmpty)
            )
            .onAppear {
                if let event = editEvent {
                    name = event.name
                    date = event.date
                    organizer = event.organizer
                    notes = event.notes ?? ""
                    selectedCostumes = Dictionary(
                        uniqueKeysWithValues: event.assignedCostumes.map { ($0.costume.id, $0.quantity) }
                    )
                }
            }
        }
    }
}

