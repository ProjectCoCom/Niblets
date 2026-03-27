import SwiftUI

struct SettingsView: View {
    @AppStorage("postInterval") private var postInterval = 5.0
    @AppStorage("useColorCycling") private var useColorCycling = false
    @AppStorage("commentOption") private var commentOption = "immediate"
    @AppStorage("commentDelay") private var commentDelay = 1

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
                Picker("Comment Option", selection: $commentOption) {
                    Text("Post Immediately").tag("immediate")
                    Text("Schedule Comment").tag("delayed")
                    Text("No Comment").tag("none")
                }
                .pickerStyle(SegmentedPickerStyle())

                if commentOption == "delayed" {
                    Stepper("Delay: \(commentDelay) hour(s)", value: $commentDelay, in: 1...48)
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
