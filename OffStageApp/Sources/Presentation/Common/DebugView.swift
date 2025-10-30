
#if DEBUG_MODE
    import SwiftUI

    struct DebugView: View {
        @StateObject private var logStore = LogStore.shared
        @StateObject private var speechRecognizer = STTManager()
        @StateObject private var vm = TTSManager()
        @FocusState private var isTextEditorFocused: Bool // 키보드 내리기위한 값.

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

            VStack(alignment: .leading, spacing: 20) {
                Text("음성 받아적기 테스트")

                // 인식된 텍스트 출력 영역
                // - 실시간으로 transcript가 바뀌면 화면도 즉시 갱신됨(@Published → @StateObject 바인딩)
                Text(speechRecognizer.transcript.isEmpty
                    ? "여기에 인식된 텍스트가 표시됩니다."
                    : speechRecognizer.transcript
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .overlay( // 테두리
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

                // 인식 시작/중지 버튼
                Button(action: {
                    if speechRecognizer.isListening {
                        // 현재 듣는 중이면 정지
                        speechRecognizer.stopListening()
                    } else {
                        // 듣는 중이 아니라면 시작
                        speechRecognizer.startListening()
                    }
                }) {
                    // 상태에 따라 라벨 토글
                    Text(speechRecognizer.isListening ? "🛑 인식 중지" : "🎙️ 인식 시작")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent) // 눈에 띄는 기본 버튼 스타일
            }
            .padding()

            VStack {
                // 텍스트 입력
                VStack(alignment: .leading, spacing: 20) {
                    Text("읽을 텍스트")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("텍스트를 입력하세요", text: $vm.inputText)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.3)))
                        .focused($isTextEditorFocused) // 키보드를 내리기 위한 포커스 모디파이어
                    // 키보드를 내리기 위한 버튼
                    Button("키보드 내리기") {
                        isTextEditorFocused = false
                    }
                    .buttonStyle(.bordered)
                }

                HStack {
                    Button("읽기") {
                        vm.speakNow()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("정지") {
                        vm.stop()
                    }
                    .buttonStyle(.bordered)
                }
                // 컨트롤 버튼
            }
            .padding()

            Spacer()
        }
    }

    struct DebugView_Previews: PreviewProvider {
        static var previews: some View {
            DebugView()
        }
    }
#endif
