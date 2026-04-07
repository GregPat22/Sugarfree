import AVFoundation
import UIKit

final class BarcodeCaptureCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate, @unchecked Sendable {
    let session = AVCaptureSession()
    var onBarcodeDetected: ((String) -> Void)?

    private var isConfigured = false
    private let supportedTypes: [AVMetadataObject.ObjectType] = [
        .ean13, .ean8, .upce, .code128, .code39, .code93, .itf14
    ]

    func configure() {
        guard !isConfigured else { return }
        isConfigured = true

        session.beginConfiguration()
        defer { session.commitConfiguration() }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }

        session.addInput(input)

        let metadataOutput = AVCaptureMetadataOutput()
        guard session.canAddOutput(metadataOutput) else { return }

        session.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metadataOutput.metadataObjectTypes = supportedTypes.filter {
            metadataOutput.availableMetadataObjectTypes.contains($0)
        }
    }

    func start() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stop() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let barcode = object.stringValue else { return }

        stop()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onBarcodeDetected?(barcode)
    }
}
