import Foundation

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
}

class LoggingService {
    private let logDirectory: URL
    private let dateFormatter = ISO8601DateFormatter()

    init() {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.logDirectory = appSupportURL.appendingPathComponent("FlashcardAutomation/logs")

        if !fileManager.fileExists(atPath: self.logDirectory.path) {
            try? fileManager.createDirectory(at: self.logDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }

    private func getLogFileURL() -> URL {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: date)
        return logDirectory.appendingPathComponent("flashcard_automation_\(dateString).log")
    }

    func log(_ level: LogLevel, message: String) {
        let timestamp = dateFormatter.string(from: Date())
        let logMessage = "[\(timestamp)] [\(level.rawValue)] - \(message)\n"

        let fileURL = getLogFileURL()

        if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(logMessage.data(using: .utf8)!)
            fileHandle.closeFile()
        } else {
            try? logMessage.data(using: .utf8)?.write(to: fileURL, options: .atomic)
        }
    }
}
