
#if DEBUG_MODE
    import SwiftUI

    struct DebugView: View {
        @EnvironmentObject var router: Router<AppRoute>
        @Environment(\.dismiss) private var dismiss
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

            Button {
                dismiss() // 시트 닫기
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    router.push(.sttstest) // 시트 애니메이션 후 라우팅
                }
            } label: {
                Text("STT & TTS Test View")
            }
            Spacer()
        }
    }

    struct DebugView_Previews: PreviewProvider {
        static var previews: some View {
            DebugView()
                .environmentObject(Router<AppRoute>(root: .home))
        }
    }
#endif
