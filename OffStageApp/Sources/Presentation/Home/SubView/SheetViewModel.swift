import AVFoundation
import BusAPI
import Foundation

@MainActor
class SheetViewModel: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    private let sttManager = STTManager()
    private var audioPlayer: AVAudioPlayer?
    private var onTextRecognized: ((String) -> Void)?

    init(onTextRecognized: @escaping (String) -> Void) {
        self.onTextRecognized = onTextRecognized
    }

    func startListeningProcess() {
        Task {
            if let recognizedText = await startSpeechRecognition() {
                let processedText = recognizedText.normalizeBusNumber()
                onTextRecognized?(processedText)
            }
        }
    }

    private func startSpeechRecognition() async -> String? {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try? audioSession.setActive(true)

        playSound(named: "onsound")

        let recognizedText = await sttManager.listenUntilFinalResult()

        playSound(named: "offsound")

        return recognizedText
    }

    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        // ✅ 추가: STT도 함께 중지
        sttManager.stopListening()
    }

    private func playSound(named: String) {
        guard let url = Bundle.main.url(forResource: named, withExtension: "mp3") else {
            print("⚠️ Sound file not found: \(named)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("⚠️ Error playing sound: \(error)")
        }
    }
}
