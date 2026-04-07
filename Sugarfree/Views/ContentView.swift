import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }

            BarcodeScannerView()
                .tabItem {
                    Label("Scan", systemImage: "barcode.viewfinder")
                }

            TrackerView()
                .tabItem {
                    Label("Log", systemImage: "plus.circle.fill")
                }

            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "flame.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
