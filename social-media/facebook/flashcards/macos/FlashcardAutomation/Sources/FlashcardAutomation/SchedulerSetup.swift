import Foundation

class SchedulerSetup {

    // TODO: Replace with your app's bundle identifier
    let agentIdentifier = "com.example.FlashcardAutomation.scheduler"

    var propertyListURL: URL {
        let libraryDir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        return libraryDir.appendingPathComponent("LaunchAgents/\(agentIdentifier).plist")
    }

    func createAndLoadLaunchAgent() {
        let launchAgent = [
            "Label": agentIdentifier,
            "ProgramArguments": [
                // This would be the path to your command-line tool that handles the posting
                "/Applications/FlashcardAutomation.app/Contents/MacOS/FlashcardAutomation",
                "--run-scheduler"
            ],
            "StartInterval": 60, // Run every 60 seconds
            "RunAtLoad": true
        ] as [String: Any]

        let propertyListData = try? PropertyListSerialization.data(fromPropertyList: launchAgent, format: .xml, options: 0)

        try? propertyListData?.write(to: propertyListURL)

        // In a real app, you would use a helper tool or ask the user to run `launchctl`
        // to load the agent. For example:
        // `launchctl load \(propertyListURL.path)`
    }

    func unloadLaunchAgent() {
        // In a real app, you would use a helper tool or ask the user to run `launchctl`
        // to unload the agent. For example:
        // `launchctl unload \(propertyListURL.path)`
        try? FileManager.default.removeItem(at: propertyListURL)
    }
}
