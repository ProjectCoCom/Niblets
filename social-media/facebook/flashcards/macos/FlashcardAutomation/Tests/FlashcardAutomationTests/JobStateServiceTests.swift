import XCTest
@testable import FlashcardAutomation

final class JobStateServiceTests: XCTestCase {

    var jobStateService: JobStateService!
    var testJobsDirectory: URL!

    override func setUp() {
        super.setUp()
        let tempDir = FileManager.default.temporaryDirectory
        testJobsDirectory = tempDir.appendingPathComponent("TestJobs")

        // Create a new instance of JobStateService pointing to the test directory
        jobStateService = JobStateService(jobsDirectory: testJobsDirectory)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: testJobsDirectory)
        super.tearDown()
    }

    func testSaveAndLoadJobState() throws {
        let jobID = UUID()
        let jobState = JobState(jobID: jobID, csvFilePath: "test.csv", totalItems: 10, processedItems: 5, successfulItems: 4, failedItems: 1, skippedItems: 0, timestamp: Date())

        try jobStateService.save(jobState: jobState)
        let loadedJobState = try jobStateService.load(jobID: jobID)

        XCTAssertNotNil(loadedJobState)
        XCTAssertEqual(loadedJobState?.jobID, jobID)
        XCTAssertEqual(loadedJobState?.processedItems, 5)
    }

    func testFindIncompleteJob() throws {
        let incompleteJob = JobState(jobID: UUID(), csvFilePath: "incomplete.csv", totalItems: 10, processedItems: 5, successfulItems: 4, failedItems: 1, skippedItems: 0, timestamp: Date())
        let completeJob = JobState(jobID: UUID(), csvFilePath: "complete.csv", totalItems: 10, processedItems: 10, successfulItems: 10, failedItems: 0, skippedItems: 0, timestamp: Date())

        try jobStateService.save(jobState: incompleteJob)
        try jobStateService.save(jobState: completeJob)

        let foundJob = try jobStateService.findIncompleteJob()
        XCTAssertNotNil(foundJob)
        XCTAssertEqual(foundJob?.jobID, incompleteJob.jobID)
    }
}
