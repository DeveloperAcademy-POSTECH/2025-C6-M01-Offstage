import AVFoundation
import BusAPI
import Foundation

enum SheetState {
    case listening
    case confirmation(recognizedBusNumber: String)
    case busRouteList([BusRoute])
}

@MainActor
class SheetViewModel: ObservableObject {
    @Published var currentSheetState: SheetState = .listening
    @Published var recognizedBusNumber: String? = nil
    @Published var currentBusStop: BusStop? = nil

    private let synthesizer = AVSpeechSynthesizer()
    private let sttManager = STTManager()
    private let busRouteMatcher: BusRouteMatcher

    init(busRoutes: [BusRoute]) { // init 수정
        busRouteMatcher = .init(busRoutes: busRoutes)
    }

    func startListeningProcess() {
        currentSheetState = .listening
        Task {
            if let recognizedText = await speakAndListenMock(text: "번호를 말씀해주세요.") {
                // 정규화 및 추론 전략을 수행하는 함수를 호출합니다.
                self.processRecognizedText(recognizedText)
            } else {
                // Handle case where nothing is recognized
            }
        }
    }

    func showBusRouteList(routes: [BusRoute]) {
        currentSheetState = .busRouteList(routes)
    }

    @MainActor
    private func processRecognizedText(_ transcript: String) {
        let matchResult = busRouteMatcher.process(transcript: transcript)

        switch matchResult {
        case let .exact(route), let .fuzzy(route):
            recognizedBusNumber = route.routeNumber
            currentSheetState = .confirmation(recognizedBusNumber: route.routeNumber)
        case let .partial(routes):
            currentSheetState = .busRouteList(routes)
        case let .none(normalizedText):
            currentSheetState = .confirmation(recognizedBusNumber: normalizedText)
        }
    }

    private func speakAndListenMock(text: String) async -> String? {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try? audioSession.setActive(true)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = 0.5
        synthesizer.speak(utterance)

        // TTS가 끝날 때까지 대기
        while synthesizer.isSpeaking {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초씩 체크
        }

        // TTS 종료 후 안정화를 위한 짧은 딜레이 0.2초
        try? await Task.sleep(nanoseconds: 200_000_000)

        // STT 시작
        sttManager.startListening()

        // 음성 인식 시간 (5초 동안 듣기)
        try? await Task.sleep(nanoseconds: 5_000_000_000)

        // STT 중지
        sttManager.stopListening()

        let recognizedText = sttManager.transcript
        return recognizedText.isEmpty ? nil : recognizedText
    }

    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        // ✅ 추가: STT도 함께 중지
        sttManager.stopListening()
    }
}
