import Foundation

// MARK: - Flexible Decodable Wrappers

/// A property wrapper for non-optional Strings that can be decoded from a String, Int, or Double.
@propertyWrapper
public struct FlexibleStringDecodable: Codable, Hashable {
    public var wrappedValue: String

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            wrappedValue = stringValue
        } else if let intValue = try? container.decode(Int.self) {
            wrappedValue = String(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            wrappedValue = String(doubleValue)
        } else {
            throw DecodingError.typeMismatch(FlexibleStringDecodable.self, .init(
                codingPath: decoder.codingPath,
                debugDescription: "Wrapped value is not a String, Int, or Double"
            ))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

/// A property wrapper for optional Strings that can be decoded from a String, Int, Double, or null.
@propertyWrapper
public struct OptionalFlexibleStringDecodable: Codable, Hashable {
    public var wrappedValue: String?

    public init(wrappedValue: String?) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            if let stringValue = try? container.decode(String.self) {
                wrappedValue = stringValue
            } else if let intValue = try? container.decode(Int.self) {
                wrappedValue = String(intValue)
            } else if let doubleValue = try? container.decode(Double.self) {
                wrappedValue = String(doubleValue)
            } else {
                wrappedValue = nil
            }
        } else {
            wrappedValue = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}
