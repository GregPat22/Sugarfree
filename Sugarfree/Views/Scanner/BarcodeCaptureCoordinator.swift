@preconcurrency import AVFoundation
import UIKit

final class BarcodeCaptureCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate, @unchecked Sendable {
    let session = AVCaptureSession()
    var onBarcodeDetected: (@MainActor @Sendable (String) -> Void)?

    private var isConfigured = false
    private var lastDetection = Date.distantPast
    private let sessionQueue = DispatchQueue(label: "com.sugarfree.camera.session", qos: .userInitiated)

    private let supportedTypes: [AVMetadataObject.ObjectType] = [
        .ean13, .ean8, .upce, .code128, .code39, .code93, .itf14
    ]

    func configureAndStart() {
        guard !isConfigured else { return }
        isConfigured = true

        sessionQueue.async { [self] in
            session.beginConfiguration()

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else {
                session.commitConfiguration()
                return
            }

            session.addInput(input)

            let metadataOutput = AVCaptureMetadataOutput()
            guard session.canAddOutput(metadataOutput) else {
                session.commitConfiguration()
                return
            }

            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = supportedTypes.filter {
                metadataOutput.availableMetadataObjectTypes.contains($0)
            }

            session.commitConfiguration()
            session.startRunning()
        }
    }

    func start() {
        sessionQueue.async { [self] in
            guard !session.isRunning else { return }
            session.startRunning()
        }
    }

    func stop() {
        sessionQueue.async { [self] in
            guard session.isRunning else { return }
            session.stopRunning()
        }
    }

    // MARK: - AVCaptureMetadataOutputObjectsDelegate

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
        stop()

        let callback = onBarcodeDetected
        Task { @MainActor in
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            callback?(barcode)
        }
    }
}
