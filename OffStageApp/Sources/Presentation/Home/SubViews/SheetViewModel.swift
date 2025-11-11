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
    @Published var isAnimating: Bool = false
    @Published var currentSheetState: SheetState = .listening
    @Published var recognizedBusNumber: String? = nil
    @Published var currentBusStop: BusStop? = nil

    private let synthesizer = AVSpeechSynthesizer()

    init() {}

    func startListeningAnimation() {
        isAnimating = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.isAnimating = true
        }
    }

    func stopListeningAnimation() {
        isAnimating = false
    }

    func startListeningProcess() {
        startListeningAnimation()
        currentSheetState = .listening
        Task {
            if let recognizedText = await speakAndListenMock(text: "번호를 말씀해주세요.") {
                self.recognizedBusNumber = recognizedText
                currentSheetState = .confirmation(recognizedBusNumber: recognizedText)
            } else {
                // Handle case where nothing is recognized
            }
        }
    }

    func showBusRouteList(routes: [BusRoute]) {
        currentSheetState = .busRouteList(routes)
    }

    private func speakAndListenMock(text: String) async -> String? {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = 0.5
        synthesizer.speak(utterance)

        try? await Task.sleep(nanoseconds: 3_000_000_000)

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        return "9007"
    }

    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
