import SwiftUI

struct SettingsView: View {
    @AppStorage("useLightAppearance") private var useLightAppearance = false
    @AppStorage("appLanguageCode") private var appLanguageCode = "system"

    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Toggle("Light mode", isOn: $useLightAppearance)
                    Text("Enable this to force a bright theme across the app.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Language") {
                    Picker("App language", selection: $appLanguageCode) {
                        Text("System").tag("system")
                        Text("English").tag("en")
                        Text("Italiano").tag("it")
                    }
                    .pickerStyle(.segmented)

                    Text("Switch between English and Italian instantly.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
