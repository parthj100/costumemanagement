import SwiftUI

struct ContentView: View {
    @StateObject var inventoryVM = InventoryViewModel()

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            CostumeListView()
                .tabItem {
                    Label("Inventory", systemImage: "tshirt.fill")
                }
            EventListView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
        }
        .environmentObject(inventoryVM)
    }
}

