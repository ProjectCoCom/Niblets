import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CSVSelectionView()) {
                    Label("CSV File", systemImage: "doc.text")
                }
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gear")
                }
                NavigationLink(destination: HealthCheckView()) {
                    Label("Health Check", systemImage: "heart.text.square")
                }
                NavigationLink(destination: DryRunView()) {
                    Label("Dry Run", systemImage: "play.circle")
                }
                NavigationLink(destination: JobProgressView()) {
                    Label("Start Posting", systemImage: "paperplane.fill")
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)

            Text("Select an option")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert(isPresented: $viewModel.isShowingResumePrompt) {
            Alert(
                title: Text("Incomplete Job Found"),
                message: Text("Do you want to resume the incomplete job from where you left off?"),
                primaryButton: .default(Text("Resume"), action: {
                    viewModel.resumeJob()
                }),
                secondaryButton: .cancel()
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
