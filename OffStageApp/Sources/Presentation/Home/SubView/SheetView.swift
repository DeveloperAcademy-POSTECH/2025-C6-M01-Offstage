import BusAPI
import SwiftUI

struct SheetView: View {
    @AccessibilityFocusState private var isListeningFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var step: Int = 0
    @StateObject private var viewModel: SheetViewModel

    init(onTextRecognized: @escaping (String) -> Void) {
        _viewModel = StateObject(wrappedValue: SheetViewModel(
            onTextRecognized: onTextRecognized
        ))
    }

    var body: some View {
        ZStack {
            VStack {
                // Dismiss Button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .accessibilityLabel(L10n.Common.Ui.buttonCancel)
                }
                .padding()
                .padding(.bottom, 20)

                Spacer()

                listeningContent()

                Spacer()
            }
        }
        .onAppear {
            viewModel.startListeningProcess()

            step = 0
            for i in 1 ... 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.35) {
                    step = i
                }
            }
        }
        .onDisappear {
            viewModel.stopSpeaking()
        }
    }

    // MARK: - Listening Content

    @ViewBuilder
    private func listeningContent() -> some View {
        VStack {
            Text(L10n.Home.Stt.listening)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 30)
                .accessibilityFocused($isListeningFocused)
                .onAppear {
                    isListeningFocused = true
                }

            ZStack {
                // Concentric circles
                ForEach(1 ... 3, id: \.self) { i in
                    Circle()
                        .stroke(Color(.primarynormal).opacity([0.6, 0.4, 0.2][i - 1]), lineWidth: 6)
                        .frame(width: 110 + 48 * CGFloat(i))
                        .opacity(step >= i ? 1 : 0)
                        .animation(.easeOut(duration: 0.35), value: step)
                }

                // Central icon
                ZStack {
                    Circle()
                        .fill(.clear)
                        .frame(width: 90, height: 90)
                        .overlay(
                            Circle()
                                .stroke(Color(.primarynormal), lineWidth: 6)
                                .scaleEffect(1.2)
                        )

                    HStack(spacing: 5) {
                        Capsule().fill(.white).frame(width: 4, height: 10)
                        Capsule().fill(.white).frame(width: 4, height: 30)
                        Capsule().fill(.white).frame(width: 4, height: 50)
                        Capsule().fill(.white).frame(width: 4, height: 20)
                        Capsule().fill(.white).frame(width: 4, height: 40)
                        Capsule().fill(.white).frame(width: 4, height: 25)
                    }
                }
            }
            .task {
                // 순차로 나타났다 리셋(무한 반복)
                while true {
                    for i in 0 ... 3 {
                        step = i
                        try? await Task.sleep(for: .milliseconds(250)) // 간격 조절
                    }
                    try? await Task.sleep(for: .milliseconds(600)) // 다 켜진 상태 유지
                    step = 0 // 다시 중앙만
                    try? await Task.sleep(for: .milliseconds(300))
                }
            }

            Spacer()
        }
    }
}
