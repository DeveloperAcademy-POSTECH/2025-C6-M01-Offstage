//
//  TiltManager.swift
//  OffStage
//
//  Created by 석민솔 on 11/19/25.
//

import Combine
import Foundation

class TiltManager: ObservableObject {
    // MARK: - Properties
    /// 기준점이 되는 기울기값
    let properTilt: Float
    
    /// 실시간으로 업데이트되는 기울기 값
    @Published var degreeTilt: Float = 0 {
        didSet {
            self.offsetZ = (degreeTilt - properTilt)
        }
    }
        
    /// UI 표시용 앞뒤 오프셋 값
    @Published var offsetZ: Float = 0
    
    /// Combine 구독을 관리하는 Set
    private var cancellables = Set<AnyCancellable>()
        
    // MARK: - init
    
    /// - Parameters:
    ///   - properTilt: 기준점이 되는 기울기값. 기본값은 (degreeX: 0.0, degreeZ: 0.0)입니다.
    ///   - dataCollector: 기울기 데이터를 제공하는 `TiltDataCollector` 인스턴스
    ///
    /// ## 중요사항
    /// - `dataCollector`는 이미 초기화되고 데이터 수집이 시작된 상태여야 합니다.
    /// - 초기 오프셋 값은 현재 기울기 값과 기준점의 차이로 계산됩니다.
    init(
        properTilt: Float = 90,
        dataCollector: TiltDataCollector
    ) {
        self.properTilt = properTilt
                
        dataCollector.$gravityZ
            .map { Float($0)}
            .assign(to: \.degreeTilt, on: self)
            .store(in: &cancellables)
        
        // 초기 오프셋 값 계산
        self.offsetZ = Float(degreeTilt - properTilt) * 100
    }
}
