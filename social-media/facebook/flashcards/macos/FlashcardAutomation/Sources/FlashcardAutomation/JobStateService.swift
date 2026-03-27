import Foundation

struct JobState: Codable {
    let jobID: UUID
    let csvFilePath: String
    let totalItems: Int
    var processedItems: Int
    var successfulItems: Int
    var failedItems: Int
    var skippedItems: Int
    let timestamp: Date
}

class JobStateService {
    private let jobsDirectory: URL

    init(jobsDirectory: URL) {
        self.jobsDirectory = jobsDirectory
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: self.jobsDirectory.path) {
            try? fileManager.createDirectory(at: self.jobsDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }

    convenience init() {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let defaultJobsDirectory = appSupportURL.appendingPathComponent("FlashcardAutomation/jobs")
        self.init(jobsDirectory: defaultJobsDirectory)
    }

    func save(jobState: JobState) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(jobState)
        let fileURL = jobsDirectory.appendingPathComponent("\(jobState.jobID).json")
        try data.write(to: fileURL)
    }

    func load(jobID: UUID) throws -> JobState? {
        let fileURL = jobsDirectory.appendingPathComponent("\(jobID).json")
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(JobState.self, from: data)
    }

    func findIncompleteJob() throws -> JobState? {
        let fileManager = FileManager.default
        let jobFiles = try fileManager.contentsOfDirectory(at: jobsDirectory, includingPropertiesForKeys: nil)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for fileURL in jobFiles {
            let data = try Data(contentsOf: fileURL)
            let jobState = try decoder.decode(JobState.self, from: data)
            if jobState.processedItems < jobState.totalItems {
                return jobState
            }
        }

        return nil
    }
}
