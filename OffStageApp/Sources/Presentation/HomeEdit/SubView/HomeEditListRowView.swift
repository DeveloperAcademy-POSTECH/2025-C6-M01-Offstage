import Accessibility // Added for UIAccessibility
import SwiftUI

struct HomeEditListRowView: View {
    let nodeName: String
    let nodeNo: String?
    let routes: [String]
    var onDelete: (() -> Void)? // Added onDelete closure
    var onMoveUp: (() -> Void)? // Added onMoveUp closure
    var onMoveDown: (() -> Void)? // Added onMoveDown closure

    // 색상팔레트 나오면 다음상수 없애고 지정하기
    let tertiary = Color(red: 0.73, green: 0.74, blue: 0.78)

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(nodeName)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(nodeNo ?? "")
                    .font(.callout)
                    .foregroundColor(.gray)

                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: "bus.fill")
                        .font(.footnote)
                        .foregroundStyle(tertiary)

                    Text(routes.joined(separator: ", "))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(tertiary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .accessibilityElement(children: .ignore) // Apply to the main HStack
        .accessibilityLabel(Text("\(nodeName) 정류장")) // Example label
        .accessibilityHint(Text(L10n.HomeEdit.A11y.rowHint))
        .accessibilityAction(named: Text(L10n.Common.A11y.actionDelete)) {
            onDelete?()
            // --- ⬇️ A11y 4단계 전략 적용 ⬇️ ---
            // 2. 실행 결과를 음성으로 알림
            announce(L10n.HomeEdit.A11y.announceItemDeleted)
        }
        .accessibilityAction(named: Text(L10n.HomeEdit.A11y.actionMoveUp)) { // Changed to .string
            onMoveUp?()
            // --- ⬇️ A11y 4단계 전략 적용 ⬇️ ---
            // 2. 실행 결과를 음성으로 알림
            announce(L10n.HomeEdit.A11y.announceItemMovedUp)
        }
        .accessibilityAction(named: Text(L10n.HomeEdit.A11y.actionMoveDown)) { // Changed to .string
            onMoveDown?()
            // --- ⬇️ A11y 4단계 전략 적용 ⬇️ ---
            // 2. 실행 결과를 음성으로 알림
            announce(L10n.HomeEdit.A11y.announceItemMovedDown)
        }
    }

    // --- ⬇️ Helper 함수 추가 ⬇️ ---
    /// A11y 알림을 메인 스레드에서 약간의 지연 후 실행합니다.
    /// (즉시 실행하면 VoiceOver가 액션 이름을 읽는 도중 끊길 수 있음)
    private func announce(_ message: LocalizedStringKey) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
}

#Preview {
    HomeEditListRowView(
        nodeName: "생명공학연구소",
        nodeNo: "299002",
        routes: ["207", "306"],
        onDelete: {},
        onMoveUp: {},
        onMoveDown: {}
    )
}
