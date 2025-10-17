import AVKit
import UIKit
import Vision

final class BusDetectionViewController: UIViewController {
    private var captureSession: AVCaptureSession?
    private var request: VNCoreMLRequest?

    private var drawingBoxesView: DrawingBoxesView?

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRequest()
        setupCaptureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBoxesView()
        captureSession?.startRunning()
    }

    // MARK: Functions
    /// 카메라 기본 설정
    private func setupCaptureSession() {
        let session = AVCaptureSession()

        session.beginConfiguration()
        session.sessionPreset = .hd1280x720

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device)
        else {
            print("Couldn't create video input")
            return
        }

        session.addInput(input)

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.frame

        view.layer.addSublayer(preview)

        let queue = DispatchQueue(label: "videoQueue", qos: .userInteractive)

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: queue)

        if session.canAddOutput(output) {
            session.addOutput(output)

            output.connection(with: .video)?.videoRotationAngle = 90
            session.commitConfiguration()

            captureSession = session
        } else {
            print("Couldn't add video output")
        }
    }

    /// 바운딩박스 뷰 서브뷰 설정
    private func setupBoxesView() {
        let drawingBoxesView = DrawingBoxesView()
        drawingBoxesView.frame = view.frame

        view.addSubview(drawingBoxesView)
        self.drawingBoxesView = drawingBoxesView
    }
}

// MARK: - Video Delegate
extension BusDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    /// 실시간 캡쳐 Delegate
    func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), let request else {
            return
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }
}

// MARK: - AI 모델 관련
extension BusDetectionViewController {
    /// AI 모델 요청
    private func setupRequest() {
        let configuration = MLModelConfiguration()

        guard let model = try? BusObjectDetector(configuration: configuration).model,
              let visionModel = try? VNCoreMLModel(for: model)
        else {
            return
        }

        request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
        request?.imageCropAndScaleOption = .scaleFit
    }

    /// AI 모델 결과 처리
    private func visionRequestDidComplete(request: VNRequest, error _: Error?) {
        if let predictions = (request.results as? [VNRecognizedObjectObservation]) {
            // TODO: 바운딩박스 받아서 OCR 돌리기
            // TODO: OCR 결과 찾던 버스라면 그때 바운딩박스 UI 그려주기
            predictions.map {
                $0.confidence > 0.6
            }

            DispatchQueue.main.async {
                self.drawingBoxesView?.drawBox(with: predictions)
            }
        }
    }
}
