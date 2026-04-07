import AVFoundation
import UIKit

@MainActor
@Observable
final class BarcodeCaptureCoordinator {
    var detectedBarcode: String?

    private(set) var session = AVCaptureSession()
    private var isConfigured = false
    private let delegate = MetadataDelegate()

    private let supportedTypes: [AVMetadataObject.ObjectType] = [
        .ean13, .ean8, .upce, .code128, .code39, .code93, .itf14
    ]

    func configure() {
        guard !isConfigured else { return }
        isConfigured = true

        delegate.onDetected = { [weak self] barcode in
            Task { @MainActor in
                self?.detectedBarcode = barcode
            }
        }

        let captureSession = session
        let metadataDelegate = delegate
        let types = supportedTypes

        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.beginConfiguration()
            defer { captureSession.commitConfiguration() }

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device),
                  captureSession.canAddInput(input) else { return }

            captureSession.addInput(input)

            let metadataOutput = AVCaptureMetadataOutput()
            guard captureSession.canAddOutput(metadataOutput) else { return }

            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(metadataDelegate, queue: .main)
            metadataOutput.metadataObjectTypes = types.filter {
                metadataOutput.availableMetadataObjectTypes.contains($0)
            }
        }
    }

    func start() {
        detectedBarcode = nil
        let captureSession = session
        DispatchQueue.global(qos: .userInitiated).async {
            guard !captureSession.isRunning else { return }
            captureSession.startRunning()
        }
    }

    func stop() {
        let captureSession = session
        DispatchQueue.global(qos: .userInitiated).async {
            guard captureSession.isRunning else { return }
            captureSession.stopRunning()
        }
    }
}

private final class MetadataDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate, @unchecked Sendable {
    var onDetected: ((String) -> Void)?
    private var lastDetection = Date.distantPast

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        let now = Date.now
        guard now.timeIntervalSince(lastDetection) > 1.0 else { return }

        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let barcode = object.stringValue else { return }

        lastDetection = now
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onDetected?(barcode)
    }
}
