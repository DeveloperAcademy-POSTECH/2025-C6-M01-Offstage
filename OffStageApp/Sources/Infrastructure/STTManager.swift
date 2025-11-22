import Accelerate
import AVFoundation // 마이크 캡처를 위한 오디오 세션/엔진
import Combine // @Published와 ObservableObject를 통해 상태 변경을 UI에 전달하기 위해 필요
import Foundation
import Speech // SFSpeechRecognizer 등 음성 인식 API

final class STTManager: NSObject, ObservableObject {
    // MARK: - 외부(UI)에서 관찰할 상태 값

    @Published var transcript: String = "" // 실시간 인식 결과 텍스트
    @Published var isListening: Bool = false // 현재 듣는 중 여부 (버튼 토글에 사용)

    // MARK: - 내부 구성 요소

    // 인식기: 언어를 한국어("ko-KR")로 지정.
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    // 마이크 입력을 다루는 오디오 엔진. installTap으로 버퍼를 받아온다.
    private let audioEngine = AVAudioEngine()
    // 인식기에게 "지금부터 오디오 스트림 들어간다"라고 전달하는 요청 객체(스트리밍)
    private var request: SFSpeechAudioBufferRecognitionRequest?
    // 실제 인식 작업(콜백으로 부분/최종 결과, 오류를 받는다)
    private var recognitionTask: SFSpeechRecognitionTask?
    private var finalResultContinuation: CheckedContinuation<String?, Never>?

    // 발화 상태 추적용
    private enum ListeningState {
        case waitingForSpeech
        case trackingSpeech(peak: Float)
    }

    private var listeningState: ListeningState = .waitingForSpeech
    private let startThreshold: Float = -40 // 말 시작 판단 임계값(dB)
    private let falloffMargin: Float = 20 // 피크 대비 종료 판단 마진(dB)
    private var silenceTimerTask: Task<Void, Never>? // 1초 무음 확인용 타이머
    private var lastSpeechTimestamp = Date.distantPast // 최소 발화 지속 시간 추적

    // MARK: - 초기화

    override init() {
        super.init()
        requestAuthorization()
    }

    // MARK: - 권한 요청

    private func requestAuthorization() {
        // iOS가 음성 인식 권한 팝업을 표시(처음 1회).
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                // 허용됨. 이후 startListening()에서 인식 가능
                print("음성 인식 권한 허용됨")
            case .denied, .restricted, .notDetermined:
                // 거부/제한/미결정. 인식 시작 전에 가드 필요
                print("음성 인식 권한이 없습니다. 설정에서 권한을 허용하세요.")
            @unknown default:
                print("알 수 없는 권한 상태")
            }
        }
    }

    // MARK: 음성이 끝난 것을 인식

    func listenUntilFinalResult() async -> String? {
        await withCheckedContinuation { continuation in
            finalResultContinuation = continuation
            startListening()
        }
    }

    // MARK: - 인식 시작 (실시간 스트리밍)

    func startListening() {
        // 이미 실행 중이면 중복으로 시작하지 않음
        guard !audioEngine.isRunning else { return }

        // UI 토글용 상태 업데이트
        isListening = true

        // 상태 초기화
        listeningState = .waitingForSpeech
        silenceTimerTask?.cancel()
        silenceTimerTask = nil

        // 1) 스트리밍 요청 객체 생성
        let request = SFSpeechAudioBufferRecognitionRequest()
        // 말하는 도중에도 중간 결과(부분 자막처럼)를 계속 받기
        request.shouldReportPartialResults = true
        self.request = request

        // 2) 인식 작업 생성: 결과가 나올 때마다 콜백 호출
        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if let result {
                // bestTranscription: 현재까지 인식된 최적의 문장
                // UI 업데이트는 메인 스레드에서
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                    print("[STT] transcript:", self.transcript)
                }

                if result.isFinal {
                    finishRecognition(with: result.bestTranscription.formattedString)
                    print("[STT] recognizer reported final result")
                    return
                }
            }

            if let error {
                // 오류가 발생하면 안전하게 정리하고 중지
                print("[STT] recognition error:", error.localizedDescription)
                finishRecognition(with: nil)
            }
        }

        // 3) 마이크 → 버퍼 → 요청 으로 이어지는 오디오 파이프라인 구성
        let inputNode = audioEngine.inputNode // 마이크 입력 노드
        let format = inputNode.outputFormat(forBus: 0) // 마이크 출력 포맷(샘플레이트 등)

        // 혹시 이전에 설치한 탭이 남아있을 수 있으니 선제적으로 제거(중복 탭 방지)
        inputNode.removeTap(onBus: 0)

        // installTap: 마이크에서 나오는 오디오 버퍼를 "훔쳐보기"로 가져옴
        // bufferSize는 1024 샘플 단위로 콜백. 너무 작거나 크면 지연/성능 영향
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let self else { return }

            // 데시벨 기반 상태 머신
            let rms = rmsLevel(for: buffer)
            print("[STT] rms:", rms, "state:", listeningState)

            switch listeningState {
            case .waitingForSpeech:
                if rms > startThreshold {
                    print("[STT] speech detected, peak:", rms)
                    listeningState = .trackingSpeech(peak: rms)
                    lastSpeechTimestamp = Date() // 발화 시작 시각 저장
                }
            case let .trackingSpeech(peak):
                let newPeak = max(peak, rms)
                listeningState = .trackingSpeech(peak: newPeak)

                let hasRecognizedText = !transcript.isEmpty // 👈 실제 문장이 나왔을 때만 무음 판단
                let elapsedSinceSpeech = Date().timeIntervalSince(lastSpeechTimestamp)
                let canCheckSilence = hasRecognizedText && elapsedSinceSpeech > 1.0

                if canCheckSilence, rms < newPeak - falloffMargin {
                    scheduleSilenceTimeout()
                } else {
                    cancelSilenceTimeout()
                    if rms > newPeak - 3 { // 👈 충분히 큰 입력이면 최근 발화 시각 갱신
                        lastSpeechTimestamp = Date()
                    }
                }
            }

            // 가져온 오디오 버퍼를 인식 요청에 계속 추가 → 스트리밍 인식
            self.request?.append(buffer)
        }

        // 4) 오디오 엔진 시작 (실제 마이크 캡처 ON)
        audioEngine.prepare()
        do {
            try audioEngine.start() // 여기서부터 마이크 입력이 흘러들어옴
            print("[STT] audio engine started")
        } catch {
            print("[STT] audio engine start failed:", error.localizedDescription)
            finishRecognition(with: nil)
        }
    }

    // MARK: - 인식 중지 (리소스 정리)

    func stopListening() {
        print("[STT] stopListening called")
        finishRecognition(with: nil)
    }

    private func finishRecognition(with finalText: String?) {
        print("[STT] finishRecognition finalText:", finalText ?? "nil")

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        request?.endAudio()
        recognitionTask?.cancel()
        request = nil
        recognitionTask = nil
        isListening = false
        listeningState = .waitingForSpeech
        silenceTimerTask?.cancel()
        silenceTimerTask = nil

        finalResultContinuation?.resume(returning: finalText?.isEmpty == false ? finalText : nil)
        finalResultContinuation = nil
    }

    // 1초 무음 대기 로직
    private func scheduleSilenceTimeout() {
        if silenceTimerTask != nil { return }
        print("[STT] silence candidate, start 1s timer")
        silenceTimerTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1))
            await MainActor.run {
                guard let self else { return }
                print("[STT] silence confirmed -> finishing")
                self.finishRecognition(with: self.transcript)
            }
        }
    }

    private func cancelSilenceTimeout() {
        if silenceTimerTask != nil {
            print("[STT] speech resumed, cancel timer")
        }
        silenceTimerTask?.cancel()
        silenceTimerTask = nil
    }

    // RMS 계산
    private func rmsLevel(for buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?.pointee else { return -100 }
        let frameLength = vDSP_Length(buffer.frameLength)
        var meanSquare: Float = 0
        vDSP_measqv(channelData, 1, &meanSquare, frameLength)
        let rms = sqrt(meanSquare)
        let db = 20 * log10(rms)
        return db.isFinite ? db : -100
    }
}
