
#if DEBUG_MODE
    import SwiftUI

    struct DebugView: View {
        @StateObject private var logStore = LogStore.shared

        var body: some View {
            NavigationView {
                List {
                    ForEach(logStore.logs, id: \.self) { log in
                        Text(log)
                            .font(.system(.caption, design: .monospaced))
                            .listRowInsets(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                    }
                }
                .navigationTitle("Debug Logs")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") {
                            logStore.clearLogs()
                        }
                    }
                }
            }
        }
    }

    struct DebugView_Previews: PreviewProvider {
        static var previews: some View {
            DebugView()
        }
    }
#endif
