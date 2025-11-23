import SwiftUI

struct ContentView: View {
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
