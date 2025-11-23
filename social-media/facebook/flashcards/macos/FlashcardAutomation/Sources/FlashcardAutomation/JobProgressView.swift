import SwiftUI

struct JobProgressView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @AppStorage("commentOption") private var commentOption = "immediate"
    @AppStorage("commentDelay") private var commentDelay = 1

    var body: some View {
        VStack {
            Text("Processing: \(Int(viewModel.postingProgress * 100))%")
                .font(.title)
                .padding()

            ProgressView(value: viewModel.postingProgress)
                .padding()

            GroupBox(label: Text("Progress Stats")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Processed: \(viewModel.successfulPosts + viewModel.failedPosts + viewModel.skippedPosts)/\(viewModel.flashcards.count)")
                    Text("Successful: \(viewModel.successfulPosts)")
                    Text("Failed: \(viewModel.failedPosts)")
                    Text("Skipped: \(viewModel.skippedPosts)")
                }
                .padding()
            }
            .padding()

            Button(action: {
                Task {
                    await viewModel.startPosting(commentOption: commentOption, commentDelay: commentDelay)
                }
            }) {
                Text("Start Posting")
            }
            .disabled(viewModel.isPosting)
            .padding()
        }
        .navigationTitle("Posting Progress")
    }
}

struct JobProgressView_Previews: PreviewProvider {
    static var previews: some View {
        JobProgressView()
            .environmentObject(AppViewModel())
    }
}
