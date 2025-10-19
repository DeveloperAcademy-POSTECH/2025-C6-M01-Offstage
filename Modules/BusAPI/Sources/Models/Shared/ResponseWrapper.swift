import Foundation

// MARK: - Generic API Response Wrappers

public struct ApiResponse<T: Codable>: Codable {
    public let response: ResponseBody<T>
}

public struct ResponseBody<T: Codable>: Codable {
    public let header: ResponseHeader
    public let body: T?
}

public struct ResponseHeader: Codable {
    public let resultCode: String
    public let resultMsg: String
}

public struct ItemBody<T: Codable>: Codable {
    public let items: ItemWrapper<T>
    public let numOfRows: Int
    public let pageNo: Int
    public let totalCount: Int

    public init(items: ItemWrapper<T>, numOfRows: Int, pageNo: Int, totalCount: Int) {
        self.items = items
        self.numOfRows = numOfRows
        self.pageNo = pageNo
        self.totalCount = totalCount
    }

    enum CodingKeys: String, CodingKey {
        case items, pageNo, totalCount
        case numOfRows, numOfROWs // all potential keys
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decode(ItemWrapper<T>.self, forKey: .items)
        pageNo = try container.decode(Int.self, forKey: .pageNo)
        totalCount = try container.decode(Int.self, forKey: .totalCount)

        if let numOfRows = try? container.decode(Int.self, forKey: .numOfRows) {
            self.numOfRows = numOfRows
        } else if let numOfRows = try? container.decode(Int.self, forKey: .numOfROWs) {
            self.numOfRows = numOfRows
        } else {
            throw DecodingError.keyNotFound(
                CodingKeys.numOfRows,
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "numOfRows key not found")
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(items, forKey: .items)
        try container.encode(numOfRows, forKey: .numOfRows)
        try container.encode(pageNo, forKey: .pageNo)
        try container.encode(totalCount, forKey: .totalCount)
    }
}

public struct ItemWrapper<T: Codable>: Codable {
    public let item: [T]

    public init(item: [T]) {
        self.item = item
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let singleItem = try? container.decode(T.self, forKey: .item) {
            item = [singleItem]
        } else if let array = try? container.decode([T].self, forKey: .item) {
            item = array
        } else {
            item = []
        }
    }

    private enum CodingKeys: String, CodingKey {
        case item
    }
}
