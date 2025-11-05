import CoreLocation // CLPlacemark를 사용하기 위해 import
import Foundation

public enum CityCodeConverter {
    /// CLPlacemark에서 cityCode(String)를 찾습니다.
    /// 서울은 "1000", 그 외 지역은 `nil`을 반환합니다.
    public static func findCode(from placemark: CLPlacemark) -> String? {
        guard let adminArea = placemark.administrativeArea else { return nil }

        // 1. 서울특별시 확인
        if adminArea.contains("서울") || adminArea.contains("Seoul") {
            return "1000" // 서울시 고정 코드
        }

        return nil // 서울이 아닌 경우 nil
    }
}
