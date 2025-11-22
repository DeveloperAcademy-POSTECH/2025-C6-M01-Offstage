import Combine
import CoreLocation
import Foundation

/// 백그라운드에서 위치를 추적하여 최신 위치를 UserDefaults에 저장하는 매니저
@MainActor
final class BackgroundLocationManager: NSObject, ObservableObject {
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()

    private let lastLocationKey = "lastKnownLocation"
    private let lastLocationTimestampKey = "lastKnownLocationTimestamp"

    @Published var isTracking = false

    override init() {
        super.init()
        setupLocationSubscription()
    }

    private func setupLocationSubscription() {
        locationManager.currentLocation
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("⚠️ Background location error: \(error)")
                    }
                },
                receiveValue: { [weak self] coordinate in
                    self?.saveLocation(coordinate)
                }
            )
            .store(in: &cancellables)
    }

    func startBackgroundTracking() {
        guard !isTracking else { return }

        // Always 권한이 있는지 확인
        let status = CLLocationManager.authorizationStatus()
        guard status == .authorizedAlways else {
            print("⚠️ Background location requires 'Always' authorization")
            return
        }

        isTracking = true
        locationManager.startBackgroundLocationUpdates()
        print("✅ Started background location tracking")
    }

    func stopBackgroundTracking() {
        guard isTracking else { return }

        isTracking = false
        locationManager.stopBackgroundLocationUpdates()
        print("🛑 Stopped background location tracking")
    }

    private func saveLocation(_ coordinate: CLLocationCoordinate2D) {
        let defaults = UserDefaults.standard
        defaults.set(coordinate.latitude, forKey: "\(lastLocationKey)_latitude")
        defaults.set(coordinate.longitude, forKey: "\(lastLocationKey)_longitude")
        defaults.set(Date().timeIntervalSince1970, forKey: lastLocationTimestampKey)

        print("📍 Saved background location: \(coordinate.latitude), \(coordinate.longitude)")
    }

    static func getLastKnownLocation() -> CLLocationCoordinate2D? {
        let defaults = UserDefaults.standard
        let latitude = defaults.double(forKey: "lastKnownLocation_latitude")
        let longitude = defaults.double(forKey: "lastKnownLocation_longitude")
        let timestamp = defaults.double(forKey: "lastKnownLocationTimestamp")

        // 위치가 저장되지 않았거나 24시간 이상 오래된 경우 nil 반환
        guard latitude != 0, longitude != 0,
              Date().timeIntervalSince1970 - timestamp < 86400
        else {
            return nil
        }

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
