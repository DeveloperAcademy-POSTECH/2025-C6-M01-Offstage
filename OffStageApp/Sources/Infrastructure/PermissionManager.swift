import AVFoundation
import Combine
import CoreLocation
import Speech
import UIKit
import UserNotifications

// MARK: - Permission Type

enum PermissionType: String, CaseIterable {
    case location = "위치"
    case camera = "카메라"
    case microphone = "마이크"
    case speech = "음성 인식"

    var description: String {
        switch self {
        case .location:
            "현재 위치를 기반으로 주변 정류장 정보를 제공합니다."
        case .camera:
            "버스 번호를 인식하여 자동으로 검색합니다."
        case .microphone:
            "음성으로 정류장을 검색할 수 있습니다."
        case .speech:
            "음성을 텍스트로 변환하여 검색합니다."
        }
    }
}

// MARK: - Permission Manager

// 각종 시스템 권한(알림, 위치, 카메라, 마이크, 음성인식)을 한 번에 요청하는 클래스
final class PermissionManager: NSObject, ObservableObject {
    // CLLocationManager 인스턴스 (위치 권한 요청용)
    private var locationManager: CLLocationManager?
    // 위치 권한 요청 시 async/await 비동기 처리를 위한 continuation 저장소
    private var locationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    // 거부된 권한 목록
    @Published var deniedPermissions: [PermissionType] = []
    // Sheet 표시 여부
    @Published var showPermissionDeniedSheet: Bool = false

    // MARK: - 모든 권한 한꺼번에 요청

    @MainActor
    func requestAll() async {
        // 거부된 권한 초기화
        deniedPermissions.removeAll()

        // 1. 위치
        let locationStatus = await requestLocation()
        if locationStatus == .denied || locationStatus == .restricted {
            deniedPermissions.append(.location)
        }

        // 2. 카메라
        let cameraGranted = await requestCamera()
        if !cameraGranted {
            deniedPermissions.append(.camera)
        }

        // 3. 마이크
        let microphoneGranted = await requestMicrophone()
        if !microphoneGranted {
            deniedPermissions.append(.microphone)
        }

        // 4. 음성 인식
        let speechStatus = await requestSpeech()
        if speechStatus != .authorized {
            deniedPermissions.append(.speech)
        }

        // 거부된 권한이 있으면 Sheet 표시
        if !deniedPermissions.isEmpty {
            showPermissionDeniedSheet = true
        }
    }

    // MARK: - 모든 권한 승인 여부 확인 (재요청 없이 현재 상태만 체크)

    @MainActor
    func checkAllPermissionsGranted() async -> Bool {
        deniedPermissions.removeAll()

        // 1. 위치
        let locationStatus = CLLocationManager.authorizationStatus()
        if locationStatus == .denied || locationStatus == .restricted || locationStatus == .notDetermined {
            deniedPermissions.append(.location)
        }

        // 2. 카메라
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraStatus != .authorized {
            deniedPermissions.append(.camera)
        }

        // 3. 마이크
        let microphoneStatus = AVAudioSession.sharedInstance().recordPermission
        if microphoneStatus != .granted {
            deniedPermissions.append(.microphone)
        }

        // 4. 음성 인식
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        if speechStatus != .authorized {
            deniedPermissions.append(.speech)
        }

        // 거부된 권한이 있으면 Sheet 표시, 없으면 Sheet 닫기
        if !deniedPermissions.isEmpty {
            showPermissionDeniedSheet = true
            return false
        } else {
            showPermissionDeniedSheet = false
            return true
        }
    }

    func grantedPermissions() -> [PermissionType] {
        let allPermissions: [PermissionType] = [.location, .camera, .microphone, .speech]
        return allPermissions.filter { !deniedPermissions.contains($0) }
    }

    func isGranted(_ permission: PermissionType) -> Bool {
        switch permission {
        case .location:
            let status = CLLocationManager.authorizationStatus()
            return status == .authorizedWhenInUse || status == .authorizedAlways
        case .camera:
            return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        case .microphone:
            return AVAudioSession.sharedInstance().recordPermission == .granted
        case .speech:
            return SFSpeechRecognizer.authorizationStatus() == .authorized
        }
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
