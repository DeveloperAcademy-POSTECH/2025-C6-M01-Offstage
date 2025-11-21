import SwiftUI

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

            Text("\(routeNo)번 버스가 정류장 진입 중입니다.")
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
    }
}

#Preview {
    SoonArrivalAlertView(routeNo: "207")
        .padding()
        .background(Color(.black500))
}
