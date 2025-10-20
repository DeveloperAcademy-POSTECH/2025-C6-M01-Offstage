import Foundation

public extension KeyedDecodingContainer {
    func decodeFlexibleString(forKey key: Key, fallbackKeys: [Key] = []) throws -> String {
        if let value = decodeOptionalFlexibleString(forKey: key, fallbackKeys: fallbackKeys) {
            return value
        }
        throw DecodingError.valueNotFound(
            String.self,
            .init(
                codingPath: codingPath + [key],
                debugDescription: "Expected String value for \(key.stringValue)"
            )
        )
    }

    func decodeOptionalFlexibleString(forKey key: Key, fallbackKeys: [Key] = []) -> String? {
        for candidate in [key] + fallbackKeys {
            if let raw: String = decodeLossyIfPresent(String.self, forKey: candidate) {
                let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    return trimmed
                }
            }
            if let intValue: Int = decodeLossyIfPresent(Int.self, forKey: candidate) {
                return String(intValue)
            }
            if let doubleValue: Double = decodeLossyIfPresent(Double.self, forKey: candidate) {
                return String(doubleValue)
            }
        }
        return nil
    }

    func decodeFlexibleInt(forKey key: Key, fallbackKeys: [Key] = []) throws -> Int {
        if let value = decodeOptionalFlexibleInt(forKey: key, fallbackKeys: fallbackKeys) {
            return value
        }
        throw DecodingError.valueNotFound(
            Int.self,
            .init(
                codingPath: codingPath + [key],
                debugDescription: "Expected Int value for \(key.stringValue)"
            )
        )
    }

    func decodeOptionalFlexibleInt(forKey key: Key, fallbackKeys: [Key] = []) -> Int? {
        for candidate in [key] + fallbackKeys {
            if let intValue: Int = decodeLossyIfPresent(Int.self, forKey: candidate) {
                return intValue
            }
            if let stringValue: String = decodeLossyIfPresent(String.self, forKey: candidate) {
                let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if let value = Int(trimmed) {
                    return value
                }
            }
            if let doubleValue: Double = decodeLossyIfPresent(Double.self, forKey: candidate) {
                return Int(doubleValue)
            }
        }
        return nil
    }

    func decodeFlexibleDouble(forKey key: Key, fallbackKeys: [Key] = []) throws -> Double {
        if let value = decodeOptionalFlexibleDouble(forKey: key, fallbackKeys: fallbackKeys) {
            return value
        }
        throw DecodingError.valueNotFound(
            Double.self,
            .init(
                codingPath: codingPath + [key],
                debugDescription: "Expected Double value for \(key.stringValue)"
            )
        )
    }

    func decodeOptionalFlexibleDouble(forKey key: Key, fallbackKeys: [Key] = []) -> Double? {
        for candidate in [key] + fallbackKeys {
            if let doubleValue: Double = decodeLossyIfPresent(Double.self, forKey: candidate) {
                return doubleValue
            }
            if let stringValue: String = decodeLossyIfPresent(String.self, forKey: candidate) {
                let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if let value = Double(trimmed) {
                    return value
                }
            }
            if let intValue: Int = decodeLossyIfPresent(Int.self, forKey: candidate) {
                return Double(intValue)
            }
        }
        return nil
    }

    private func decodeLossyIfPresent<T: Decodable>(_ type: T.Type, forKey key: Key) -> T? {
        (try? decodeIfPresent(type, forKey: key)) ?? nil
    }
}
