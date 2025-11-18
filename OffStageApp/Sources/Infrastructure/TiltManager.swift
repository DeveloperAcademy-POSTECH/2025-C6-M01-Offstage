import Combine
import Foundation

class TiltManager: ObservableObject {
    // MARK: - Properties

    /// 기준점이 되는 기울기값
    let properTilt: Float = 0.1

    /// 실시간으로 업데이트되는 기울기 값
    @Published var degreeTilt: Float = 0 {
        didSet {
            offsetZ = abs(degreeTilt - properTilt)
            checkTiltFeedback()
        }
    }

    /// UI 표시용 앞뒤 오프셋 값
    /// - 추후 햅틱 강도로 활용을 기대해보는 중
    @Published var offsetZ: Float = 0

    /// Combine 구독을 관리하는 Set
    private var cancellables = Set<AnyCancellable>()

    /// 현재 기울기 상태
    var tiltState: TiltState {
        let tolerance: Float = 0.15
        let tiltDifference = degreeTilt - properTilt

        if tiltDifference > tolerance {
            return .backward
        } else if tiltDifference < -tolerance {
            return .forward
        } else {
            return .normal
        }
    }

    // MARK: - init

    /// - Parameters:
    ///   - properTilt: 기준점이 되는 기울기값. 기본값은 (degreeX: 0.0, degreeZ: 0.0)입니다.
    ///   - dataCollector: 기울기 데이터를 제공하는 `TiltDataCollector` 인스턴스
    ///
    /// ## 중요사항
    /// - `dataCollector`는 이미 초기화되고 데이터 수집이 시작된 상태여야 합니다.
    /// - 초기 오프셋 값은 현재 기울기 값과 기준점의 차이로 계산됩니다.
    init(
        dataCollector: TiltDataCollector
    ) {
        dataCollector.$gravityZ
            .map { Float($0) }
            .assign(to: \.degreeTilt, on: self)
            .store(in: &cancellables)

        // 초기 오프셋 값 계산
        offsetZ = abs(degreeTilt - properTilt)
    }

    // MARK: - Methods

    /// 기울기에 따른 피드백 로그를 출력합니다
    private func checkTiltFeedback() {
        switch tiltState {
        case .backward:
            print("뒤로 기울이세요")
        case .forward:
            print("앞으로 기울이세요")
        case .normal:
            break
        }
    }
}

/// 기울기 상태를 나타내는 열거형
enum TiltState {
    case forward // 앞으로 기울어짐
    case backward // 뒤로 기울어짐
    case normal // 정상 범위
}
