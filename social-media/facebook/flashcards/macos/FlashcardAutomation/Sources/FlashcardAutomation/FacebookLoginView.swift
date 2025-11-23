import SwiftUI

struct FacebookLoginView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        VStack {
            Text(viewModel.isAuthenticated ? "Logged In" : "Not Logged In")
                .padding()

            if !viewModel.isAuthenticated {
                Button(action: {
                    Task {
                        await viewModel.login()
                    }
                }) {
                    Text("Login with Facebook")
                }
                .padding()
            } else {
                Button(action: {
                    viewModel.logout()
                }) {
                    Text("Logout")
                }
                .padding()
            }
        }
        .navigationTitle("Facebook Login")
    }
}

struct FacebookLoginView_Previews: PreviewProvider {
    static var previews: some View {
        FacebookLoginView()
            .environmentObject(AppViewModel())
    }
}
