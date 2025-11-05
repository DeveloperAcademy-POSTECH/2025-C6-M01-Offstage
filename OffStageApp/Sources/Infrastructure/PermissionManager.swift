import AVFoundation
import Combine
import CoreLocation
import Speech
import UIKit
import UserNotifications

// MARK: - Permission Manager

// 각종 시스템 권한(알림, 위치, 카메라, 마이크, 음성인식)을 한 번에 요청하는 클래스
final class PermissionManager: NSObject, ObservableObject {
    // CLLocationManager 인스턴스 (위치 권한 요청용)
    private var locationManager: CLLocationManager?
    // 위치 권한 요청 시 async/await 비동기 처리를 위한 continuation 저장소
    private var locationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    // MARK: - 모든 권한 한꺼번에 요청

    @MainActor
    func requestAll() async {
        // 각각의 권한 요청을 동시에 비동기로 수행
        _ = await requestLocation() // 1. 위치
        _ = await requestCamera() // 2. 카메라
        _ = await requestMicrophone() // 3. 마이크
        _ = await requestSpeech() // 4. 음성 인식
    }

    // MARK: - 알림 권한 요청

    private func requestNotifications() async -> Bool {
        let center = UNUserNotificationCenter.current()
        // 비동기적으로 사용자에게 알림 권한 요청
        let granted = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            center.requestAuthorization(options: [.alert, .badge, .sound]) { ok, _ in
                cont.resume(returning: ok)
            }
        }
        // 권한이 허용되면 원격 알림 등록
        if granted {
            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        return granted
    }

    // MARK: - 위치 권한 요청 (WhenInUse)

    private func requestLocation() async -> CLAuthorizationStatus {
        // CLLocationManager 생성 및 delegate 지정
        await MainActor.run {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.requestWhenInUseAuthorization()
        }

        // 사용자가 응답할 때까지 suspension
        return await withCheckedContinuation { (cont: CheckedContinuation<CLAuthorizationStatus, Never>) in
            self.locationContinuation = cont
        }
    }

    // MARK: - 카메라 권한 요청

    private func requestCamera() async -> Bool {
        await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                cont.resume(returning: granted)
            }
        }
    }

    // MARK: - 마이크 권한 요청

    private func requestMicrophone() async -> Bool {
        await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                cont.resume(returning: granted)
            }
        }
    }

    // MARK: - 음성 인식 권한 요청

    private func requestSpeech() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { (cont: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension PermissionManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let cont = locationContinuation else { return }
        locationContinuation = nil
        cont.resume(returning: manager.authorizationStatus)
    }
}
