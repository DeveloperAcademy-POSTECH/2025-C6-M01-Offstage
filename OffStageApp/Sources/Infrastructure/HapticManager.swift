import CoreHaptics

class HapticManager {
    // MARK: - Properties

    // 싱글톤 객체
    static let shared = HapticManager()

    // 핵심 햅틱 엔진
    var hapticEngine: CHHapticEngine?

    // MARK: - init

    private init() {
        createEngine()
    }

    // MARK: - Engine Setup

    func createEngine() {
        // Create and configure a haptic engine.
        do {
            hapticEngine = try CHHapticEngine()
        } catch {
            print("Engine Creation Error: \(error)")
        }

        guard let hapticEngine else {
            print("Failed to create engine!")
            return
        }

        // The stopped handler alerts you of engine stoppage due to external causes.
        hapticEngine.stoppedHandler = { reason in
            print("The engine stopped for reason: \(reason.rawValue)")
            switch reason {
            case .audioSessionInterrupt:
                print("Audio session interrupt")
            case .applicationSuspended:
                print("Application suspended")
            case .idleTimeout:
                print("Idle timeout")
            case .systemError:
                print("System error")
            case .notifyWhenFinished:
                print("Playback finished")
            case .gameControllerDisconnect:
                print("Controller disconnected.")
            case .engineDestroyed:
                print("Engine destroyed.")
            @unknown default:
                print("Unknown error")
            }
        }

        // The reset handler provides an opportunity for your app to restart the engine in case of failure.
        hapticEngine.resetHandler = {
            print("The engine reset --> Restarting now!")
            do {
                try self.hapticEngine?.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
    }

    // private 헬퍼 - 엔진 시작 로직 통합
    private func startEngineIfNeeded() -> Bool {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("이 기기는 햅틱을 지원하지 않습니다")
            return false
        }

        do {
            try hapticEngine?.start()
            return true
        } catch {
            print("엔진 시작 실패: \(error)")
            return false
        }
    }

    // MARK: - Playback

    /// ahap 파일로부터 햅틱 읽어서 재생하기
    func playHapticsFile(named filename: String) {
        guard startEngineIfNeeded() else { return }

        guard let path = Bundle.main.path(forResource: filename, ofType: "ahap") else {
            return
        }

        do {
            try hapticEngine?.playPattern(from: URL(fileURLWithPath: path))

        } catch {
            print("An error occured playing \(filename): \(error).")
        }
    }

    // 단일 햅틱 재생
    func playHaptic(intensity: Float, sharpness: Float, relativeTime: Double = 0, duration: Double) {
        let event = makeHaptic(
            intensity: intensity,
            sharpness: sharpness,
            relativeTime: relativeTime,
            duration: duration
        )
        playHapticPattern(hapticEvents: [event])
    }

    // 패턴 햅틱 재생 (통합 버전)
    func playHapticPattern(hapticEvents: [CHHapticEvent]) {
        guard startEngineIfNeeded() else { return }

        do {
            let pattern = try CHHapticPattern(events: hapticEvents, parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("햅틱 재생 실패: \(error)")
        }
    }

    // MARK: - Helpers

    // public으로 변경 - 외부에서 이벤트 생성 가능하게
    func makeHaptic(intensity: Float, sharpness: Float, relativeTime: Double = 0, duration: Double) -> CHHapticEvent {
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)

        return CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensityParam, sharpnessParam],
            relativeTime: relativeTime,
            duration: duration
        )
    }
}
