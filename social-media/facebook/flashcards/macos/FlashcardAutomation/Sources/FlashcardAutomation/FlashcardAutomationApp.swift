import SwiftUI

@main
struct FlashcardAutomationApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }

    init() {
        if CommandLine.arguments.contains("--run-scheduler") {
            // This is where the background processing would happen.
            // In a real app, you would instantiate the necessary services
            // and run the comment posting logic.
            print("Running scheduler...")

            // For now, we'll just exit.
            NSApplication.shared.terminate(nil)
        }
    }
}
