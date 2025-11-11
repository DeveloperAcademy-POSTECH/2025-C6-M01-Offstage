import Combine
import CoreLocation
import Foundation

/// A concrete implementation of the `LocationProviding` protocol using Apple's CoreLocation framework.
///
/// This class is part of the Infrastructure layer and is responsible for all interactions
/// with the `CLLocationManager` system API.
final class LocationManager: NSObject, LocationProviding {
    /// 전역 접근용 shared 인스턴스. 앱 내 DI가 아직 단일 인스턴스를 사용하지 않는 곳이 있어
    /// Debug 토글에서 동일한 인스턴스에 접근하기 위해 제공합니다.
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    // CurrentValueSubject을 사용하여 최신 위치(모의 또는 실제)를 저장합니다.
    // 이렇게 하면 토글로 mock을 켠 뒤 화면을 갱신하지 않아도 새로운 구독자(예: LegacySearchViewModel)
    // 가 즉시 마지막 위치를 받을 수 있습니다.
    private let subject = CurrentValueSubject<LocationCoordinate?, Error>(nil)

    lazy var currentLocation: AnyPublisher<LocationCoordinate, Error> = subject
        .compactMap { $0 }
        .eraseToAnyPublisher()

    // [추가] Reverse Geocoding을 위한 지오코더
    private let geocoder = CLGeocoder()

    #if DEBUG
        // Debug: 강제 좌표를 외부에서 설정할 수 있도록 최소한의 상태만 유지
        private let suyuCoordinate = LocationCoordinate(latitude: 37.6371095, longitude: 127.0247325)
        private let daeguUniversityCoordinate = LocationCoordinate(latitude: 35.8990476, longitude: 128.8437207)
        private var mockCoordinate: LocationCoordinate?
        private(set) var isMockLocationEnabled = false

        /// UserDefaults key for persisted debug selection
        private static let debugSelectionKey = "Debug.MockLocationType"

        enum MockType: String {
            case none
            case suyu
            case daegu
        }

        /// Debug 빌드에서만 사용 가능한 모의 위치 설정 API (최소화)
        /// - Parameters:
        ///   - enabled: 모의 위치 사용 여부
        ///   - coordinate: nil이면 이전에 설정한 mockCoordinate를 사용합니다. 값이 주어지면 해당 좌표로 변경합니다.
        func setMockLocationEnabled(_ enabled: Bool, coordinate: LocationCoordinate? = nil) {
            isMockLocationEnabled = enabled
            if enabled {
                if let coordinate {
                    mockCoordinate = coordinate
                }
                if let toSend = mockCoordinate {
                    subject.send(toSend)
                }
            } else {
                mockCoordinate = nil
            }
        }

        /// Apply persisted debug selection (called from init)
        private func applyPersistedDebugSelection() {
            guard let raw = UserDefaults.standard.string(forKey: Self.debugSelectionKey),
                  let type = MockType(rawValue: raw) else { return }
            switch type {
            case .suyu:
                setMockLocationEnabled(true, coordinate: suyuCoordinate)
            case .daegu:
                setMockLocationEnabled(true, coordinate: daeguUniversityCoordinate)
            case .none:
                setMockLocationEnabled(false)
            }
        }
    #endif

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        #if DEBUG
            // 앱 시작 시 이전에 선택한 디버그 모의 위치가 있으면 적용
            applyPersistedDebugSelection()
        #endif
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    // [추가] 프로토콜 함수 구현
    func fetchPlacemark(from location: LocationCoordinate) async throws -> CLPlacemark? {
        let clLocation = CLLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )

        // 로케일을 "ko-KR"로 설정하여 주소를 한국어로 받습니다.
        let placemarks = try await geocoder.reverseGeocodeLocation(
            clLocation,
            preferredLocale: Locale(identifier: "ko-KR")
        )
        return placemarks.first
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            // TODO: Handle location access denial. Maybe publish an error.
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        #if DEBUG
            if isMockLocationEnabled {
                if let mock = mockCoordinate {
                    subject.send(mock)
                    return
                }
                return
            }
        #endif
        guard let location = locations.last else { return }
        let coordinate = LocationCoordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        subject.send(coordinate)
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        subject.send(completion: .failure(error))
    }
}
