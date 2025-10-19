import Foundation
import Logging

let logger = Logger(label: "")

private extension Logger {
    func logWithMeta(
        level: Logger.Level,
        icon: String? = nil,
        _ message: @autoclosure () -> String,
        category: String = "오뿌스테이지",
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        let emoji = icon ?? ""

        let context =
            """
            \n[\(category)] \(emoji) \(message())
            ↘📍 \(file):\(line)
            → \(function)
            """
        log(level: level, "\(context)")
    }
}

public func logNotice(
    _ message: @autoclosure () -> String,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    logger.logWithMeta(level: .notice, message(), file: file, function: function, line: line)
}

public func logInfo(
    _ message: @autoclosure () -> String,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    logger.logWithMeta(level: .info, icon: "🛠️", message(), file: file, function: function, line: line)
}

public func logDebug(
    _ message: @autoclosure () -> String,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    logger.logWithMeta(level: .debug, icon: "💬", message(), file: file, function: function, line: line)
}

public func logError(
    _ message: @autoclosure () -> String,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
) {
    logger.logWithMeta(level: .error, icon: "❗️", message(), file: file, function: function, line: line)
}

// 필요 시 debug, warning 등 추가
