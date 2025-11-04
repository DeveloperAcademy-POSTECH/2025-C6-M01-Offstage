#!/usr/bin/env swift

import Foundation

// --- Configuration ---
let csvPath = "Scripts/strings.csv" // CSV 파일 경로 (스크립트 위치 기준)
let xcstringsPath = "OffStageApp/Resources/Localizable.xcstrings"
let swiftManagerPath = "OffStageApp/Sources/Presentation/Common/L10n.swift"
let sourceLanguage = "ko"
// ---------------------

// MARK: - Codable Structures for .xcstrings

struct XCStrings: Codable {
    let sourceLanguage: String
    let strings: [String: StringItem]
    let version: String
}

struct StringItem: Codable {
    var comment: String?
    let localizations: [String: Localization]
}

struct Localization: Codable {
    let stringUnit: StringUnit
}

struct StringUnit: Codable {
    let state: String
    let value: String
}

// MARK: - Main Logic

struct StringEntry {
    let key: String
    let value: String
    let comment: String
}

enum ScriptError: Error {
    case fileReadError(String)
    case fileWriteError(String)
    case parsingError(String)
}

// 1. Read and Parse CSV
func parseCSV(path: String) throws -> [StringEntry] {
    let content: String
    do {
        content = try String(contentsOfFile: path, encoding: .utf8)
    } catch {
        throw ScriptError.fileReadError("Failed to read \(path): \(error.localizedDescription)")
    }

    var entries = [StringEntry]()
    guard !content.isEmpty else { return [] } // Handle empty file case

    var rows = [[String]]()
    var currentRow = [String]()
    var currentField = ""
    var inQuotes = false

    // Skip header line
    var iterator = content.makeIterator()
    while let char = iterator.next(), char != "\n" {} // Consume characters until newline

    while let char = iterator.next() {
        if inQuotes {
            if char == "\"" {
                inQuotes = false
            } else {
                currentField.append(char)
            }
        } else {
            switch char {
            case "\"":
                inQuotes = true
            case ",":
                currentRow.append(currentField)
                currentField = ""
            case "\n":
                currentRow.append(currentField)
                rows.append(currentRow)
                currentRow = []
                currentField = ""
            default:
                currentField.append(char)
            }
        }
    }
    // Append the last line if it's not empty
    if !currentField.isEmpty || !currentRow.isEmpty {
        currentRow.append(currentField)
        rows.append(currentRow)
    }

    for row in rows where !row.allSatisfy(\.isEmpty) { // Ensure row is not entirely empty strings
        if row.count == 3 {
            let key = row[0].trimmingCharacters(in: .whitespaces)
            let value = row[1].trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            let comment = row[2].trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            entries.append(StringEntry(key: key, value: value, comment: comment))
        } else {
            print("Warning: Skipping malformed row with \(row.count) fields -> \(row)")
        }
    }

    return entries
}

// 2. Generate Localizable.xcstrings Content (JSON)
func generateXcstringsJSON(entries: [StringEntry]) throws -> String {
    var stringsDict = [String: StringItem]()
    for entry in entries {
        let unit = StringUnit(state: "translated", value: entry.value.replacingOccurrences(of: "\\n", with: "\n"))
        let localization = Localization(stringUnit: unit)
        let item = StringItem(
            comment: entry.comment.isEmpty ? nil : entry.comment,
            localizations: [sourceLanguage: localization]
        )
        stringsDict[entry.key] = item
    }

    let root = XCStrings(
        sourceLanguage: sourceLanguage,
        strings: stringsDict,
        version: "1.0"
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    guard let data = try? encoder.encode(root), let jsonString = String(data: data, encoding: .utf8) else {
        throw ScriptError.parsingError("Failed to encode .xcstrings JSON.")
    }
    return jsonString
}

// 3. Generate L10n.swift Content (Enum Manager)
func generateSwiftManager(entries: [StringEntry]) -> String {
    var swiftContent = """
    import SwiftUI

    // [주의] 이 파일은 스크립트에 의해 자동 생성되었습니다.
    // L10n(현지화) 및 A11y(접근성) 문자열을 관리합니다.
    // 원본 소스: \(csvPath)

    enum L10n {
        private static func key(_ key: String) -> LocalizedStringKey {
            return LocalizedStringKey(key)
        }

    """

    let groupedByScreen = Dictionary(grouping: entries) { $0.key.split(separator: ".")[0] }

    for screen in groupedByScreen.keys.sorted() {
        let capitalizedScreen = String(screen).prefix(1).uppercased() + String(screen).dropFirst()
        swiftContent += "    enum \(capitalizedScreen) {\n"

        let screenEntries = groupedByScreen[screen]!
        var entriesWithContext: [StringEntry] = []

        for entry in screenEntries.sorted(by: { $0.key < $1.key }) {
            let components = entry.key.split(separator: ".")
            if components.count < 3 {
                let propertyName = components.dropFirst().joined(separator: ".").prefix(1).lowercased() + components
                    .dropFirst().joined(separator: ".").dropFirst()
                if propertyName.isEmpty { continue }
                swiftContent += "\n        /// \"\(entry.value.replacingOccurrences(of: "\n", with: " "))\" (문맥: \(entry.comment))\n"
                swiftContent += "        static let \(propertyName) = key(\"\(entry.key)\")\n"
            } else {
                entriesWithContext.append(entry)
            }
        }

        let groupedByContext = Dictionary(grouping: entriesWithContext) { $0.key.split(separator: ".")[1] }

        for context in groupedByContext.keys.sorted() {
            let capitalizedContext = String(context).prefix(1).uppercased() + String(context).dropFirst()
            swiftContent += "\n        enum \(capitalizedContext) {\n"

            let strings = groupedByContext[context]!.sorted(by: { $0.key < $1.key })
            for entry in strings {
                let propertyName = entry.key.split(separator: ".").dropFirst(2)
                    .enumerated()
                    .map { index, part -> String in
                        let partString = String(part)
                        return index == 0 ? partString : partString.prefix(1).uppercased() + partString.dropFirst()
                    }
                    .joined()

                if propertyName.isEmpty { continue }

                swiftContent += "\n            /// \"\(entry.value.replacingOccurrences(of: "\n", with: " "))\" (문맥: \(entry.comment))\n"
                swiftContent += "            static let \(propertyName) = key(\"\(entry.key)\")\n"
            }
            swiftContent += "        }\n"
        }
        swiftContent += "    }\n"
    }
    swiftContent += "}"
    return swiftContent
}

// --- Main Execution ---
func main() {
    do {
        print("스크립트 실행...")
        let entries = try parseCSV(path: csvPath)

        print("\(entries.count)개의 키 파싱 완료.")

        // Write .xcstrings
        let xcstringsContent = try generateXcstringsJSON(entries: entries)
        try xcstringsContent.write(toFile: xcstringsPath, atomically: true, encoding: .utf8)
        print("✅ \(xcstringsPath) 생성 완료.")

        // Write .swift
        let swiftContent = generateSwiftManager(entries: entries)
        try swiftContent.write(toFile: swiftManagerPath, atomically: true, encoding: .utf8)
        print("✅ \(swiftManagerPath) 생성 완료.")

        print("🎉 L10n 인프라 구축 완료.")

    } catch let error as ScriptError {
        print("❌ Error: \(error)")
    } catch {
        print("❌ An unexpected error occurred: \(error)")
    }
}

main()
