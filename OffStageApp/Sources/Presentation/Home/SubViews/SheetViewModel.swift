import AVFoundation
import Foundation

enum SheetState {
    case listening
    case confirmation(recognizedBusNumber: String)
}

@MainActor
class SheetViewModel: ObservableObject {
    @Published var isAnimating: Bool = false
    @Published var currentSheetState: SheetState = .listening
    @Published var recognizedBusNumber: String? = nil

    private let synthesizer = AVSpeechSynthesizer()

    init() {
        // Optional: Configure synthesizer if needed
    }

    func startListeningAnimation() {
        isAnimating = true
    }

    func stopListeningAnimation() {
        isAnimating = false
    }

    func startListeningProcess() {
        currentSheetState = .listening
        startListeningAnimation()
        Task {
            if let recognizedText = await speakAndListenMock(text: "번호를 말씀해주세요.") {
                self.recognizedBusNumber = recognizedText
                currentSheetState = .confirmation(recognizedBusNumber: recognizedText)
            } else {
                // Handle case where nothing is recognized, maybe go back to listening or dismiss
                // For now, let's just dismiss the sheet (handled by SheetView's dismiss button)
            }
        }
    }

    /// 음성 인식 과정을 모의(mock)합니다.
    /// 이 함수는 TTS를 통해 주어진 텍스트를 말하는 것을 시뮬레이션한 후,
    /// 짧은 지연 시간(듣는 것을 모방하기 위함) 후에 하드코딩된 값 "207"을 반환합니다.
    /// 이는 테스트 목적으로 사용자가 "207"을 말한 것처럼 시뮬레이션하기 위함입니다.
    ///
    /// - Parameter text: "듣기" 전에 TTS를 통해 "말할" 텍스트입니다.
    /// - Returns: 모의로 인식된 문자열로, 이 모의 구현에서는 항상 "207"입니다.
    private func speakAndListenMock(text: String) async -> String? {
        // TTS 말하기 시뮬레이션
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR") // 한국어 음성
        utterance.rate = 0.5 // 말하기 속도 조절
        synthesizer.speak(utterance)

        // 듣는 시간 시뮬레이션 (3초 지연)
        try? await Task.sleep(nanoseconds: 3_000_000_000)

        // TTS가 여전히 말하고 있다면 중지 (예: 텍스트가 매우 길었을 경우)
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        // 모의로 인식된 값 반환
        return "207"
    }

    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
