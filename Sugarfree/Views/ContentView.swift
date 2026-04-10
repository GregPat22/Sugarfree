import SwiftUI

struct ContentView: View {
    private enum Tab: Hashable {
        case dashboard
        case scan
        case log
        case goals
        case settings
    }

    @State private var selectedTab: Tab = .dashboard
    @State private var dashboardRefreshToken = UUID()
    @AppStorage("useLightAppearance") private var useLightAppearance = false
    @AppStorage("appLanguageCode") private var appLanguageCode = "system"

    private var appLocale: Locale {
        if appLanguageCode == "system" {
            return .autoupdatingCurrent
        }
        return Locale(identifier: appLanguageCode)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(refreshToken: dashboardRefreshToken)
                .tag(Tab.dashboard)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }

            BarcodeScannerView()
                .tag(Tab.scan)
                .tabItem {
                    Label("Scan", systemImage: "barcode.viewfinder")
                }

            TrackerView()
                .tag(Tab.log)
                .tabItem {
                    Label("Log", systemImage: "plus.circle.fill")
                }

            GoalsView()
                .tag(Tab.goals)
                .tabItem {
                    Label("Goals", systemImage: "flame.fill")
                }

            SettingsView()
                .tag(Tab.settings)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .preferredColorScheme(useLightAppearance ? .light : nil)
        .environment(\.locale, appLocale)
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .dashboard {
                dashboardRefreshToken = UUID()
            }
        }
    }
}

#Preview {
    ContentView()
}
