import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ScannerViewModel()
    @State private var coordinator = BarcodeCaptureCoordinator()
    @State private var cameraPermission: AVAuthorizationStatus = .notDetermined

    var body: some View {
        NavigationStack {
            ZStack {
                switch cameraPermission {
                case .authorized:
                    cameraLayer
                case .denied, .restricted:
                    permissionDeniedView
                default:
                    Color.black.ignoresSafeArea()
                }

                VStack {
                    Spacer()

                    switch viewModel.state {
                    case .scanning:
                        scanPrompt
                    case .loading:
                        ProgressView("Looking up product...")
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    case .found(let name, let brand, let barcode, let sugar, let serving, let categoryTags):
                        ProductResultCard(
                            name: name,
                            brand: brand,
                            sugarGrams: sugar,
                            servingSize: serving,
                            suggestions: viewModel.suggestions(
                                productName: name,
                                categoryTags: categoryTags,
                                sugarGrams: sugar
                            ),
                            remainingBudgetText: {
                                guard let sugar else { return nil }
                                let remaining = viewModel.predictedRemaining(after: sugar)
                                return remaining >= 0
                                    ? "After this entry: \(remaining, specifier: "%.1f")g left today"
                                    : "After this entry: \(-remaining, specifier: "%.1f")g over today"
                            }(),
                            riskText: {
                                guard let sugar else { return nil }
                                return viewModel.streakRiskText(for: sugar)
                            }(),
                            onSave: { grams in
                                viewModel.saveEntry(
                                    name: name,
                                    brand: brand,
                                    barcode: barcode,
                                    sugarGrams: grams,
                                    servingSize: serving,
                                    swapUsed: false,
                                    context: modelContext
                                )
                                coordinator.start()
                            },
                            onUseSwap: { suggestion, estimatedSugar in
                                EventLogger.log(.swapTapped, metadata: suggestion, context: modelContext)
                                viewModel.saveEntry(
                                    name: suggestion,
                                    brand: brand,
                                    barcode: barcode,
                                    sugarGrams: estimatedSugar,
                                    servingSize: serving,
                                    swapUsed: true,
                                    context: modelContext
                                )
                                coordinator.start()
                            },
                            onManualEntry: { viewModel.showManualEntry = true },
                            onRescan: {
                                viewModel.reset()
                                coordinator.start()
                            },
                            onSuggestionsShown: {
                                EventLogger.log(.swapShown, metadata: name, context: modelContext)
                            }
                        )
                    case .notFound(let barcode):
                        notFoundCard(barcode: barcode)
                    case .error(let message):
                        errorCard(message: message)
                    }
                }
            }
            .navigationTitle("Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showManualEntry = true
                    } label: {
                        Image(systemName: "keyboard")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Rescue") {
                        viewModel.startRescueMode(context: modelContext)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showManualEntry) {
                manualEntrySheet
            }
            .alert(
                "Craving Rescue",
                isPresented: Binding(
                    get: { viewModel.rescueModeMessage != nil },
                    set: { if !$0 { viewModel.rescueModeMessage = nil } }
                )
            ) {
                Button("Got it", role: .cancel) { viewModel.rescueModeMessage = nil }
            } message: {
                Text(viewModel.rescueModeMessage ?? "")
            }
            .task {
                await requestCameraAccess()
                setupCoordinator()
            }
            .onDisappear {
                coordinator.stop()
            }
        }
    }

    // MARK: - Setup

    private func setupCoordinator() {
        coordinator.onBarcodeDetected = { @MainActor barcode in
            Task { await viewModel.lookupBarcode(barcode, context: modelContext) }
        }
        coordinator.configureAndStart()
    }

    // MARK: - Camera

    private var cameraLayer: some View {
        CameraPreview(session: coordinator.session)
            .ignoresSafeArea()
            .overlay {
                if viewModel.isScanning {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.6), lineWidth: 2)
                        .frame(width: 280, height: 160)
                }
            }
    }

    // MARK: - States

    private var scanPrompt: some View {
        Text("Point camera at a barcode")
            .font(.callout.weight(.medium))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.regularMaterial, in: Capsule())
            .padding(.bottom, 40)
    }

    private func notFoundCard(barcode: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "barcode.viewfinder")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("Product not found")
                .font(.headline)
            Text("Barcode: \(barcode)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Scan Again") {
                    viewModel.reset()
                    coordinator.start()
                }
                .buttonStyle(.bordered)

                Button("Enter Manually") {
                    viewModel.showManualEntry = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding()
    }

    private func errorCard(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.largeTitle)
                .foregroundStyle(.red)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                viewModel.reset()
                coordinator.start()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding()
    }

    private var permissionDeniedView: some View {
        ContentUnavailableView {
            Label("Camera Access Required", systemImage: "camera.fill")
        } description: {
            Text("Sugarfree needs camera access to scan barcodes. Enable it in Settings.")
        } actions: {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Manual Entry Sheet

    @ViewBuilder
    private var manualEntrySheet: some View {
        switch viewModel.state {
        case .found(let name, let brand, _, _, _, _):
            ManualEntryForm(prefillName: name, prefillBrand: brand)
        case .notFound(let barcode):
            ManualEntryForm(prefillBarcode: barcode)
        default:
            ManualEntryForm()
        }
    }

    // MARK: - Permissions

    private func requestCameraAccess() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            cameraPermission = granted ? .authorized : .denied
        } else {
            cameraPermission = status
        }
    }
}

#Preview {
    BarcodeScannerView()
        .modelContainer(for: [FoodEntry.self, SugarGoal.self, FeatureEvent.self], inMemory: true)
}
