import SwiftUI

// TODO: 추후 정류장 개수로 수정 시 텍스트와 VO라벨링 수정 필요
/// 비전버스에서 곧도착  알람 뜨는 뷰
struct SoonArrivalAlertView: View {
    /// 보여줄 노선번호
    let routeNo: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "bell.circle")
                .font(.title2)
                .fontWeight(.regular)
                .foregroundStyle(Color(.primarynormal))

            Text("버스가 전정류장에서 출발했어요.")
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.primarynormal), lineWidth: 2)
                .fill(.black)
        )
        .padding(.horizontal)
        .onAppear {
            // tts 효과를 내는 a11y announcement post
            UIAccessibility.post(
                notification: .announcement,
                argument: "\(routeNo)번 전 정류장에서 출발했습니다"
            )
        }
    }
}

#Preview {
    SoonArrivalAlertView(routeNo: "207")
        .padding()
        .background(Color(.black500))
}
