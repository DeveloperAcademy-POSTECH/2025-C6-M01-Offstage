extension String {
    func removeParenthesesContent() -> String {
        if let range = range(of: "\\(.*\\)", options: .regularExpression) {
            return replacingCharacters(in: range, with: "").trimmingCharacters(in: .whitespaces)
        }
        return self
    }
}
