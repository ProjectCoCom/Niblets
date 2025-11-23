import Foundation
import AuthenticationServices

class FacebookAuthService: NSObject, ASWebAuthenticationPresentationContextProviding {

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Return the main window of the app
        return NSApplication.shared.windows.first!
    }

    func authenticate() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            // In a real app, you would construct the full URL with your app ID, redirect URI, and scopes.
            guard let authURL = URL(string: "https://www.facebook.com/v18.0/dialog/oauth?client_id=YOUR_APP_ID&redirect_uri=YOUR_REDIRECT_URI&scope=email") else {
                continuation.resume(throwing: URLError(.badURL))
                return
            }

            let callbackURLScheme = "YOUR_URL_SCHEME"

            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackURLScheme) { callbackURL, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let callbackURL = callbackURL else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }

                // The access token is typically a fragment in the URL
                let queryItems = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true)?.queryItems
                if let token = queryItems?.first(where: { $0.name == "access_token" })?.value {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true

            session.start()
        }
    }
}
