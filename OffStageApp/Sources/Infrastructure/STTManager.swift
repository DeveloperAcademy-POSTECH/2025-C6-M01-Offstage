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

    // MARK: - 인식 시작 (실시간 스트리밍)

    func startListening() {
        // 이미 실행 중이면 중복으로 시작하지 않음
        guard !audioEngine.isRunning else { return }

        // UI 토글용 상태 업데이트
        isListening = true

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
                }
            }

            if let error {
                // 오류가 발생하면 안전하게 정리하고 중지
                print("인식 오류: \(error.localizedDescription)")
                stopListening()
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
            // 가져온 오디오 버퍼를 인식 요청에 계속 추가 → 스트리밍 인식
            self?.request?.append(buffer)
        }

        // 4) 오디오 엔진 시작 (실제 마이크 캡처 ON)
        audioEngine.prepare()
        do {
            try audioEngine.start() // 여기서부터 마이크 입력이 흘러들어옴
        } catch {
            print("오디오 엔진 시작 실패: \(error.localizedDescription)")
            stopListening()
        }
    }

    // MARK: - 인식 중지 (리소스 정리)

    func stopListening() {
        // 오디오 입력 정지
        audioEngine.stop()
        // 탭 제거: 다음 시작 때 중복 탭으로 인한 충돌/중복 콜백 방지
        audioEngine.inputNode.removeTap(onBus: 0)
        // 인식 요청 스트림 종료 통지(더 이상 오디오 없음)
        request?.endAudio()
        // 인식 작업 취소(완전 종료)
        recognitionTask?.cancel()

        // 참조 해제 (다음 시작을 위해 깔끔히)
        request = nil
        recognitionTask = nil

        // UI 토글용 상태 업데이트
        isListening = false
    }
}
