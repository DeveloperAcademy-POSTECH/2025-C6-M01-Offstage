import BusAPI
import Combine
import CoreLocation
import Foundation

@MainActor
final class BusStopSelectionViewModel: ObservableObject {
    // MARK: - Published Properties (UI에서 관찰하는 상태 변수들)

    /// 근처 정류장 리스트 - UI에서 이 배열을 사용해 List를 표시합니다
    @Published var nearbyStops: [BusStop] = []

    /// 로딩 상태 - true일 때 ProgressView를 보여줍니다
    @Published var isLoading = false

    /// 에러 메시지 - nil이 아니면 에러 화면을 표시합니다
    @Published var errorMessage: String?

    // MARK: - Private Properties

    /// 위치 정보를 가져오는 Provider (현재 GPS 좌표를 얻기 위함)
    private var locationProvider: LocationProviding

    /// 버스 API 호출을 담당하는 Repository
    private let busRepository = MainBusRepository()

    // MARK: - Initializer

    /// ViewModel 초기화 - 의존성 주입을 통해 테스트 가능하도록 설계
    /// - Parameter locationProvider: 위치 정보 제공자 (기본값: LocationManager)
    init(locationProvider: LocationProviding = LocationManager()) {
        self.locationProvider = locationProvider
    }

    // MARK: - Private Methods

    /// GPS 좌표를 기반으로 도시 코드를 감지합니다
    /// - Parameter gps: 위도/경도 좌표
    /// - Returns: 감지된 도시 코드 문자열 (예: "31020" - 성남시)
    /// - Throws: Placemark를 가져오지 못하면 BusAPIError 발생
    private func detectCityCode(from gps: CLLocationCoordinate2D) async throws -> String {
        // GPS 좌표로부터 주소 정보(Placemark) 가져오기
        guard let placemark = try await locationProvider.fetchPlacemark(from: gps) else {
            throw BusAPIError.unknown("Failed to fetch placemark for city code detection.")
        }

        // Placemark에서 도시 코드를 추출 (실패 시 성남시 코드를 기본값으로 사용)
        let detectedCityCode = CityCodeConverter.findCode(from: placemark) ?? "31020"
        return detectedCityCode
    }

    // MARK: - Public Methods

    /// 현재 위치 기반으로 근처 정류장을 가져옵니다
    /// TestViewModel의 testSeoulGpsSearch()와 getStopsByGPS()를 참고하여 구현
    func fetchNearbyStops() {
        Task {
            // 로딩 시작
            isLoading = true
            errorMessage = nil

            // defer: 함수가 끝날 때 항상 실행됨 (성공/실패 관계없이 로딩 종료)
            defer { isLoading = false }

            do {
                // 1. 현재 위치 가져오기 (LocationProvider 사용)
                let location = try await locationProvider.requestLocation()

                // 2. CLLocationCoordinate2D 형식으로 변환
                let coordinate = CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                )

                // 3. GPS 좌표로부터 도시 코드 감지 (예: 성남 = "31020", 서울 = "1000")
                let cityCodeString = try await detectCityCode(from: coordinate)

                // 4. Bus API 호출: 근처 정류장 가져오기
                // TestViewModel의 getStopsByGPS()와 동일한 API 사용
                let stops = try await busRepository.fetchStopsNearby(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    cityCode: cityCodeString
                )

                // 5. 성공: 정류장 리스트 업데이트
                nearbyStops = stops

            } catch {
                // 6. 실패: 에러 처리
                print("Error fetching nearby stops: \(error)")
                errorMessage = "근처 정류장을 불러오는데 실패했습니다."
                nearbyStops = []
            }
        }
    }
}
