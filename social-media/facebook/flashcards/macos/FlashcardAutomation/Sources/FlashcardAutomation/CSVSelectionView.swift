import SwiftUI

struct CSVSelectionView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isFilePickerPresented = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false

    var body: some View {
        VStack {
            if let job = viewModel.currentJob {
                Text("Loaded file: \(URL(fileURLWithPath: job.csvFilePath).lastPathComponent)")
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
                    do {
                        try viewModel.loadCSV(from: url)
                    } catch {
                        self.errorMessage = "Error loading CSV: \(error.localizedDescription)"
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

            if !viewModel.flashcards.isEmpty {
                List(viewModel.flashcards, id: \.question) { flashcard in
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
