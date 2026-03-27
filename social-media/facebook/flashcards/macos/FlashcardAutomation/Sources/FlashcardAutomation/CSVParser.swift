import Foundation

struct Flashcard {
    let question: String
    let answer: String
}

enum CSVParserError: Error {
    case fileNotFound
    case invalidData
    case missingHeaders
}

class CSVParser {
    func parse(filePath: String) throws -> [Flashcard] {
        guard FileManager.default.fileExists(atPath: filePath) else {
            throw CSVParserError.fileNotFound
        }

        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        var lines = content.components(separatedBy: .newlines)

        guard let header = lines.first, header == "Question,Answer" else {
            throw CSVParserError.missingHeaders
        }

        lines.removeFirst()

        var flashcards: [Flashcard] = []
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty { continue }

            let fields = try parseLine(line)
            if fields.count == 2 {
                let question = fields[0]
                let answer = fields[1]
                flashcards.append(Flashcard(question: question, answer: answer))
            } else {
                // You might want to handle malformed rows more gracefully
                print("Warning: Malformed row skipped: \(line)")
            }
        }
        return flashcards
    }

    private func parseLine(_ line: String) throws -> [String] {
        var fields = [String]()
        var currentField = ""
        var inQuotes = false
        var lastChar: Character?

        for char in line {
            switch char {
            case "\"":
                if inQuotes && lastChar == "\"" {
                    // This is an escaped quote
                    currentField.append(char)
                    lastChar = nil // Reset lastChar
                } else {
                    inQuotes.toggle()
                    lastChar = char
                }
            case ",":
                if inQuotes {
                    currentField.append(char)
                } else {
                    fields.append(currentField)
                    currentField = ""
                }
                lastChar = char
            default:
                currentField.append(char)
                lastChar = char
            }
        }
        fields.append(currentField)
        return fields
    }
}
