import Foundation

/// 공공데이터 포털 버스 API의 공통 응답 래퍼입니다.
/// - Note: `response` 키 아래에 `header`와 `body`가 함께 전달됩니다.
struct APIEnvelope<T: Decodable>: Decodable {
    /// 응답 메시지의 헤더 및 본문을 포함한 최상위 객체입니다.
    let response: Response

    /// 헤더와 본문을 나타내는 중첩 타입입니다.
    struct Response: Decodable {
        /// 결과 코드와 메시지를 포함하는 헤더입니다.
        let header: Header
        /// 실제 데이터가 포함되는 본문입니다. 비어 있을 수 있습니다.
        let body: Body?
    }

    /// API 응답 헤더입니다.
    struct Header: Decodable {
        /// API 호출 성공 여부를 나타내는 코드입니다.
        let resultCode: String
        /// 실패 시 제공되는 상세 메시지입니다.
        let resultMsg: String?
    }

    /// 페이징 정보와 결과 항목을 포함하는 본문입니다.
    struct Body: Decodable {
        /// 항목 리스트를 나타내는 컨테이너입니다.
        let items: Items<T>?
        /// 현재 페이지 번호입니다.
        let pageNo: Int?
        /// 페이지당 항목 수입니다.
        let numOfRows: Int?
        /// 전체 항목 수입니다.
        let totalCount: Int?
    }

    /// 하나의 항목 또는 다수의 항목을 포괄적으로 표현하는 컨테이너입니다.
    struct Items<U: Decodable>: Decodable {
        /// 응답에서 파싱된 항목 배열입니다.
        let item: [U]

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let array = try? container.decode([U].self) {
                item = array
                return
            }
            if let single = try? container.decode(U.self) {
                item = [single]
                return
            }
            item = []
        }
    }
}
