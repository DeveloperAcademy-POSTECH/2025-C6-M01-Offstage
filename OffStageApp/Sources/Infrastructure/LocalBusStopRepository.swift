import BusAPI
import Foundation
import GRDB

// MARK: - LocalBusStopRepository

/// 로컬 버스 정류장 데이터베이스(`BusStops.sqlite`)에 접근하여 정류소 정보를 조회하는 리포지토리입니다.
public final class LocalBusStopRepository {
    private let dbQueue: DatabaseQueue

    /// 리포지토리를 초기화하고 데이터베이스 연결을 설정합니다.
    /// - Throws: 데이터베이스 파일을 찾을 수 없거나 연결에 실패할 경우 오류를 발생시킵니다.
    public init() throws {
        guard let dbPath = Bundle.main.path(forResource: "BusStops", ofType: "sqlite") else {
            throw LocalBusStopRepositoryError.databaseNotFound
        }
        dbQueue = try DatabaseQueue(path: dbPath)
    }

    /// 정류소 이름으로 정류소를 검색하고, 결과를 페이지네이션하여 반환합니다.
    /// - Parameters:
    ///   - name: 검색할 정류소 이름.
    ///   - page: 불러올 페이지 번호 (1부터 시작).
    ///   - pageSize: 한 페이지에 포함될 결과의 수.
    /// - Returns: 검색된 `BusStop` 객체의 배열.
    public func searchStops(byName name: String, page: Int, pageSize: Int = 15) async throws -> [BusStop] {
        let searchPattern = "%\(name)%"
        let offset = (page - 1) * pageSize
        return try await dbQueue.read { db in
            try BusStop.fetchAll(
                db,
                sql: "SELECT * FROM stops WHERE nodenm LIKE ? ORDER BY nodenm LIMIT ? OFFSET ?",
                arguments: [searchPattern, pageSize, offset]
            )
        }
    }

    /// 지정된 좌표 주변의 정류소를 검색하고, 결과를 페이지네이션하여 반환합니다.
    /// - Parameters:
    ///   - latitude: 중심 위도.
    ///   - longitude: 중심 경도.
    ///   - radiusInMeters: 검색 반경 (미터 단위).
    ///   - page: 불러올 페이지 번호 (1부터 시작).
    ///   - pageSize: 한 페이지에 포함될 결과의 수.
    /// - Returns: 주변에 있는 `BusStop` 객체의 배열.
    public func findNearbyStops(
        latitude: Double,
        longitude: Double,
        radiusInMeters: Int,
        page: Int,
        pageSize: Int = 15
    ) async throws -> [BusStop] {
        // Bounding box로 1차 필터링합니다. 정확한 반경보다 조금 더 넓은 영역을 가져옵니다.
        let fetchFactor = 1.5
        let latDelta = (Double(radiusInMeters) * fetchFactor) / 111_000.0
        let lonDelta = (Double(radiusInMeters) * fetchFactor) / (111_000.0 * cos(latitude * .pi / 180.0))

        let query = """
        SELECT *
        FROM stops
        WHERE gpslati BETWEEN ? AND ? AND gpslong BETWEEN ? AND ?
        """

        let stopsInBoundingBox = try await dbQueue.read { db in
            try BusStop.fetchAll(
                db,
                sql: query,
                arguments: [latitude - latDelta, latitude + latDelta, longitude - lonDelta, longitude + lonDelta]
            )
        }

        // Swift 코드에서 정확한 거리를 계산하고 필터링, 정렬, 페이지네이션을 수행합니다.
        let center = (lat: latitude, lon: longitude)
        let radius = Double(radiusInMeters)

        let stopsWithDistance = stopsInBoundingBox
            .map { stop -> (stop: BusStop, distance: Double) in
                let distance = haversineDistance(from: center, to: (lat: stop.latitude, lon: stop.longitude))
                return (stop, distance)
            }
            .filter { $0.distance <= radius }
            .sorted { $0.distance < $1.distance }

        let startIndex = (page - 1) * pageSize
        guard startIndex < stopsWithDistance.count else {
            return [] // 요청한 페이지가 범위를 벗어남
        }
        let endIndex = min(startIndex + pageSize, stopsWithDistance.count)

        return Array(stopsWithDistance[startIndex ..< endIndex]).map(\.stop)
    }
}

// MARK: - Helper Functions

private func haversineDistance(from: (lat: Double, lon: Double), to: (lat: Double, lon: Double)) -> Double {
    let earthRadius = 6_371_000.0 // 미터
    let lat1 = from.lat * .pi / 180.0
    let lon1 = from.lon * .pi / 180.0
    let lat2 = to.lat * .pi / 180.0
    let lon2 = to.lon * .pi / 180.0

    let dLat = lat2 - lat1
    let dLon = lon2 - lon1

    let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return earthRadius * c
}

// MARK: - LocalBusStopRepositoryError

enum LocalBusStopRepositoryError: Error, LocalizedError {
    case databaseNotFound

    var errorDescription: String? {
        switch self {
        case .databaseNotFound:
            "번들에서 BusStops.sqlite 데이터베이스 파일을 찾을 수 없습니다."
        }
    }
}

// MARK: - BusStop + GRDB

extension BusStop: FetchableRecord {
    /// GRDB를 통해 데이터베이스 레코드에서 `BusStop` 객체를 초기화합니다.
    public init(row: Row) {
        self.init(
            nodeId: row["nodeid"],
            name: row["nodenm"],
            number: row["nodeno"],
            cityCode: row["citycode"],
            direction: nil, // CSV에 방향 정보가 없으므로 nil로 설정
            latitude: row["gpslati"],
            longitude: row["gpslong"]
        )
    }
}
