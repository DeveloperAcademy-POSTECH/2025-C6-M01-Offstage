//
//  TiltDataCollector.swift
//  Chalkak
//
//  Created by 석민솔 on 7/14/25.
//

import CoreMotion
import Foundation

/**
 CoreMotion 데이터를 수집하는 클래스
 
 `TiltDataCollector`는 디바이스의 물리적 기울기를 감지하여 중력 벡터 데이터를 수집합니다.
 
 ## 사용 예시
 ```swift
 @StateObject private var tiltCollector = TiltDataCollector()
 
 var body: some View {
     Text("z: \(tiltCollector.gravityZ)")
 }
 ```
 */
class TiltDataCollector: ObservableObject {
    // MARK: - Properties
    /// CoreMotion 데이터를 수집하는 모션 매니저
    private var motionManager = CMMotionManager()

    /// 디바이스가 앞뒤로 기울어진 정도
    @Published var gravityZ: Double = 0.0

    // MARK: - init
    /// TiltDataCollector를 초기화하고 CoreMotion 데이터 수집을 시작합니다.
    init() {
        // 디바이스 모션 업데이트 시작
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 24.0  // 1초에 24번(24FPS)
            motionManager.startDeviceMotionUpdates(to: .main) {
                [weak self] (data, error) in
                guard let self = self, let data = data else { return }

                self.gravityZ = data.gravity.z
            }
        }
    }
    
    /// TiltDataCollector가 해제될 때 motion updates를 자동으로 중지하도록 처리
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}
