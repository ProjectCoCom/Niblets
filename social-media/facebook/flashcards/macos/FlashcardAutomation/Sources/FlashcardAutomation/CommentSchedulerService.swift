import Foundation
import SwiftData

@Model
class ScheduledComment {
    var id: UUID
    var postID: String
    var commentText: String
    var scheduledFor: Date
    var status: String
    var createdAt: Date
    var postedAt: Date?
    var attempts: Int
    var lastError: String?

    init(id: UUID = UUID(), postID: String, commentText: String, scheduledFor: Date, status: String = "pending", createdAt: Date = Date(), postedAt: Date? = nil, attempts: Int = 0, lastError: String? = nil) {
        self.id = id
        self.postID = postID
        self.commentText = commentText
        self.scheduledFor = scheduledFor
        self.status = status
        self.createdAt = createdAt
        self.postedAt = postedAt
        self.attempts = attempts
        self.lastError = lastError
    }
}

class CommentSchedulerService {
    private var modelContainer: ModelContainer?

    init() {
        do {
            self.modelContainer = try ModelContainer(for: ScheduledComment.self)
        } catch {
            // Handle the error appropriately in a real application
            print("Failed to create the model container: \(error)")
            self.modelContainer = nil
        }
    }

    @MainActor
    func scheduleComment(postID: String, text: String, delayInHours: Int) {
        guard let modelContainer else { return }
        let scheduledFor = Calendar.current.date(byAdding: .hour, value: delayInHours, to: Date())!
        let comment = ScheduledComment(postID: postID, commentText: text, scheduledFor: scheduledFor)
        modelContainer.mainContext.insert(comment)
    }

    @MainActor
    func findDueComments() -> [ScheduledComment] {
        guard let modelContainer else { return [] }
        let now = Date()
        let fetchDescriptor = FetchDescriptor<ScheduledComment>(
            predicate: #Predicate { $0.scheduledFor <= now && $0.status == "pending" }
        )
        return (try? modelContainer.mainContext.fetch(fetchDescriptor)) ?? []
    }

    @MainActor
    func updateCommentStatus(comment: ScheduledComment, newStatus: String, error: String? = nil) {
        // This method modifies the comment object directly, so it doesn't need a model container
        comment.status = newStatus
        comment.postedAt = (newStatus == "posted") ? Date() : nil
        comment.lastError = error
        comment.attempts += 1
    }
}
