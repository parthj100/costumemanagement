import SwiftUI

struct CheckOutSheet: View {
    let costume: Costume
    var onCheckOut: (String, Int, Date) -> Void

    @State private var checkedOutBy = ""
    @State private var quantity = 1
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("How many?")) {
                    Stepper(value: $quantity, in: 1...costume.availableQuantity) {
                        Text("\(quantity) of \(costume.availableQuantity) available")
                    }
                }
                Section(header: Text("Who is checking out?")) {
                    TextField("Name", text: $checkedOutBy)
                }
                Section(header: Text("Return Date")) {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Check Out Costume")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Check Out") {
                    onCheckOut(checkedOutBy, quantity, dueDate)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(checkedOutBy.isEmpty)
            )
        }
    }
}


