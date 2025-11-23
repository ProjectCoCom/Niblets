import SwiftUI

struct CSVSelectionView: View {
    @State private var flashcards: [Flashcard] = []
    @State private var isFilePickerPresented = false
    @State private var selectedFileURL: URL?
    @State private var errorMessage: String?
    @State private var showErrorAlert = false

    private let csvParser = CSVParser()

    var body: some View {
        VStack {
            if let url = selectedFileURL {
                Text("Selected file: \(url.lastPathComponent)")
                    .padding()
            }

            Button(action: {
                isFilePickerPresented = true
            }) {
                Text("Select CSV File")
            }
            .padding()
            .fileImporter(
                isPresented: $isFilePickerPresented,
                allowedContentTypes: [.commaSeparatedText]
            ) { result in
                switch result {
                case .success(let url):
                    self.selectedFileURL = url
                    do {
                        self.flashcards = try csvParser.parse(filePath: url.path)
                    } catch {
                        self.errorMessage = "Error parsing CSV: \(error.localizedDescription)"
                        self.showErrorAlert = true
                    }
                case .failure(let error):
                    self.errorMessage = "Error selecting file: \(error.localizedDescription)"
                    self.showErrorAlert = true
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "An unknown error occurred"), dismissButton: .default(Text("OK")))
            }

            if !flashcards.isEmpty {
                List(flashcards, id: \.question) { flashcard in
                    VStack(alignment: .leading) {
                        Text("Question: \(flashcard.question)").font(.headline)
                        Text("Answer: \(flashcard.answer)").font(.subheadline)
                    }
                }
            } else {
                Text("No CSV file selected or file is empty.")
                    .padding()
            }
        }
        .navigationTitle("CSV Selection & Preview")
    }
}

struct CSVSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CSVSelectionView()
    }
}
