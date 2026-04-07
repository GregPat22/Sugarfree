import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ScannerViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                // TODO: Replace with live AVCaptureSession camera preview
                // that detects EAN-13, UPC-A, and other barcode symbologies
                ContentUnavailableView(
                    "Point at a barcode",
                    systemImage: "barcode.viewfinder",
                    description: Text("Camera preview and barcode detection will appear here.")
                )
            }
            .navigationTitle("Scan")
            .sheet(isPresented: $viewModel.showManualEntry) {
                // TODO: Manual sugar entry form as fallback
                Text("Manual Entry Form")
            }
        }
    }
}

#Preview {
    BarcodeScannerView()
        .modelContainer(for: FoodEntry.self, inMemory: true)
}
