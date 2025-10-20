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

        guard let body = try? response.nestedContainer(keyedBy: BodyKeys.self, forKey: .body) else {
            pagination = nil
            items = []
            return
        }

        pagination = Pagination(container: body)

        guard body.contains(.items) else {
            items = []
            return
        }

        if let nested = try? body.nestedContainer(keyedBy: ItemsKeys.self, forKey: .items) {
            items = try BusAPIEnvelope.decodeNestedItems(from: nested)
        } else if var unkeyed = try? body.nestedUnkeyedContainer(forKey: .items) {
            items = try BusAPIEnvelope.decodeItemsArray(from: &unkeyed)
        } else if let single = try? body.decode(Item.self, forKey: .items) {
            items = [single]
        } else {
            items = []
        }
    }

    private static func decodeNestedItems(from container: KeyedDecodingContainer<ItemsKeys>) throws -> [Item] {
        if let single = try? container.decode(Item.self, forKey: .item) {
            return [single]
        }
        if let array = try? container.decode([Item].self, forKey: .item) {
            return array
        }

        if var unkeyed = try? container.nestedUnkeyedContainer(forKey: .item) {
            return try decodeItemsArray(from: &unkeyed)
        }

        return []
    }

    private static func decodeItemsArray(from container: inout UnkeyedDecodingContainer) throws -> [Item] {
        var decoded: [Item] = []
        while !container.isAtEnd {
            let elementDecoder = try container.superDecoder()
            if let element = try? Item(from: elementDecoder) {
                decoded.append(element)
            } else {
                _ = try? Discardable(from: elementDecoder)
            }
        }
        return decoded
    }
}

private struct Discardable: Decodable {
    init(from decoder: Decoder) throws {
        if var array = try? decoder.unkeyedContainer() {
            while !array.isAtEnd {
                _ = try? array.decode(Discardable.self)
            }
            return
        }

        if var container = try? decoder.container(keyedBy: AnyCodingKey.self) {
            for key in container.allKeys {
                _ = try? container.decode(Discardable.self, forKey: key)
            }
            return
        }

        _ = try? decoder.singleValueContainer()
    }
}

private struct AnyCodingKey: CodingKey {
    var stringValue: String
    init?(stringValue: String) { self.stringValue = stringValue }

    var intValue: Int?
    init?(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }

    init(_ key: CodingKey) {
        stringValue = key.stringValue
        intValue = key.intValue
    }
}
