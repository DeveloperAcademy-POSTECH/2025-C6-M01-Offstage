import Foundation

public struct BusAPIHeader: Decodable {
    public let resultCode: String
    public let resultMessage: String

    public var isSuccess: Bool {
        resultCode == "00"
    }

    private enum CodingKeys: String, CodingKey {
        case resultCode
        case resultMessage = "resultMsg"
    }
}

public struct BusAPIEnvelope<Item: Decodable>: Decodable {
    public let header: BusAPIHeader
    public let items: [Item]
    public let pagination: Pagination?

    public struct Pagination: Decodable {
        public let numOfRows: Int?
        public let pageNo: Int?
        public let totalCount: Int?

        fileprivate init(container: KeyedDecodingContainer<BodyKeys>) {
            numOfRows = container.decodeOptionalFlexibleInt(forKey: .numOfRows, fallbackKeys: [.numOfROWs])
            pageNo = container.decodeOptionalFlexibleInt(forKey: .pageNo)
            totalCount = container.decodeOptionalFlexibleInt(forKey: .totalCount)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case response
    }

    private enum ResponseKeys: String, CodingKey {
        case header
        case body
    }

    /// TestCode를 위해 public으로 선언
    public enum BodyKeys: String, CodingKey {
        case items
        case numOfRows
        case numOfROWs
        case pageNo
        case totalCount
    }

    private enum ItemsKeys: String, CodingKey {
        case item
    }

    public init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        let response = try root.nestedContainer(keyedBy: ResponseKeys.self, forKey: .response)
        header = try response.decode(BusAPIHeader.self, forKey: .header)

        if let body = try? response.nestedContainer(keyedBy: BodyKeys.self, forKey: .body) {
            pagination = Pagination(container: body)
            if let items = try? body.nestedContainer(keyedBy: ItemsKeys.self, forKey: .items) {
                self.items = try BusAPIEnvelope.decodeItems(from: items)
            } else {
                items = []
            }
        } else {
            pagination = nil
            items = []
        }
    }

    private static func decodeItems(from container: KeyedDecodingContainer<ItemsKeys>) throws -> [Item] {
        if let single = try? container.decode(Item.self, forKey: .item) {
            return [single]
        }
        if let array = try? container.decode([Item].self, forKey: .item) {
            return array
        }
        return []
    }
}
