import SwiftUI

struct JobProgressView: View {
    @State private var progress = 0.5 // Example progress
    @State private var successfulPosts = 23
    @State private var failedPosts = 1
    @State private var skippedPosts = 1
    @State private var totalPosts = 50
    @State private var elapsedTime = "2m 5s"
    @State private var remainingTime = "~2m 5s"

    var body: some View {
        VStack {
            Text("Processing: \(Int(progress * 100))%")
                .font(.title)
                .padding()

            ProgressView(value: progress)
                .padding()

            GroupBox(label: Text("Progress Stats")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Processed: \(successfulPosts + failedPosts + skippedPosts)/\(totalPosts)")
                    Text("Successful: \(successfulPosts)")
                    Text("Failed: \(failedPosts)")
                    Text("Skipped: \(skippedPosts)")
                    Divider()
                    Text("Elapsed Time: \(elapsedTime)")
                    Text("Remaining Time: \(remainingTime)")
                }
                .padding()
            }
            .padding()

            Button(action: {
                // Logic to cancel the operation
            }) {
                Text("Cancel")
            }
            .padding()
        }
        .navigationTitle("Posting Progress")
    }
}

struct JobProgressView_Previews: PreviewProvider {
    static var previews: some View {
        JobProgressView()
    }
}
