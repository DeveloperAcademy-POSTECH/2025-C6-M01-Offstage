import SwiftUI

/// 자주 사용되는 버스아이콘 + 노선번호 컴포넌트
struct RouteNumberToken: View {
    let routeno: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "bus.fill")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Text(routeno)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .accessibilityElement(children: .combine)
        .padding(.vertical, 6)
        .padding(.horizontal, 7)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color(.backgroundmedium))
        )
    }
}

#Preview {
    RouteNumberToken(routeno: "208(기본)")
}
