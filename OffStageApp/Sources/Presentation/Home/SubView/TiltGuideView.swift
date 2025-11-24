import SwiftUI

/// 기울기 가이드를 표시하는 뷰 - 사다리꼴 모양으로 기울기 상태를 시각적으로 안내
struct TiltGuideView: View {
    let offset: Float
    let tiltState: TiltState

    var body: some View {
        // 사다리꼴 가이드
        TrapezoidShape(tiltOffset: offset, tiltState: tiltState)
            .fill(
                tiltState == .normal
                    ? Color.clear
                    : Color(red: 0.9, green: 1, blue: 0).opacity(0.3)
            )
            .overlay(
                TrapezoidShape(tiltOffset: offset, tiltState: tiltState)
                    .stroke(
                        tiltState == .normal
                            ? Color.clear
                            : Color.white,
                        lineWidth: 3
                    )
            )
            .animation(.easeInOut(duration: 0.3), value: offset)
    }
}

/// 기울기에 따라 변형되는 사다리꼴 모양
struct TrapezoidShape: Shape {
    let tiltOffset: Float
    let tiltState: TiltState

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // 기본 사다리꼴 비율
        let baseWidth = rect.width
        let height = rect.height

        // 기울기에 따른 상단/하단 너비 조정
        let maxSkew: CGFloat = 0.3 // 최대 기울기 효과
        let skewAmount = CGFloat(min(tiltOffset, 1.0)) * maxSkew

        var topWidth: CGFloat
        var bottomWidth: CGFloat

        switch tiltState {
        case .forward:
            // 앞으로 기울어졌을 때: 상단이 더 좁아짐
            topWidth = baseWidth * (1.0 - skewAmount)
            bottomWidth = baseWidth
        case .backward:
            // 뒤로 기울어졌을 때: 하단이 더 좁아짐
            topWidth = baseWidth
            bottomWidth = baseWidth * (1.0 - skewAmount)
        case .normal:
            // 정상일 때: 직사각형에 가까움
            topWidth = baseWidth
            bottomWidth = baseWidth
        }

        // 사다리꼴 점들 계산
        let topLeft = CGPoint(x: (baseWidth - topWidth) / 2, y: 0)
        let topRight = CGPoint(x: (baseWidth + topWidth) / 2, y: 0)
        let bottomRight = CGPoint(x: (baseWidth + bottomWidth) / 2, y: height)
        let bottomLeft = CGPoint(x: (baseWidth - bottomWidth) / 2, y: height)

        // 경로 그리기
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.closeSubpath()

        return path
    }
}
