import AVKit
import CoreML
import UIKit
import Vision

final class BusDetectionViewController: UIViewController {
    /// 인식할 노선번호
    var routeNumbersToDetect: [String] = []
    /// 감지된 노선번호 배열이 변경될 때 SwiftUI에서 처리하기 위한 클로저
    var onDetectedRouteNumbersChanged: (([String]) -> Void)?

    private var captureSession: AVCaptureSession?
    private var request: VNCoreMLRequest?

    private var drawingBoxesView: DrawingBoxesView?
    private var tempStrokeBoxesView: TempStokeBoxesView?
    private var currentPixelBuffer: CVPixelBuffer?

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRequest()
        setupCaptureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBoxesView()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // (0, 0)부터 시작하도록
        let fullFrame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height
        )

        view.layer.sublayers?.first(where: { $0 is AVCaptureVideoPreviewLayer }
        )?.frame = fullFrame
        drawingBoxesView?.frame = fullFrame
        tempStrokeBoxesView?.frame = fullFrame
    }

    // MARK: Functions

    /// 카메라 기본 설정
    private func setupCaptureSession() {
        let session = AVCaptureSession()

        session.beginConfiguration()
        session.sessionPreset = .hd1280x720

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ),
            let input = try? AVCaptureDeviceInput(device: device)
        else {
            print("Couldn't create video input")
            return
        }

        session.addInput(input)

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.bounds

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
        let strokeBoxesView = TempStokeBoxesView()
        drawingBoxesView.frame = view.frame
        strokeBoxesView.frame = view.frame

        view.addSubview(strokeBoxesView)
        view.addSubview(drawingBoxesView)

        self.drawingBoxesView = drawingBoxesView
        tempStrokeBoxesView = strokeBoxesView
    }
}

// MARK: - Video Delegate

extension BusDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    /// 실시간 캡쳐 Delegate
    func captureOutput(
        _: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from _: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let request
        else {
            return
        }

        currentPixelBuffer = pixelBuffer

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }
}

// MARK: - AI 모델 관련

extension BusDetectionViewController {
    /// AI 모델 요청
    private func setupRequest() {
        let configuration = MLModelConfiguration()

        guard let model = try? loadMLModel(configuration: configuration),
              let visionModel = try? VNCoreMLModel(for: model)
        else {
            return
        }

        request = VNCoreMLRequest(
            model: visionModel,
            completionHandler: visionRequestDidComplete
        )
        request?.imageCropAndScaleOption = .scaleFit
    }

    private func loadMLModel(configuration: MLModelConfiguration) throws
        -> MLModel
    {
        let bundle = Bundle.main

        if let modelURL = bundle.url(
            forResource: "BusObjectDetector",
            withExtension: "mlmodelc"
        ) {
            return try MLModel(
                contentsOf: modelURL,
                configuration: configuration
            )
        }

        guard let modelURL = bundle.url(
            forResource: "BusObjectDetector",
            withExtension: "mlmodel"
        )
        else {
            throw NSError(
                domain: "BusDetectionViewController",
                code: -1,
                userInfo: nil
            )
        }

        let compiledURL = try MLModel.compileModel(at: modelURL)
        return try MLModel(
            contentsOf: compiledURL,
            configuration: configuration
        )
    }

    /// AI 모델 결과 처리
    private func visionRequestDidComplete(request: VNRequest, error _: Error?) {
        guard let predictions =
            (request.results as? [VNRecognizedObjectObservation])
        else { return }

        var tempDetected: [String] = []
        var finalPredictions: [VNRecognizedObjectObservation] = []

        for prediction in predictions {
            if prediction.confidence < 0.6 { continue }

            // 이미지 자르기
            guard let image = cropImage(
                pixelBuffer: currentPixelBuffer,
                prediction: prediction
            ) else {
                print("이미지 자르기 실패")
                continue
            }

            // 이미지 크기 조정
            guard let resizedImage = resizeImage(image) else {
                print("이미지 크기 조정 실패")
                continue
            }

            // 자른 이미지 OCR 처리하기
            OCRManager.recognizeText(from: resizedImage) { ocrText in
                guard let ocrText else {
                    print("OCR 처리 실패")
                    return
                }
                print(ocrText)

                // OCR 텍스트에 찾던 버스번호 있는지 검사
                for routeNo in self.routeNumbersToDetect {
                    if ocrText.contains(routeNo) {
                        // 검사 결과에 있다면 바운딩박스에 추가
                        finalPredictions.append(prediction)
                        if !tempDetected.contains(routeNo) {
                            tempDetected.append(routeNo)
                        }
                    }
                }
            }
        }

        DispatchQueue.main.async {
            self.onDetectedRouteNumbersChanged?(tempDetected)
            self.drawingBoxesView?.drawBox(with: finalPredictions)
            self.tempStrokeBoxesView?.drawBox(with: predictions.filter { prediction in
                prediction.confidence >= 0.6 &&
                    !finalPredictions.contains(where: { $0.uuid == prediction.uuid })
            })
        }
    }
}
