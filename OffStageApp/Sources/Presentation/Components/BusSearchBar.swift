import SwiftUI

/// 버스 번호 검색을 위한 재사용 가능한 검색바 컴포넌트
struct BusSearchBar: View {
    @Binding var text: String
    let showMicButton: Bool
    let isMicEnabled: Bool
    let onSubmit: () -> Void
    let onMicTap: () -> Void

    init(
        text: Binding<String>,
        showMicButton: Bool = true,
        isMicEnabled: Bool = true,
        onSubmit: @escaping () -> Void = {},
        onMicTap: @escaping () -> Void = {}
    ) {
        _text = text
        self.showMicButton = showMicButton
        self.isMicEnabled = isMicEnabled
        self.onSubmit = onSubmit
        self.onMicTap = onMicTap
    }

    var body: some View {
        ZStack {
            TextField(
                "",
                text: $text,
                prompt: Text(L10n.Home.Stt.askBusNumber).foregroundColor(Color(.gray100))
            )
            .font(.body)
            .foregroundColor(.white)
            .background(Color(.backgroundstrong))
            .padding(.leading, 25)
            .padding(.vertical, 20)
            .onSubmit {
                onSubmit()
            }

            if showMicButton {
                HStack {
                    Spacer()

                    Button {
                        onMicTap()
                    } label: {
                        Image(systemName: "mic")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 45, height: 45)
                            .background(
                                Circle()
                                    .fill(Color(.backgroundmedium))
                            )
                    }
                    .disabled(!isMicEnabled)
                    .opacity(isMicEnabled ? 1.0 : 0.4)
                }
                .padding(.trailing, 10)
            }
        }
        .background(Color(red: 0.0784, green: 0.0823, blue: 0.1059))
        .cornerRadius(99)
    }
}
