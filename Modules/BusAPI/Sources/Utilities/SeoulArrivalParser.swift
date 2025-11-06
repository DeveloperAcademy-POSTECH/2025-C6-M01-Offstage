import Foundation

/// Parses Seoul arrival messages such as "3분후[2번째 전]" or "곧 도착" into
/// estimated seconds and remaining stop counts.
public enum SeoulArrivalParser {
    public struct Result {
        public let seconds: Int
        public let remainingStops: Int?
    }

    /// Parse a message string from Seoul API arrival fields.
    /// - Parameter msg: raw message string
    /// - Returns: Result with seconds and remainingStops, or nil if message indicates no arrival (운행종료 등)
    public static func parse(_ msg: String) -> Result? {
        let trimmed = msg.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }

        // Common phrases
        if trimmed.contains("운행종료") || trimmed.contains("출발대기") {
            return nil
        }

        // "곧 도착" 처리
        if trimmed.contains("곧") {
            return Result(seconds: 60, remainingStops: 0)
        }

        // 정규식으로 "NN분후" 추출
        if let minuteMatch = matchFirst(in: trimmed, pattern: "([0-9]+)분후") {
            if let minutes = Int(minuteMatch) {
                let seconds = minutes * 60
                // remaining stops: [X번째 전] 형태가 있으면 추출
                var remaining: Int? = nil
                if let remMatch = matchFirst(in: trimmed, pattern: "\\[([0-9]+)번째 전\\]") {
                    remaining = Int(remMatch)
                }
                return Result(seconds: seconds, remainingStops: remaining)
            }
        }

        // 다른 패턴: 예를 들어 "약 1분 후" 등. 숫자만 추출해서 분으로 해석
        if let numberMatch = matchFirst(in: trimmed, pattern: "([0-9]+)") {
            if let num = Int(numberMatch) {
                return Result(seconds: num * 60, remainingStops: nil)
            }
        }

        return nil
    }

    private static func matchFirst(in text: String, pattern: String) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(text.startIndex ..< text.endIndex, in: text)
            if let match = regex.firstMatch(in: text, options: [], range: range), match.numberOfRanges >= 2 {
                let r = match.range(at: 1)
                if let swiftRange = Range(r, in: text) {
                    return String(text[swiftRange])
                }
            }
        } catch {
            return nil
        }
        return nil
    }
}
