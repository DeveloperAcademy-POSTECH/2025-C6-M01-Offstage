import SwiftUI

/// 비전버스에서 곧도착  알람 뜨는 뷰
struct SoonArrivalAlertView: View {
    /// 보여줄 노선번호
    let routeNo: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bell.circle")
                .font(.title2)
                .foregroundStyle(Color(.primarynormal))

            Text("\(routeNo)번 버스가 정류장 진입 중입니다.")
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.primarynormal), lineWidth: 2)
                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.12).opacity(0.9))
        )
        .padding(.horizontal)
    }
}

#Preview {
    SoonArrivalAlertView(routeNo: "207")
}
