import AVKit
import CoreML
import UIKit
import Vision

final class BusDetectionViewController: UIViewController {
    // MARK: Properties

    // input properties
    /// 인식할 노선번호
    var routeNumbersToDetect: [String] = []
    /// 감지된 노선번호 배열이 변경될 때 SwiftUI에서 처리하기 위한 클로저
    var onDetectedRouteNumbersChanged: (([String]) -> Void)?

    // APIs
    private var captureSession: AVCaptureSession?
    private var request: VNCoreMLRequest?
    private var hapticManager = HapticManager.shared
    private var ttsManager: TTSManager = .init()

    // subviews
    private var drawingBoxesView: DrawingBoxesView?
    private var detectingStatusView: BusDetectStatusView?
    #if DEBUG_MODE
        private var tempStrokeBoxesView: TempStokeBoxesView?
        private var croppedImageView: UIImageView?
    #endif

    // for view logic
    private var currentPixelBuffer: CVPixelBuffer?
    private var frameCount: UInt = 0
    private var isBusDetected: Bool = false

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRequest()
        setupCaptureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBoxesView()
        setupStatusView()

        #if DEBUG_MODE
            setupDebugModeBoxesView()
            setupDebugCroppedImageView()
        #endif

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

        // 카메라뷰
        view.layer.sublayers?.first(where: { $0 is AVCaptureVideoPreviewLayer }
        )?.frame = fullFrame

        // 바운딩박스뷰
        drawingBoxesView?.frame = fullFrame

        // 상태표시뷰
        detectingStatusView?.frame = CGRect(
            x: 0,
            y: 16,
            width: view.bounds.width,
            height: 160
        )

        #if DEBUG_MODE
            // 디버그뷰에서만 보이는 버스 인식 바운딩박스
            tempStrokeBoxesView?.frame = fullFrame

            // 크롭된 이미지 뷰 위치 설정 (우상단)
            let imageSize: CGFloat = 150
            let padding: CGFloat = 16
            croppedImageView?.frame = CGRect(
                x: view.bounds.width - imageSize - padding,
                y: view.safeAreaInsets.top + padding,
                width: imageSize,
                height: imageSize
            )
        #endif
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

        do {
            try device.lockForConfiguration()
            // zoom
            let zoomfactor = min(device.maxAvailableVideoZoomFactor, 2.0)
            device.videoZoomFactor = zoomfactor
            print("zoom setting: \(zoomfactor)")

            // fps
            for fps in device.activeFormat.videoSupportedFrameRateRanges {
                print("fps min: \(fps.minFrameRate)")
                print("fps max: \(fps.maxFrameRate)")
            }
            device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 24)
            device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 24)

            device.unlockForConfiguration()
        } catch {
            print("Couldn't set camera configuration (zoom/fps): \(error)")
        }

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
        drawingBoxesView.frame = view.frame
        view.addSubview(drawingBoxesView)
        self.drawingBoxesView = drawingBoxesView
    }

    /// 감지상태 모니터링뷰
    private func setupStatusView() {
        let statusView = BusDetectStatusView()
        view.addSubview(statusView)
        detectingStatusView = statusView
    }

    #if DEBUG_MODE
        /// 디버깅모드용 바운딩박스 서브뷰 설정
        private func setupDebugModeBoxesView() {
            let strokeBoxesView = TempStokeBoxesView()
            strokeBoxesView.frame = view.frame
            view.addSubview(strokeBoxesView)
            tempStrokeBoxesView = strokeBoxesView
        }

        /// 디버깅모드용 버스 이미지 크롭 확인용 서브뷰 설정
        private func setupDebugCroppedImageView() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .black.withAlphaComponent(0.7)
            imageView.layer.borderColor = UIColor.green.cgColor
            imageView.layer.borderWidth = 2
            imageView.layer.cornerRadius = 8
            imageView.clipsToBounds = true
            view.addSubview(imageView)
            croppedImageView = imageView
        }
    #endif
}

// MARK: - Video Delegate

extension BusDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    /// 실시간 캡쳐 Delegate
    func captureOutput(
        _: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from _: AVCaptureConnection
    ) {
        if frameCount >= UInt.max {
            frameCount = 0
        }
        frameCount += 1

        // 1초에 3번만 처리 (24fps → 3fps 처리)
        guard frameCount % 8 == 0 else { return }

        // 여기서 실제 처리 (1초에 3번만 실행됨)
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let request
        else {
            return
        }

        currentPixelBuffer = pixelBuffer

        // 비전 노선탐지
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
        else {
            isBusDetected = false
            detectingStatusView?.updateStatus(to: .unDetected)
            return
        }

        // 박스 초기화
        DispatchQueue.main.async {
            self.drawingBoxesView?.drawBox(with: [])
            self.onDetectedRouteNumbersChanged?([])
            #if DEBUG_MODE
                self.tempStrokeBoxesView?.drawBox(with: [])
            #endif
        }

        var tempDetected: [String] = []
        var finalPredictions: [VNRecognizedObjectObservation] = []
        isBusDetected = false

        for prediction in predictions {
            if prediction.confidence < 0.8 { continue }
            isBusDetected = true

            // 이미지 영역 정하기
            guard let areaOfInterest = cropBusArea(prediction: prediction) else {
                print("이미지 자르기 실패")
                continue
            }

            // 자른 이미지 OCR 처리하기
            OCRManager.recognizeText(from: currentPixelBuffer, in: areaOfInterest) { ocrText in
                guard let ocrText else {
                    print("OCR 처리 실패")
                    self.detectingStatusView?.updateStatus(to: .notMine)
                    return
                }
                print("--BUS OCR--\n\(ocrText)\n------")

                guard let routeContained = OCRManager.isTextContains(
                    text: ocrText,
                    routeNumbers: self.routeNumbersToDetect
                ) else {
                    self.detectingStatusView?.updateStatus(to: .notMine)
                    return
                }

                self.hapticManager.playHaptic(intensity: 1.0, sharpness: 0.0, duration: 0.2)

                finalPredictions.append(prediction)

                for route in routeContained {
                    if !tempDetected.contains(route) {
                        tempDetected.append(route)
                    }
                }

                DispatchQueue.main.async {
                    self.detectingStatusView?.updateStatus(to: .mineDetected)
                    self.onDetectedRouteNumbersChanged?(tempDetected)
                    self.drawingBoxesView?.drawBox(with: finalPredictions)
                }

                // tts
                guard let firstBusDetected = tempDetected.first else {
                    return
                }
                self.ttsManager.speakNow(of: firstBusDetected)

                #if DEBUG_MODE
                    DispatchQueue.main.async {
                        if let pixelBuffer = self.currentPixelBuffer,
                           let croppedImage = self.cropPixelBufferToImage(pixelBuffer, in: areaOfInterest)
                        {
                            self.croppedImageView?.image = croppedImage
                        }
                    }
                #endif
            }
        }
        #if DEBUG_MODE
            DispatchQueue.main.async {
                self.tempStrokeBoxesView?.drawBox(with: predictions.filter { prediction in
                    prediction.confidence >= 0.8 &&
                        !finalPredictions.contains(where: { $0.uuid == prediction.uuid })
                })
            }
        #endif

        if !isBusDetected {
            detectingStatusView?.updateStatus(to: .unDetected)
        }
    }
}
