import SwiftUI

struct SettingsView: View {
    @AppStorage("postInterval") private var postInterval = 5.0
    @AppStorage("useColorCycling") private var useColorCycling = false
    @AppStorage("commentDelay") private var commentDelay = 0

    let colorPresets = ["Red", "Blue", "Green", "Yellow", "Purple", "Orange", "Pink", "Black"]
    @State private var selectedColor = "Blue"

    var body: some View {
        Form {
            Section(header: Text("Posting")) {
                Slider(value: $postInterval, in: 3...60, step: 1) {
                    Text("Post Interval (\(Int(postInterval)) seconds)")
                }

                Toggle(isOn: $useColorCycling) {
                    Text("Cycle through all colors")
                }

                Picker("Default Color", selection: $selectedColor) {
                    ForEach(colorPresets, id: \.self) {
                        Text($0)
                    }
                }
                .disabled(useColorCycling)
            }

            Section(header: Text("Comments")) {
                Picker("Comment Delay", selection: $commentDelay) {
                    Text("Immediate").tag(0)
                    Text("1 Hour").tag(1)
                    Text("2 Hours").tag(2)
                    Text("6 Hours").tag(6)
                    Text("12 Hours").tag(12)
                    Text("24 Hours").tag(24)
                }
            }
        }
        .padding()
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
