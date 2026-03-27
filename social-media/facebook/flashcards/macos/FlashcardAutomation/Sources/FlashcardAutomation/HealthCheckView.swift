import SwiftUI

struct HealthCheckView: View {
    struct CheckResult: Identifiable {
        let id = UUID()
        let name: String
        let status: Bool
    }

    @State private var checkResults: [CheckResult] = [
        CheckResult(name: "Credentials", status: true),
        CheckResult(name: "Token Expiration", status: true),
        CheckResult(name: "Internet Connectivity", status: true),
        CheckResult(name: "Token Validation", status: false),
        CheckResult(name: "Page Access", status: true),
        CheckResult(name: "Post Permissions", status: true)
    ]

    @State private var isChecking = false

    var body: some View {
        VStack {
            List(checkResults) { result in
                HStack {
                    Text(result.name)
                    Spacer()
                    if result.status {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }

            Button(action: {
                // Logic to re-run the health checks
                isChecking = true
                // Simulate a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isChecking = false
                }
            }) {
                if isChecking {
                    ProgressView()
                } else {
                    Text("Run Health Checks")
                }
            }
            .padding()
        }
        .navigationTitle("Health Check")
    }
}

struct HealthCheckView_Previews: PreviewProvider {
    static var previews: some View {
        HealthCheckView()
    }
}
