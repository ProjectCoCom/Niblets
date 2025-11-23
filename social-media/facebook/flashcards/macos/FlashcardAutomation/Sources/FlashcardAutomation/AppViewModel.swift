import Foundation
import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var flashcards: [Flashcard] = []
    @Published var currentJob: JobState?
    @Published var incompleteJobToShow: JobState?
    @Published var isShowingResumePrompt = false

    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var isPosting = false
    @Published var postingProgress = 0.0
    @Published var successfulPosts = 0
    @Published var failedPosts = 0
    @Published var skippedPosts = 0

    // MARK: - Services
    private let csvParser = CSVParser()
    private let jobStateService = JobStateService()
    private let facebookAuthService = FacebookAuthService()
    private let keychainService = KeychainService()
    private let facebookAPIClient = FacebookAPIClient()
    private let rateLimiter = RateLimiter(capacity: 10, refillRate: 1)
    private let commentSchedulerService = CommentSchedulerService()

    init() {
        checkForIncompleteJob()
        loadTokenFromKeychain()
    }

    // MARK: - Authentication Methods
    func login() async {
        do {
            let token = try await facebookAuthService.authenticate()
            try keychainService.save(account: "facebook_access_token", data: token.data(using: .utf8)!)
            isAuthenticated = true
        } catch {
            // In a real app, you'd show an error to the user here.
            print("Authentication failed: \(error)")
            isAuthenticated = false
        }
    }

    func logout() {
        try? keychainService.delete(account: "facebook_access_token")
        isAuthenticated = false
    }

    // MARK: - Posting Logic
    func startPosting(commentOption: String, commentDelay: Int) async {
        guard let job = currentJob else { return }

        isPosting = true

        for (index, flashcard) in flashcards.enumerated() {
            do {
                try await rateLimiter.take()

                // TODO: Replace with actual page ID from user settings
                let postID = try await facebookAPIClient.post(pageID: "me", message: flashcard.question)

                switch commentOption {
                case "immediate":
                    try await facebookAPIClient.comment(postID: postID, message: flashcard.answer)
                case "delayed":
                    commentSchedulerService.scheduleComment(postID: postID, text: flashcard.answer, delayInHours: commentDelay)
                case "none":
                    // Do nothing
                    break
                default:
                    break
                }

                successfulPosts += 1
            } catch {
                failedPosts += 1
            }

            postingProgress = Double(index + 1) / Double(flashcards.count)
            currentJob?.processedItems = index + 1
            currentJob?.successfulItems = successfulPosts
            currentJob?.failedItems = failedPosts
            try? jobStateService.save(jobState: currentJob!)
        }

        isPosting = false
    }

    // MARK: - Public Methods
    func loadCSV(from url: URL) throws {
        let loadedFlashcards = try csvParser.parse(filePath: url.path)

        guard !loadedFlashcards.isEmpty else {
            // In a real app, you'd show an error to the user here.
            print("CSV file is empty or invalid.")
            return
        }

        self.flashcards = loadedFlashcards
        self.currentJob = JobState(
            jobID: UUID(),
            csvFilePath: url.path,
            totalItems: loadedFlashcards.count,
            processedItems: 0,
            successfulItems: 0,
            failedItems: 0,
            skippedItems: 0,
            timestamp: Date()
        )
        try? jobStateService.save(jobState: self.currentJob!)
    }

    func resumeJob() {
        guard let jobToResume = incompleteJobToShow else { return }
        // TODO: Implement the logic to resume the job
        print("Resuming job: \(jobToResume.jobID)")
        incompleteJobToShow = nil
        isShowingResumePrompt = false
    }

    // MARK: - Private Methods
    private func checkForIncompleteJob() {
        if let incompleteJob = try? jobStateService.findIncompleteJob() {
            self.incompleteJobToShow = incompleteJob
            self.isShowingResumePrompt = true
        }
    }

    private func loadTokenFromKeychain() {
        if let _ = try? keychainService.load(account: "facebook_access_token") {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
    }
}
