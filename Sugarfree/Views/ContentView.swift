import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "chart.bar.fill") {
                DashboardView()
            }

            Tab("Scan", systemImage: "barcode.viewfinder") {
                BarcodeScannerView()
            }

            Tab("Log", systemImage: "plus.circle.fill") {
                TrackerView()
            }

            Tab("Goals", systemImage: "flame.fill") {
                GoalsView()
            }
        }
    }
}

#Preview {
    ContentView()
}
