import AVKit
import CoreML
import UIKit
import Vision

final class BusDetectionViewController: UIViewController {
    // MARK: Properties

    // input properties
    /// 인식할 노선번호
    var routeNumbersToDetect: [String] = []
    /// 감지된 상태가 변경될 때 SwiftUI에서 처리하기 위한 클로저
    var onDetectedStatusChanged: ((BusDetectStatus) -> Void)?

    // APIs
    private var captureSession: AVCaptureSession?
    private var request: VNCoreMLRequest?
    private var hapticManager = HapticManager.shared
    private var ttsManager: TTSManager = .init()

    // subviews
    #if DEBUG_MODE
        private var drawingBoxesView: DrawingBoxesView?
        private var tempStrokeBoxesView: TempStokeBoxesView?
    #endif

    // for view logic
    private var currentPixelBuffer: CVPixelBuffer?
    private var frameCount: UInt = 0
    private var isBusDetected: Bool = false
    private var detectStatus: BusDetectStatus = .unDetected

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRequest()
        setupCaptureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        #if DEBUG_MODE
            setupBoxesView()
            setupDebugModeBoxesView()
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

        #if DEBUG_MODE
            // 내버스 바운딩박스
            drawingBoxesView?.frame = fullFrame

            // 버스 인식 바운딩박스
            tempStrokeBoxesView?.frame = fullFrame
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

    #if DEBUG_MODE
        /// 디버깅모드용 내버스 바운딩박스 뷰 서브뷰 설정
        private func setupBoxesView() {
            let drawingBoxesView = DrawingBoxesView()
            drawingBoxesView.frame = view.frame
            view.addSubview(drawingBoxesView)
            self.drawingBoxesView = drawingBoxesView
        }

        /// 디버깅모드용 감지된 버스 바운딩박스 서브뷰 설정
        private func setupDebugModeBoxesView() {
            let strokeBoxesView = TempStokeBoxesView()
            strokeBoxesView.frame = view.frame
            view.addSubview(strokeBoxesView)
            tempStrokeBoxesView = strokeBoxesView
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
            self.onDetectedStatusChanged?(.unDetected)
            return
        }

        #if DEBUG_MODE
            // 박스 초기화
            DispatchQueue.main.async {
                self.drawingBoxesView?.drawBox(with: [])
                self.tempStrokeBoxesView?.drawBox(with: [])
            }
        #endif

        var finalPredictions: [VNRecognizedObjectObservation] = []
        isBusDetected = false

        let ocrGroup = DispatchGroup()

        for prediction in predictions {
            if prediction.confidence < 0.8 { continue }
            isBusDetected = true

            // 이미지 영역 정하기
            guard let areaOfInterest = cropBusArea(prediction: prediction) else {
                print("이미지 자르기 실패")
                continue
            }

            ocrGroup.enter()

            // 자른 이미지 OCR 처리하기
            OCRManager.recognizeText(from: currentPixelBuffer, in: areaOfInterest) { ocrText in
                defer {
                    ocrGroup.leave()
                }

                guard let ocrText else {
                    print("OCR 처리 실패")
                    return
                }
                print("--BUS OCR--\n\(ocrText)\n------")

                guard let routeContained = OCRManager.isTextContains(
                    text: ocrText,
                    routeNumbers: self.routeNumbersToDetect
                ) else {
                    return
                }

                // 배열 접근 동기화
                DispatchQueue.main.async {
                    finalPredictions.append(prediction)

                    // TODO: for prediction in predictions for문 탈출
                }
            }
        }

        // 한 프레임의 prediction이 끝나면 한 번에 처리
        ocrGroup.notify(queue: .main) {
            // 내가 탈 버스가 감지되었는지
            if !finalPredictions.isEmpty {
                // 상태 업데이트
                self.onDetectedStatusChanged?(.mineDetected(routeNum: self.routeNumbersToDetect.first!))

                // 햅틱
                self.hapticManager.playHaptic(intensity: 1.0, sharpness: 0.0, duration: 0.2)

                #if DEBUG_MODE
                    // 박스 그리기
                    self.drawingBoxesView?.drawBox(with: finalPredictions)
                #endif

                // TTS
                self.ttsManager.speakNow(of: self.routeNumbersToDetect.first!)
            } else if self.isBusDetected {
                // 버스는 감지됐지만 내 버스가 아님
                self.onDetectedStatusChanged?(.notMine)
            } else {
                // 버스가 아예 없음
                self.onDetectedStatusChanged?(.unDetected)
            }

            #if DEBUG_MODE
                // 디버깅모드용 흰색박스
                self.tempStrokeBoxesView?.drawBox(with: predictions.filter { prediction in
                    prediction.confidence >= 0.8 &&
                        !finalPredictions.contains(where: { $0.uuid == prediction.uuid })
                })
            #endif
        }
    }
}
