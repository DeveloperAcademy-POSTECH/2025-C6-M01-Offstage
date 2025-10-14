import Foundation

/// 버스 공공데이터 API 호출을 담당하는 간단한 HTTP 클라이언트입니다.
struct BusAPIClient {
    /// URL 인코딩된 서비스 키입니다.
    let serviceKey: String
    /// 테스트 환경에서도 재사용할 `URLSession` 인스턴스입니다.
    let session: URLSession = .shared

    /// 지정된 제네릭 타입을 직접 전달해 API를 호출합니다.
    /// - Parameters:
    ///   - service: 공공데이터 서비스명입니다.
    ///   - method: 서비스 내 메서드명입니다.
    ///   - queries: 추가할 쿼리 파라미터 목록입니다.
    /// - Returns: 디코딩된 응답과 호출된 URL을 반환합니다.
    func request<T: Decodable>(
        service: String,
        method: String,
        queries: [URLQueryItem]
    ) async throws -> (APIEnvelope<T>, URL) {
        let url = try makeURL(service: service, method: method, queries: queries)
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(APIEnvelope<T>.self, from: data)
        return (decoded, url)
    }

    /// `BusAPIRequest` 프로토콜을 따르는 요청을 실행합니다.
    /// - Parameter request: 호출하려는 요청 모델입니다.
    /// - Returns: 디코딩된 응답과 호출된 URL을 반환합니다.
    func request<R: BusAPIRequest>(_ request: R) async throws -> (APIEnvelope<R.Response>, URL) {
        try await self.request(
            service: request.service,
            method: request.method,
            queries: request.queryItems
        )
    }

    /// 공용 URL 조립 로직을 모은 헬퍼입니다.
    private func makeURL(service: String, method: String, queries: [URLQueryItem]) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "apis.data.go.kr"
        components.path = "/1613000/\(service)/\(method)"
        components.queryItems = queries + [
            URLQueryItem(name: "serviceKey", value: serviceKey),
            URLQueryItem(name: "_type", value: "json"),
        ]
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        return url
    }
}
