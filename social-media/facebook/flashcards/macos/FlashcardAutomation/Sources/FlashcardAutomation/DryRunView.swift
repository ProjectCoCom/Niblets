import SwiftUI

struct DryRunView: View {
    let flashcards = [
        Flashcard(question: "What is the capital of France?", answer: "Paris"),
        Flashcard(question: "What is 2+2?", answer: "Four"),
        Flashcard(question: "This is a very long question that will most likely exceed the character limit for a colored background post on Facebook, so we should see a warning about it.", answer: "A long answer.")
    ]

    var body: some View {
        VStack {
            List(flashcards, id: \.question) { flashcard in
                VStack(alignment: .leading, spacing: 10) {
                    Text("Question: \(flashcard.question)")
                        .font(.headline)
                    Text("Answer: \(flashcard.answer)")
                        .font(.subheadline)

                    if flashcard.question.count > 130 {
                        Text("Warning: Question is too long for a colored background (\(flashcard.question.count)/130 characters)")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
            }

            Button(action: {
                // Logic to start the actual posting
            }) {
                Text("Looks good, start posting!")
            }
            .padding()
        }
        .navigationTitle("Dry Run Preview")
    }
}

struct DryRunView_Previews: PreviewProvider {
    static var previews: some View {
        DryRunView()
    }
}
