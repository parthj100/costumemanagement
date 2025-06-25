import SwiftUI

struct CheckInSheet: View {
    let costume: Costume
    let checkOutInfo: CheckOutInfo
    var onCheckIn: (Int) -> Void

    @State private var quantity = 1
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("How many to check in?")) {
                    Stepper(value: $quantity, in: 1...checkOutInfo.quantity) {
                        Text("\(quantity) of \(checkOutInfo.quantity) checked out")
                    }
                }
            }
            .navigationTitle("Check In Costume")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Check In") {
                    onCheckIn(quantity)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
