import Foundation

extension String {
    func removeParenthesesContent() -> String {
        if let range = range(of: "\\(.*\\)", options: .regularExpression) {
            return replacingCharacters(in: range, with: "").trimmingCharacters(in: .whitespaces)
        }
        return self
    }

    func levenshteinDistance(to target: String) -> Int {
        let s = Array(self)
        let t = Array(target)
        let sCount = s.count
        let tCount = t.count

        if sCount == 0 { return tCount }
        if tCount == 0 { return sCount }

        var dist = [[Int]](repeating: [Int](repeating: 0, count: tCount + 1), count: sCount + 1)

        for i in 0 ... sCount {
            dist[i][0] = i
        }
        for j in 0 ... tCount {
            dist[0][j] = j
        }

        for i in 1 ... sCount {
            for j in 1 ... tCount {
                let cost = (s[i - 1] == t[j - 1]) ? 0 : 1
                dist[i][j] = Swift.min(
                    dist[i - 1][j] + 1, // Deletion
                    dist[i][j - 1] + 1, // Insertion
                    dist[i - 1][j - 1] + cost // Substitution
                )
            }
        }
        return dist[sCount][tCount]
    }

    func normalizeBusNumber() -> String {
        var normalized = self
        let koreanNumberMap: [String: String] = [
            "일": "1", "이": "2", "삼": "3", "사": "4", "오": "5",
            "육": "6", "칠": "7", "팔": "8", "구": "9", "공": "0",
        ]
        let specialCharsMap: [String: String] = [
            "다시": "-", "의": "-", "엠": "M",
        ]

        // 1. 한글 숫자 및 특수 발음 변환
        for (key, value) in koreanNumberMap {
            normalized = normalized.replacingOccurrences(of: key, with: value)
        }
        for (key, value) in specialCharsMap {
            normalized = normalized.replacingOccurrences(of: key, with: value)
        }

        // "십", "백", "천" 처리 (간단한 버전)
        // TODO: 더 복잡한 케이스(e.g., "이십", "삼백")는 추후 개선
        normalized = normalized.replacingOccurrences(of: "십", with: "10")
        normalized = normalized.replacingOccurrences(of: "백", with: "100")
        normalized = normalized.replacingOccurrences(of: "천", with: "1000")

        // 2. 불필요한 문자 제거 (숫자, 영어 대문자, 하이픈(-) 제외)
        let allowedCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-")
        normalized = normalized.unicodeScalars.filter(allowedCharacters.contains).map(String.init).joined()

        return normalized
    }
}
