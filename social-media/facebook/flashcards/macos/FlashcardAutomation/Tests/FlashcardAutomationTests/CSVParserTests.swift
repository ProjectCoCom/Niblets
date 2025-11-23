import XCTest
@testable import FlashcardAutomation

final class CSVParserTests: XCTestCase {

    func testParseValidCSV() throws {
        let csvContent = """
        Question,Answer
        "What is the capital of France?","Paris"
        "What is 2+2?","Four"
        "A question, with a comma","An answer"
        """
        let filePath = try createTemporaryFile(with: csvContent)

        let parser = CSVParser()
        let flashcards = try parser.parse(filePath: filePath)

        XCTAssertEqual(flashcards.count, 3)
        XCTAssertEqual(flashcards[0].question, "What is the capital of France?")
        XCTAssertEqual(flashcards[0].answer, "Paris")
        XCTAssertEqual(flashcards[1].question, "What is 2+2?")
        XCTAssertEqual(flashcards[1].answer, "Four")
        XCTAssertEqual(flashcards[2].question, "A question, with a comma")
        XCTAssertEqual(flashcards[2].answer, "An answer")
    }

    func testParseCSVWithEscapedQuotes() throws {
        let csvContent = """
        Question,Answer
        "A question with ""quotes""","An answer"
        """
        let filePath = try createTemporaryFile(with: csvContent)

        let parser = CSVParser()
        let flashcards = try parser.parse(filePath: filePath)

        XCTAssertEqual(flashcards.count, 1)
        XCTAssertEqual(flashcards[0].question, "A question with \"quotes\"")
        XCTAssertEqual(flashcards[0].answer, "An answer")
    }

    func testParseCSVWithMissingHeaders() throws {
        let csvContent = """
        "What is the capital of France?","Paris"
        "What is 2+2?","Four"
        """
        let filePath = try createTemporaryFile(with: csvContent)

        let parser = CSVParser()
        XCTAssertThrowsError(try parser.parse(filePath: filePath)) { error in
            XCTAssertEqual(error as? CSVParserError, .missingHeaders)
        }
    }

    func testParseCSVWithFileNotFound() {
        let parser = CSVParser()
        XCTAssertThrowsError(try parser.parse(filePath: "nonexistent.csv")) { error in
            XCTAssertEqual(error as? CSVParserError, .fileNotFound)
        }
    }

    // Helper function to create a temporary file for testing
    private func createTemporaryFile(with content: String) throws -> String {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("csv")
        try content.write(to: temporaryFileURL, atomically: true, encoding: .utf8)
        return temporaryFileURL.path
    }
}
